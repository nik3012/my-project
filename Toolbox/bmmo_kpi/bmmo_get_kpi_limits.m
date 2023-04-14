function [le, lw, uw, ue] = bmmo_get_kpi_limits
% function [le, lw, uw, ue] = bmmo_get_kpi_limits
%
% Returns the default KPI limits for BMMO-NXE. Each output is a subset of
% the BMMO-NXE output KPI structure for which the appropriate limits are
% defined
%
% Output:
%   le: structure containing lower error KPI limits
%   lw: structure containing lower warning KPI limits
%   uw: structure containing upper warning KPI limits
%   ue: structure containing upper error KPI limits
%
% 20171006 SBPR Creation

limits = [...
    NaN, NaN, NaN, 10e-9; ...  %1 uncontrolled: IGNORE
    NaN, NaN, 3.0e-9,NaN; ...   %2 input
    NaN, NaN, 0.8, NaN; ...  %3 outlier coverage
    NaN, NaN, 200, NaN; ... % 4 invalids
    NaN, NaN, 5e-9, NaN; ... % 5 w2w
    NaN, NaN, 2.5e-9, NaN; ... % 6 residual
    NaN, NaN, 1e-10, NaN; ... % 7 susd
    NaN, -0.2, 0.2, NaN; ... % 8 delta ir2euv
    NaN, NaN, 1e-9, NaN; ... % 9 delta mi
    NaN, NaN, 1.4e-9, NaN; ... % 10 delta bao
    NaN, NaN, 0.8e-9, NaN; ... % 11 delta intraf
    NaN, NaN, 1.9e-9, NaN; ... % 12 delta total
    NaN, -0.8, 0.8, NaN; ... % 13 total ir2euv
    NaN, NaN, 5e-9, NaN; ... % 14 total mi 
    NaN, NaN, 5e-9, NaN; ... % 15 total bao
    NaN, NaN, 2e-9, NaN; ... % 16 total intraf
    NaN, NaN, 7.2e-9, NaN]; % 17 total total

le = sub_set_limits(limits(:, 1));
lw = sub_set_limits(limits(:, 2));
uw = sub_set_limits(limits(:, 3));
ue = sub_set_limits(limits(:, 4));

function lm = sub_set_limits(limits)

chucks = {'1', '2'};
ov = {'x', 'y'};
mi = {'ytx', 'xty'};
    
for ic = 1:2
    for ix = 1:2
        ov_string = ['ovl_chk' chucks{ic} '_997_' ov{ix}];
        %lm.uncontrolled.overlay.(ov_string) = limits(1);
        lm.input.overlay.(ov_string) = limits(2);
        lm.residue.overlay.(ov_string) = limits(6);
       
        ov_string = ['ovl_chk' chucks{ic} '_max_' ov{ix}];
        lm.correction.delta_unfiltered.bao.(ov_string) = limits(10);
        lm.correction.delta_unfiltered.k_factors.(ov_string) = limits(11);
        lm.correction.delta_unfiltered.total.(ov_string) = limits(12);
        
        lm.correction.total_unfiltered.bao.(ov_string) = limits(15);
        lm.correction.total_unfiltered.k_factors.(ov_string) = limits(16);
        lm.correction.total_unfiltered.total.(ov_string) = limits(17);
        
        ov_string = ['ovl_exp_' mi{ix} '_max_wafer_chk' chucks{ic}];
        lm.correction.delta_unfiltered.mirror.(ov_string) = limits(9);
        lm.correction.total_unfiltered.mirror.(ov_string) = limits(14);
    end
    
    lm.correction.monitor.susd.(['ovl_exp_grid_chk' chucks{ic} '_ty_susd']) = limits(7);
    lm.input.valid.(['ovl_exp_grid_chk' chucks{ic} '_nr_invalids']) = limits(4);
    lm.input.w2w.(['ovl_exp_grid_chk' chucks{ic}  '_max_w2w_var']) = limits(5);
end

lm.correction.delta_unfiltered.waferheating.ovl_exp_grid_whc = limits(8);
lm.correction.total_unfiltered.waferheating.ovl_exp_grid_whc = limits(13); 

lm.input.outlier_coverage = limits(3);
        
        