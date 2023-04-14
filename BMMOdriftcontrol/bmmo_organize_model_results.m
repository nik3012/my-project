function [results_out, kpi_out]= bmmo_organize_model_results(intermediate_results, options)
% function [results_out, kpi_out]= bmmo_organize_model_results(intermediate_results, options)
%
% Fill the model results output, applying the time filtering coefficients and
% adding to the previous correction
%
% Input:
%   intermediate_results: structure defined in bmmo_default_model_result.m
%   options: BMMO/BL3 default option structure
%
% Output:
%   results_out: structure defined in bmmo_default_output_structure.m, with
%       values filled in from intermediate_results and time filtering
%       coefficients applied from options.filter_coefficients
%   kpi_out: structure containing the following SBC correction structures
%            delta_filtered
%            delta_unfiltered
%            total_filtered
%            total_unfiltered

[results_out.corr, kpi_out] = feval(options.filter.function, intermediate_results, options);

% add output configurations
results_out.corr.Configurations.KA_start_x  = options.KA_start;
results_out.corr.Configurations.KA_start_y  = options.KA_start;
results_out.corr.Configurations.KA_steps_x  = options.KA_length;
results_out.corr.Configurations.KA_steps_y  = options.KA_length;
results_out.corr.Configurations.KA_pitch_x  = options.KA_pitch;
results_out.corr.Configurations.KA_pitch_y  = options.KA_pitch;
results_out.corr.Configurations.MI_start    = options.map_param.start_position;
results_out.corr.Configurations.MI_steps    = options.map_table_length;
results_out.corr.Configurations.MI_pitch    = options.map_param.pitch;
