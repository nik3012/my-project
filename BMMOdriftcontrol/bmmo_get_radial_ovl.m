function [R_mean, R_median, R_mean_inward, R_median_inward] = bmmo_get_radial_ovl(wdm_clamp, R_edge, R_outer)
% function [R_mean, R_median, R_mean_inward, R_median_inward] = bmmo_get_radial_ovl(wdm_clamp, R_edge, R_outer)
%
% This function calculates the radial projection overlay
%
% Input:
%   wdm_clamp:      WDM with wafer clamp
%   R_edge:        Inner radius limit
%   R_outer:        Outer radius limit
%
% Output:
%   R_mean:             Radial ovl average
%   R_median:           Radial ovl median
%   R_mean_inward:      Radial ovl mean inward only
%   R_median_inward:    Radial ovl median inward only (SPI KPI)

%% Check for R_outer
if nargin < 3
    R_outer = 0.15; % Take all points, i.e. for measurement data with R>147
end
if nargin < 2
    R_outer = 0.15; % Take all points, i.e. for measurement data with R>147
    R_edge = 0.1451;
end

%% Prepare input data: remove edge and inner points
for iC = 1:2
    ml_inner = ovl_remove_edge(wdm_clamp(iC), R_outer);
    mli(iC) = ovl_remove_inside(ml_inner, R_edge);
%     N_pts = sum(~isnan(mli.layer.wr(1).dx));
end
for iC = 1:2
    %% Define mark positions and values.
    [xc,yc,xf,yf,dx,dy] = ovl_concat_wafer_results(mli(iC));
    xw = xc + xf;
    yw = yc + yf;
    mark_radii = 1e3.*sqrt(xw.^2 + yw.^2); % mm

    %% Define angles, for sign consistency.
    angle_o    = zeros(numel(xw),1);
    angle_r    = zeros(numel(xw),1);
    angle_r(xw >= 0) = 2.*pi;     % quadrants 1 and 4
    angle_r(xw <  0) =    pi;     % quadrants 2 and 3
    angle_o(dx >= 0) = 2.*pi;
    angle_o(dx <  0) =    pi;
    angle_r = atan(yw./xw) + angle_r;
    angle_o = atan(dy./dx) + angle_o;
    angle_final = angle_o - angle_r;

    %% Calculate radial overlay
    radial_ovl = sqrt(dx.^2 + dy.^2).*cos(angle_final); % This is the overlay projected onto its radial vector, nm
    R_mean(iC) = mean(radial_ovl, 'omitnan');
    R_median(iC) = median(radial_ovl, 'omitnan');
    R_mean_inward(iC) = mean(radial_ovl(radial_ovl<0), 'omitnan');
    R_median_inward(iC) = median(radial_ovl(radial_ovl<0), 'omitnan');
    % figure; plot(mark_radii, radial_ovl, 'b.');
    
end

end
