function results_out = bmmo_sub_model_SUSD_1L_monitor(results_in, options)
% function results_out = bmmo_sub_model_SUSD_1L_monitor(results_in, options)
%
% The SUSD sub-model, run for one layer input and used for monitoring only
%
% Input:
%   results_in: structure containing various results from other models
%   options: options structure
%
% Output:
%   results_out: structure containing intermediate models and results
%       This function adds the field SUSD, with the following subfields:
%           model: SUSD model
%           Calib_SUSD: SUSD calibrations
%           fp: (only if not already in WH combined model) SUSD fingerprint
%
%       If it does not exist, it also adds the field WH with the subfields
%       ml7x7 and FPS. (see bmmo_sub_model_WH for definitions).

results_out = results_in;
model = 'SUSD_1L';

if ~isfield(results_out.WH, 'ml_7x7') || ~isfield(results_out.WH, 'FPS')
    [results_out.WH.ml_7x7, results_out.WH.FPS] = bmmo_setup_combined_model(results_in.WH.input, options, model);
end

susd_options = options;

% Remove edge fields
for ic = options.chuck_usage.chuck_id_used
    [~, edge_fieldnos] = ovl_get_innerfields(results_out.WH.ml_7x7(ic), 'radius', options.edge_clearance, 'marks', 'invert');
    results_out.WH.ml_7x7(ic) = ovl_combine_linear(results_out.WH.ml_7x7(ic), 1, ovl_combine_linear(ovl_get_fields(results_out.WH.ml_7x7(ic), edge_fieldnos), NaN));
end

% switch in WH fingerprint
susd_FPS = results_out.WH.FPS;

% perform the fit and add the correction to the monitoring 
[fit_coeffs, fitted_fps] = bmmo_combined_model(results_out.WH.ml_7x7, susd_FPS, susd_options);
    
    
% gather the SUSD output   
for chuck_id = options.chuck_usage.chuck_id_used
    results_out.SUSD.Monitor_SUSD(chuck_id) = fit_coeffs.SUSD{chuck_id}*1/options.scaling_factor;
    results_out.SUSD.fitted_fp(chuck_id) = fitted_fps.SUSD(chuck_id);
end
