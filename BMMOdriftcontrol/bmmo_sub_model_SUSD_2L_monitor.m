function results_out = bmmo_sub_model_SUSD_2L_monitor(results_in, options)
% function results_out = bmmo_sub_model_SUSD_2L_monitor(results_in, options)
%
% The  SUSD sub-model, used for two layer input and monitoring only
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
model = 'WH_SUSD';

% Switch WH fp for modelling into options
options.WH.input_fp_per_chuck = results_in.WH.model_fp;

[results_out.SUSD.ml_7x7, results_out.SUSD.FPS, C] = bmmo_setup_combined_model(results_in.WH.input, options, model);

% Remove edge fields
for ic = options.chuck_usage.chuck_id_used
    [~, edge_fieldnos] = ovl_get_innerfields(results_out.SUSD.ml_7x7(ic), 'radius', options.edge_clearance, 'marks', 'invert');
    results_out.SUSD.ml_7x7(ic) = ovl_combine_linear(results_out.SUSD.ml_7x7(ic), 1, ovl_combine_linear(ovl_get_fields(results_out.SUSD.ml_7x7(ic), edge_fieldnos), NaN));
end

% SUSD sub-model (2-layer SUSD control calibrated in WH_SUSD submodel)
% Run the combined model
[fit_coeffs, fitted_fps] = bmmo_combined_model(results_out.SUSD.ml_7x7, results_out.SUSD.FPS, options, C);

% gather the SUSD output   
for chuck_id = options.chuck_usage.chuck_id_used
    results_out.SUSD.Monitor_SUSD(chuck_id) = fit_coeffs.SUSD{chuck_id}*1/options.scaling_factor;
    results_out.SUSD.fitted_fp(chuck_id) = fitted_fps.SUSD(chuck_id);
end

% mail from ZHMA 20160824:
% as we model SUSD using delta of 2 layers, the final SUSD value e.g.
% Ty should be half of the fitted Ty from combined model.
% -1 factor to get L1 Ty as we are using s2f in the 2 layer case
results_out.SUSD.Monitor_SUSD = -1*results_out.SUSD.Monitor_SUSD / 2;
