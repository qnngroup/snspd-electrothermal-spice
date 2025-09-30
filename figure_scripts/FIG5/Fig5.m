close all;

% Parse the sweeps (make sure parse_spice_sweeps returns fields I_bias and R_load)
% NOTE: make sure to update parameters in afterpulsing_solver.mat
sweeps     = parse_spice_sweeps('snspd-thermal-fig5-runs.txt');
% sweeps     = parse_spice_sweeps('snspd-thermal-runs.txt');

Rvec = sweeps.R_load;
Ivec = sweeps.I_bias*10^6;

RL_idx_max = length(Rvec);
IB_idx_max = length(Ivec);

pixels = zeros(RL_idx_max, IB_idx_max);
pixels_model = zeros(RL_idx_max, IB_idx_max);
t_aps  = zeros(RL_idx_max, IB_idx_max);

for RL_idx = 1:RL_idx_max
    for IB_idx = 1:IB_idx_max
        [t_ap, pixel, pixel_model] = afterpulsing_solver(RL_idx, IB_idx, sweeps);
        
        pixels(RL_idx, IB_idx) = pixel;
        t_aps(RL_idx, IB_idx)  = t_ap*10^9;
        
        pixels_model(RL_idx, IB_idx) = pixel_model;
    end
end


figure('Units',      'inches', ...
    'Position',   [1, 1, 12, 10], ... 
    'PaperUnits', 'inches', ...
    'PaperSize',  [6, 6], ...
    'PaperPosition', [0, 0, 6, 4]);
set(gcf, ...
    'defaultAxesTickLabelInterpreter','latex', ...
    'defaultLegendInterpreter','latex', ...
    'DefaultAxesFontSize', 30, ...
    'DefaultTextFontSize', 40, ...
    'defaultTextInterpreter','latex');

t_aps_max = max(t_aps(:));
t_aps_min = min(t_aps(:));
t_aps_mid = (t_aps_max + t_aps_min)./2;

scale_factor = 10;
gauss_kernel_size = 10;

% L_k from these results
L_k = 200;
tau_vec = L_k./Rvec;
[t_aps_fine, I_fine, tau_fine, IIf, ttf] = gauss_filter(pixels, t_aps, Ivec, tau_vec, scale_factor, gauss_kernel_size);
pixels_adj = zeros(RL_idx_max, IB_idx_max);
pixels_adj(pixels==1) = t_aps_max;
pixels_adj(pixels==-1) = t_aps_min;
pixels_adj(pixels==0) = t_aps_mid;

[pixels_fine, ~, ~] = gauss_filter(pixels, pixels_adj, Ivec, tau_vec, scale_factor, gauss_kernel_size);

imagesc( I_fine, tau_fine, t_aps_fine );
set(gca, 'YDir','normal');
ax = gca;
hold on

cm = colormap(ax, magma);
c = colorbar;
c.Label.String = {'After-pulse time', 'after retrapping (ns)'};
c.Label.Interpreter = 'latex';

low_level  = prctile(t_aps(:), 5);   % 10th percentile, approx. single pulsing
high_level = prctile(t_aps(:), 95);   % 90th percentile, approx. latching

contour( IIf, ttf, pixels_fine, [low_level low_level], '--', 'Color', cm(end-20, :), 'LineWidth', 1 );
contour( IIf, ttf, pixels_fine, [high_level high_level], '--', 'Color', cm(20, :),'LineWidth', 1 );


xlabel('$I_\mathrm{B}\,(\mu\mathrm{A})$',  'Interpreter','latex');
ylabel('$\tau_\mathrm{e}\,\mathrm{(ns)}$',         'Interpreter','latex');

text(Ivec(end-2), tau_vec(end), 'Latched', ...
    'Color',cm(end-20, :), ...
    'EdgeColor','none', ...
    'FontSize',40, ...
    'FontWeight','bold', ...
    'Interpreter', 'latex', ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'bottom');
text(Ivec(2), tau_vec(2), {'Single', 'pulse'}, ...
    'Color',cm(20, :), ...
    'EdgeColor','none', ...
    'FontSize',40, ...
    'FontWeight','bold', ...
    'Interpreter', 'latex', ...
    'HorizontalAlignment', 'left',...
    'VerticalAlignment', 'top');
text(Ivec(18), tau_vec(8), {'Multiple pulses'}, ...
    'Color',cm(end-50, :), ...
    'EdgeColor','none', ...
    'FontSize',40, ...
    'FontWeight','bold', ...
    'Interpreter', 'latex', ...
    'HorizontalAlignment', 'center',...
    'VerticalAlignment', 'bottom');


hold off;


function [T_fine, I_fine, R_fine, IIf, RRf] = gauss_filter(pixels, T, Ivec, Rvec, scale_factor, kernel_size)

[IIc, RRc] = meshgrid(Ivec, Rvec);

nI_fine = (numel(Ivec)-1)*scale_factor+1;
nR_fine = (numel(Rvec)-1)*scale_factor+1;

I_fine = linspace(min(Ivec), max(Ivec), nI_fine);
R_fine = linspace(min(Rvec), max(Rvec), nR_fine);
[IIf, RRf] = meshgrid(I_fine, R_fine);

Tmax = max(T(:));
Tmin = min(T(:));

for i = 1:numel(Rvec)
    for j = numel(Ivec):-1:1
        if isnan( T(i,j) ) && (pixels(i,j) == 1)
            % single pulse
            T(i,j) = Tmax*1.1;
        elseif isnan( T(i,j) ) && (pixels(i,j) == -1)
            % latching
            T(i,j) = Tmin*0.9;
        end
    end
end

sigma = 2;                        % Standard deviation for Gaussian kernel
h = fspecial('gaussian', [kernel_size kernel_size], sigma);  % Create Gaussian kernel
T_gauss = imfilter(T, h, 'replicate');  % Filter the T matrix with Gaussian

T_fine = interp2( IIc, RRc, T_gauss, IIf, RRf, 'linear' );

end
