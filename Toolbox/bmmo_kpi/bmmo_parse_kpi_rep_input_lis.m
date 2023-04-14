function kpi_input = bmmo_parse_kpi_rep_input_lis(kpi_rep_input, kpi_rep_outlier, stats_rep_input)
%
% function kpi_input = bmmo_parse_kpi_rep_input_lis(kpi_rep_input, kpi_rep_outlier, stats_rep_input)
%
%Given the Controlled input KPIs, Outlier coverage and statistics from the LIS job report, parse the
%contents into a BMMO-NXE kpi structure
% Input:
%   kpi_rep_input  :  Controlled input overlay metrics (99.7, M3s)
%   kpi_rep_outlier:  Outlier coverage  
%   stats_rep_input:  Controlled input overlay metrics (Max, 3s) 
% 
% Output:
%   kpi_input :  KPI (99.7, M3s, Max, 3s) Controlled overlay, & outlier coverage structure as generated by
%   BMMO model
%
% Changelog
% 20200812  ANBZ Creation
% 20201030  LUDU added w2w and data points

% Outlier coverage
kpi_input.outlier_coverage = str2double(kpi_rep_outlier.OutlierCoverage.Max) * 1e-2;

% Controlled overlay (99.7, M3s)
kpi_input.overlay = bmmo_parse_kpi_overlay_lis(kpi_rep_input(1).ControlledOverlayMetrics, kpi_rep_input(2).ControlledOverlayMetrics, 'kpi');

% Controlled overlay (Max, 3s)
kpi1_input.overlay = bmmo_parse_kpi_overlay_lis(stats_rep_input(1).ControlledOverlayMetrics, stats_rep_input(2).ControlledOverlayMetrics, 'kpi2');

% Copy  other metrics (Max, 3s) to kpi_input
kpi_input.overlay =  bmmo_add_missing_fields(kpi_input.overlay, kpi1_input.overlay);

% ERO PIs
if isfield(stats_rep_input(1), 'ControlledClamp')
    kpi_input.input_clamp = bmmo_parse_clamp_pi_lis(stats_rep_input(1).ControlledClamp, stats_rep_input(2).ControlledClamp, 'controlled');
end
    
% Wafer to wafer variation and Data Points    
for ichuck = 1:2
    if isfield(stats_rep_input(ichuck), 'W2wVariation')
        kpi_input.w2w.(['ovl_exp_grid_chk' num2str(ichuck) '_max_w2w_var']) =   str2double(stats_rep_input(ichuck).W2wVariation.MaxStDev3) * 1e-9;
    end
    if isfield(stats_rep_input(ichuck), 'DataPoints')
        kpi_input.valid.(['ovl_exp_grid_chk' num2str(ichuck) '_nr_valids']) =    str2double(stats_rep_input(ichuck).DataPoints.NumberOfValidMeasurements);
        kpi_input.valid.(['ovl_exp_grid_chk' num2str(ichuck) '_nr_readout_nans']) =  str2double(stats_rep_input(ichuck).DataPoints.NumberOfReadoutNans);
        kpi_input.valid.(['ovl_exp_grid_chk' num2str(ichuck) '_nr_invalids']) =  str2double(kpi_rep_input(ichuck).DataPoints.NumberOfInvalids);
        kpi_input.valid.(['ovl_exp_grid_chk' num2str(ichuck) '_nr_outliers']) =  str2double(stats_rep_input(ichuck).DataPoints.NumberOfOutliers);
    end
end



