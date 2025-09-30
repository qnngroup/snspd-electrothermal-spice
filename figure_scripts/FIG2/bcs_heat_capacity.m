%% BCS Electronic Heat Capacity (alpha-model, alpha_{BCS}= 1.76)
clear all; close all;

% Parameters
alpha = 1.76;          % delta(0)/(k_B T_c)
L = 500;               % cutoff for energy integral
logTerm = log(2*L);

% Reduced temperature array (0 < t <= 1)
t_vals = linspace(0.001, 1, 400);
Delta_tilde = zeros(size(t_vals));

% fzero options
opts = optimset('TolX',1e-8);

%% Solve BCS gap equation
for i = 1:length(t_vals)-1
    t = t_vals(i);
    if abs(t - 1) < 1e-6
        Delta_tilde(i) = 1.737 * sqrt(1 - t);
    else
        gap_eq = @(D) integral(@(eps) (1./sqrt(eps.^2 + D.^2) .* ...
            tanh(alpha*sqrt(eps.^2 + D.^2)/(2*t))), 0, L, 'ArrayValued', true) - logTerm;
        if i == 1
            D0 = 1;
        else
            D0 = Delta_tilde(i-1);
        end
        Delta_tilde(i) = fzero(gap_eq, D0, opts);
    end
end
Delta_tilde(end) = 0; % at t = 1

%% Numerical derivative d(delta^2)/dt
Delta_sq = Delta_tilde.^2;
dDelta_sq_dt = gradient(Delta_sq, t_vals);

% Phenomenological gap and its derivative
Delta_tilde_phen = tanh(1.74 .* sqrt(1./t_vals - 1));
% derivative computed analytically
x = 1 ./ t_vals - 1;
dDelta_sq_dt_phen = -(1.74 .* tanh(1.74 .* sqrt(x)) .* sech(1.74 .* sqrt(x)).^2) ./ (sqrt(x) .* t_vals.^2);
dDelta_sq_dt_phen(~isfinite(dDelta_sq_dt_phen)) = 0; % handle t->1

%% Compute normalized superconducting heat capacity C_es/(gamma_n T_c)
Ces_norm = zeros(size(t_vals));
Ces_norm_phen = zeros(size(t_vals));
for i = 1:length(t_vals)
    t = t_vals(i);
    D = Delta_tilde(i);
    dDsq_dt = dDelta_sq_dt(i);
    integrand = @(eps) ( ...
        (1./(exp(alpha*sqrt(eps.^2 + D^2)/t) + 1)) .* (1 - 1./(exp(alpha*sqrt(eps.^2 + D^2)/t) + 1)) ...
        .* ((eps.^2 + D^2) ./ t - 0.5*dDsq_dt) );
    I = integral(integrand, 0, L, 'ArrayValued', true, 'RelTol', 1e-6);
    Ces_norm(i) = (6 * alpha^3) / (pi^2 * t) * I;

    % phenomenological gap
    Dp = Delta_tilde_phen(i);
    dDsq_dt_p = dDelta_sq_dt_phen(i);
    integrand_p = @(eps) ( ...
        (1./(exp(alpha*sqrt(eps.^2 + Dp^2)/t) + 1)) .* (1 - 1./(exp(alpha*sqrt(eps.^2 + Dp^2)/t) + 1)) ...
        .* ((eps.^2 + Dp^2) ./ t - 0.5*dDsq_dt_p) );
    Ip = integral(integrand_p, 0, L, 'ArrayValued', true, 'RelTol', 1e-6);
    Ces_norm_phen(i) = (6 * alpha^3) / (pi^2 * t) * Ip;
end

%% Normal-state heat capacity (C_en/(gamma_n T_c) = t for T >= T_c)
t_normal = linspace(1, 1.5, 20);
Ces_normal = t_normal;

%% Fit: quadratic to high-t superconducting tail (subset of data)
[xData, yData] = prepareCurveData(t_vals(75:end), Ces_norm(75:end));
ft = fittype('A + B*x + C*x^2', 'independent', 'x', 'dependent', 'y');
fopts = fitoptions('Method', 'NonlinearLeastSquares', 'Display', 'Off');
[fitresult, ~] = fit(xData, yData, ft, fopts);

% piecewise fit: exponential for low-t, quadratic for higher t
Ces_exp = @(t) 8.5 .* exp(-1.44 ./ t);
Ces_quad = @(t) fitresult.A + fitresult.B.*t + fitresult.C.*t.^2;
fit_intersection = @(t) Ces_quad(t) - Ces_exp(t);
z = fzero(fit_intersection, 0.5, opts);

t_vals_fit = [linspace(0.001, z, 200), linspace(z, 1, 200)];
Ces_fit = [Ces_exp(linspace(0.001, z, 200)), Ces_quad(linspace(z, 1, 200))];

%% Plot
figure; hold on;
plot(t_vals_fit, Ces_fit, 'k', 'LineWidth', 1);
plot(t_vals, Ces_norm, 'c--', 'LineWidth', 1);
plot(t_normal, Ces_normal, 'r--', 'LineWidth', 1);
yline(2.43, '--');
xline(1, '--');
xlabel('T/T_c');
ylabel('C_{es}/(\gamma_n T_c)');
legend('Superconducting (piecewise fit)', 'Superconducting (BCS, numerical gap)', 'Normal state', ...
    'Location', 'NorthWest', 'Interpreter', 'Latex');
title('Normalized Electronic Heat Capacity vs. Reduced Temperature');
grid on;
