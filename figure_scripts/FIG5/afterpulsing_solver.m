function [t_ap, pixel, pixel_model] = afterpulsing_solver(RL_idx, IB_idx, sweeps)

%% This model is right in predicting afterpulsing except for R_L = 153-155 ohms, given L_0 is constant

a      = 8.5;
b      = -1.44;

% this parameters can change based on volume of device. Best to check in
% SPICE simulation
gamma  = 1.2510727e-17;   % J/K^2
alpha  = 4.6030228e-19;  % J/K^4
% gamma  = 1.0573655e-16;   % J/K^2
% alpha  = 1.3748291e-18;  % J/K^4

Gv = 2e-9;          % thermal boundary conductance (W/K^n)
% Gv = 2e-7;

R_th   = 1/Gv;

L_0    = 200e-9;     % zero‐temp inductance (H)

I_0    = 9e-6;       % switching current scale (A)
T_c    = 10;         % critical temperature (K)
T_B    = 2;          % bath temperature (K)

% Note, these values are dependent on normal state evaluation, which will
% be separately analyzed, for now we can import them at different
% sweeps = parse_spice_sweeps('snspd-thermal-nonlinear.txt');
R_L = sweeps.R_load(RL_idx);        % load resistance (ohm)
I_B = sweeps.I_bias(IB_idx);        % bias current (A)

data = sweeps.data{RL_idx,IB_idx};
[I_R, T_R] = retrapCurrentAndTemp(data);

%    Y(1) = T,  Y(2) = i_D
odesys = @(t,Y) twoODEs(t, Y, a, b, gamma, alpha, R_th, L_0, R_L, I_0, T_c, T_B, I_B);

Y0    = [ T_R;  I_R ];

tFinal = 20e-9;   % 20 ns time length
tspan  = [ 0,  tFinal ];

opts = odeset( 'RelTol',1e-9, 'AbsTol',1e-12 );
[tt, YY] = ode45( odesys, tspan, Y0, opts );

% tt is (Mx1), YY is (M×2): col 1 = T(t), col 2 = i_D(t).

T_sol  = YY(:,1);
iD_sol = YY(:,2);

I_sw_sol = I_0 * ( 1 - (T_sol./T_c).^2 ).^(3/2);

valid = (tt < 2e-9);
T2 = (T_sol(valid)).^2;
p = polyfit(tt(valid), T2, 1);
slope     = p(1);
C  = -slope;

y_lin = log((I_B - iD_sol) ./ (I_B - I_R));
p = polyfit(tt(tt<L_0/R_L), y_lin(tt<L_0/R_L), 1);

slope = p(1);
TT = -1 / ( (L_0/R_L) * slope );

t_ap = NaN;
if (T_R == 0) && (I_R == 0)
    pixel = -1;
else
    pixel = 1;
end
for t = 1:length(tt)
    if abs(iD_sol(t)) >= I_sw_sol(t)
        t_ap = tt(t);
        pixel = 0;
        break;
    end
end

% determine if there is after pulsing
B = C/T_c^2;
A = 1 - T_R^2/T_c^2;
tau_el = L_0/R_L*TT;
t_star = 1/B*(B*tau_el/2*myLambertW(8*(I_B-I_R)^2/(9*B^3*I_0^2*tau_el^3)*exp(2*A/(B*tau_el)))-A);
F = @(t) I_0*(1-(T_R^2-C*t)./T_c^2).^(3/2)-(I_B-(I_B-I_R)*exp(-t./tau_el));
afterpulse = F(t_star) <= 0;

if afterpulse == 1
    pixel_model = 0;

elseif (T_R == 0) && (I_R == 0)
    % latching
    pixel_model = -1;
else
    % single pulse
    pixel_model = 1;
end

%% SUB ROUTINES
    function dYdt = twoODEs(~, Y, a, b, gamma, alpha, R_th, L_0, R_L, I_0, T_c, T_B, I_B)

        T  = Y(1);
        iD = Y(2);

        % Compute I_sw(T)
        if T < T_c
            I_sw = I_0 * (1 - (T./T_c)^2).^(3/2);
        else
            I_sw = 0;
        end
        
        % Compute C(T)
        if T < 0.2720*T_c
            C_T = gamma*T_c*a*exp(b/(T./T_c)) + alpha*T^3;
        else
            C_T = gamma*T_c*(-0.1129-0.1827*(T/T_c)+2.775*(T/T_c)^2) + alpha*T^3;
        end
        % dT/dt from (T_B - T)/(R_th * C(T)):
        dTdt = (T_B - T) / (R_th * C_T);

        L_k = L_0./(2*cos(0.67*asin(0.6*(iD)./I_sw)) - 1);

        diDdt = (R_L * (I_B - iD)) / L_k;

        dYdt = [ dTdt; diDdt ];
    end
end
