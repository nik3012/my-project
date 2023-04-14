function [corr_out, kpi_out, zero_corr] = bmmo_apply_ewma_filter(model_results, options)
% function [corr_out, kpi_out, zero_corr] = bmmo_apply_ewma_filter(model_results, options)
%
% The function does the following:
  % Applies ewma time filtering on SBC correction.
  % Generates correction structures such as delta filtered/unfiltered and
  %   total filtered/ unfiltered. 
  % Inserts zeros in the previous corrections that are disabled in the
  %   configuration (SUSD/KA/KA@M).
  % Removes 10 par from total filtered/unfiltered FFP
%
% Input:
%   model_results: intermediate model results
%   options: BMMO/BL3 options structure
%
% Output: 
%   corr_out: BMMO/BL3 SBC correction structure (sent to TS)
%   kpi_out: structure containing the following SBC correction structures
%       delta_filtered
%       delta_unfiltered
%       total_filtered (equal to corr_out)
%       total_unfiltered
%   zero_corr: zero BMMO/BL3 SBC correction structuere

% Initializations
zero_out = bmmo_default_output_structure(options);   
zero_corr = zero_out.corr;

delta_corr = bmmo_fill_correction(zero_corr, model_results, options);
empty_filter = bmmo_get_empty_filter;

delta_corr = bmmo_apply_time_filter(delta_corr, empty_filter, -1); % invert the sign of delta_corr


if options.undo_before_modelling > 0
     delta_corr = bmmo_add_output_corr(delta_corr, bmmo_apply_time_filter(options.previous_correction, empty_filter, -1));
end

if ~options.KA_control
    for i=1:length(options.previous_correction.KA.grid_2de)
        options.previous_correction.KA.grid_2de(i).dx = options.previous_correction.KA.grid_2de(i).dx*0;
        options.previous_correction.KA.grid_2de(i).dy = options.previous_correction.KA.grid_2de(i).dy*0;
    end
end

if ~options.KA_measure_enabled
    for i=1:length(options.previous_correction.KA.grid_2dc)
        options.previous_correction.KA.grid_2dc(i).dx = options.previous_correction.KA.grid_2dc(i).dx*0;
        options.previous_correction.KA.grid_2dc(i).dy = options.previous_correction.KA.grid_2dc(i).dy*0;
    end
end

if ~options.susd_control
    for i=1:length(options.previous_correction.SUSD)
        options.previous_correction.SUSD(i).TranslationY = options.previous_correction.SUSD(i).TranslationY*0;
    end
end

kpi_out.delta_filtered   =  bmmo_ewma_filter(delta_corr, zero_corr, options.filter.coefficients);
kpi_out.delta_unfiltered =  bmmo_ewma_filter(delta_corr, zero_corr, empty_filter);
kpi_out.total_filtered   =  bmmo_ewma_filter(delta_corr, options.previous_correction, options.filter.coefficients);
kpi_out.total_unfiltered =  bmmo_ewma_filter(delta_corr, options.previous_correction, empty_filter);

kpi_out.delta_filtered   = bmmo_fix_KA_corr(kpi_out.delta_filtered);
kpi_out.delta_unfiltered = bmmo_fix_KA_corr(kpi_out.delta_unfiltered);
kpi_out.total_filtered   = bmmo_fix_KA_corr(kpi_out.total_filtered);
kpi_out.total_unfiltered = bmmo_fix_KA_corr(kpi_out.total_unfiltered);

% recommendation after JIMI convergence study:
% remove 10par from total ffp output
kpi_out.total_filtered.ffp = bmmo_model_10par_ffp(kpi_out.total_filtered.ffp, options);
kpi_out.total_unfiltered.ffp = bmmo_model_10par_ffp(kpi_out.total_unfiltered.ffp, options);

corr_out = kpi_out.total_filtered;
