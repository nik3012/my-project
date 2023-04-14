function erokpi = bmmo_get_KPI_ERO(wdm_clamp, type, R_inner, R_edge, R_outer)
% function erokpi = bmmo_get_KPI_ERO(wdm_clamp, type, R_inner, R_edge, R_outer)
%
% Generate Edge Roll Off KPIs as described in D000810611
%
% Input:
%   wmd_clamp:      WDM with wafer clamp
%   type:           'controlled' - Controlled input clamp KPI
%                   'uncontrolled' - Uncontrolled input clamp KPI
%                   'modelled' - Modelled clamp (KA) KPI
%   R_inner:        Inner wafer area radius, R = 0.140 m, see D000810611
%   R_edge:         Wafer edge radius, R = 0.1451 m, see D000810611
%   R_outer:        Outer radius limit, taken into account, R = 0.147 or
%                   0.150 m, see D000810611.
%
% Output:
%   erokpi:         ERO kpi structure as described in D000810611.

%% Check for R_outer
if nargin < 5
    R_outer = 0.15; % Take all points, i.e. for measurement data with R>147
end
if nargin < 4
    R_outer = 0.15; % Take all points, i.e. for measurement data with R>147
    R_edge = 0.1451;
end
if nargin < 3
    R_outer = 0.15; % Take all points, i.e. for measurement data with R>147
    R_edge = 0.1451;
    R_inner = 0.140;
end

%% Calculate ovl-radial
[R_mean, R_median, R_mean_inward, R_median_inward] = bmmo_get_radial_ovl(wdm_clamp, R_edge, R_outer);

%% Split inner and outer wafer area
for iC = 1:2
    ml_inner(iC) = ovl_remove_edge(wdm_clamp(iC), R_inner);
    ml_outer(iC) = ovl_remove_edge(ovl_remove_inside(wdm_clamp(iC), R_inner), R_outer);
end

%% Controlled Input Clamp Overlay Inner/Outer
for iC = 1:2
    ovl_inner(iC) = ovl_calc_overlay(ml_inner(iC));
    ovl_outer(iC) = ovl_calc_overlay(ml_outer(iC));
end

%% Arrange KPIs to be mapped to .PI.controlled.input_clamp.
for iC = 1:2
    chuckstr = num2str(iC);
    switch(type)
        case 'controlled'
            % KPI Inner
            erokpi.(['ovl_inner_chk' chuckstr '_997_x']) = ovl_inner(iC).ox997;
            erokpi.(['ovl_inner_chk' chuckstr '_997_y']) = ovl_inner(iC).oy997;
            erokpi.(['ovl_inner_chk' chuckstr '_max_x'])  = ovl_inner(iC).ox100;
            erokpi.(['ovl_inner_chk' chuckstr '_max_y'])  = ovl_inner(iC).oy100;
            erokpi.(['ovl_inner_chk' chuckstr '_m3s_x'])  = ovl_inner(iC).oxm3s;
            erokpi.(['ovl_inner_chk' chuckstr '_m3s_y'])  = ovl_inner(iC).oym3s;
            erokpi.(['ovl_inner_chk' chuckstr '_3std_x']) = ovl_inner(iC).ox3sd;
            erokpi.(['ovl_inner_chk' chuckstr '_3std_y']) = ovl_inner(iC).oy3sd;
            % KPI Outer
            erokpi.(['ovl_outer_chk' chuckstr '_997_x']) = ovl_outer(iC).ox997;
            erokpi.(['ovl_outer_chk' chuckstr '_997_y']) = ovl_outer(iC).oy997;
            erokpi.(['ovl_outer_chk' chuckstr '_max_x'])  = ovl_outer(iC).ox100;
            erokpi.(['ovl_outer_chk' chuckstr '_max_y'])  = ovl_outer(iC).oy100;
            erokpi.(['ovl_outer_chk' chuckstr '_m3s_x'])  = ovl_outer(iC).oxm3s;
            erokpi.(['ovl_outer_chk' chuckstr '_m3s_y'])  = ovl_outer(iC).oym3s;
            erokpi.(['ovl_outer_chk' chuckstr '_3std_x']) = ovl_outer(iC).ox3sd;
            erokpi.(['ovl_outer_chk' chuckstr '_3std_y']) = ovl_outer(iC).oy3sd;
            % KPI Radial
            erokpi.(['ovl_radial_chk' chuckstr '_mean']) = R_mean(iC);
            erokpi.(['ovl_radial_chk' chuckstr '_median']) = R_median(iC);
        case 'uncontrolled'
            % KPI Radial
            erokpi.(['ovl_radial_chk' chuckstr '_mean']) = R_mean(iC);
            erokpi.(['ovl_radial_chk' chuckstr '_median']) = R_median(iC);
            erokpi.(['ovl_radial_inward_chk' chuckstr '_mean']) = R_mean_inward(iC);
            erokpi.(['ovl_radial_inward_chk' chuckstr '_median']) = R_median_inward(iC);
        case 'modelled'
            % KPI Outer
            erokpi.(['ovl_outer_chk' chuckstr '_997_x']) = ovl_outer(iC).ox997;
            erokpi.(['ovl_outer_chk' chuckstr '_997_y']) = ovl_outer(iC).oy997;
            erokpi.(['ovl_outer_chk' chuckstr '_max_x'])  = ovl_outer(iC).ox100;
            erokpi.(['ovl_outer_chk' chuckstr '_max_y'])  = ovl_outer(iC).oy100;
            erokpi.(['ovl_outer_chk' chuckstr '_m3s_x'])  = ovl_outer(iC).oxm3s;
            erokpi.(['ovl_outer_chk' chuckstr '_m3s_y'])  = ovl_outer(iC).oym3s;
            erokpi.(['ovl_outer_chk' chuckstr '_3std_x']) = ovl_outer(iC).ox3sd;
            erokpi.(['ovl_outer_chk' chuckstr '_3std_y']) = ovl_outer(iC).oy3sd;
            % KPI Radial
            erokpi.(['ovl_radial_chk' chuckstr '_mean']) = R_mean(iC);
            erokpi.(['ovl_radial_chk' chuckstr '_median']) = R_median(iC);
    end
end

end


