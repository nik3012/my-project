function results_out = bmmo_sub_model_WH(results_in, options)
% function results_out = bmmo_sub_model_WH(results_in, options)
%
% The WH sub-model
%
% Input:
%   results_in: structure containing intermediate models and results
%   This structure must at least contain the following fields:
%           ml_outlier_removed: input data with, if specified, outliers removed
%   options: options structure
%   This structure must at least contain the following fields:
%           IR2EUVsensitivity: (double) drdl value for WH calibration
%           WH.input_fp_per_chuck: input WH fingerprint averaged per chuck
%           chuck_usage.chuck_id_used: chuck ids used, in usage order
%
%   Output:
%   results_out: structure containing intermediate models and results
%       This function adds or modifies the following fields:
%           WH.residual: input, averaged per chuck after WH fingerprint removed
%           WH.FPS: raw fingerprints for WH combined model
%           WH.fit_coeffs: fit coefficients for each fingerprint
%           WH.fitted_fps: fitted fingerprints from WH combined model
%           WH.Calib_WH: IR2EUV ratio
%           WH.lambda: WH lambda value
%           WH.fp: fitted WHFP per chuck
%           WH.ml_7x7: input resampled to 7x7 (can be reused by SUSD model)

FIRST_CHUCK = 1; % index of first chuck in options.chuck_usage_chuck_id_used
model = 'WH';

% Initialise output
results_out = results_in;
mli = results_in.WH.input;

% Switch WH fp for modelling into options
options.WH.input_fp_per_chuck = results_in.WH.model_fp;

% Initialise combined model, resampled to 7x7
if ~isfield(results_out.WH, 'ml_7x7') | ~isfield(results_out.WH, 'FPS') % these fields may already have been initialised in the SUSD submodel
    [results_out.WH.ml_7x7, results_out.WH.FPS, C] = bmmo_setup_combined_model(mli, options, model);
end

% Calculate WH and SUSD calibration using combined model
% [results_out.WH.Calib_WH, ~, results_out.WH.fitted_fps, ~, ...
%     results_out.WH.fit_coeffs, results_out.SUSD.Calib_SUSD, results_out.SUSD.fitted_fp]...
%     = bmmo_combined_model_WH_DD(results_out.WH.ml_7x7, results_out.WH.FPS, options, model);

% Run the combined model
[fit_coeffs, fitted_fps] = bmmo_combined_model(results_out.WH.ml_7x7, results_out.WH.FPS, options, C);

% gather the WH output
results_out.WH.fit_coeffs = [fit_coeffs.WH{:}];
results_out.WH.fitted_fps = fitted_fps.WH(1);

results_out.WH.Calib_WH = options.IR2EUVsensitivity * results_out.WH.fit_coeffs(options.chuck_usage.chuck_id_used(1)); % this is the delta update

ch = options.chuck_usage.chuck_id_used(FIRST_CHUCK);
results_out.WH.lambda = results_out.WH.fit_coeffs(ch);

% Switch WH fp for residual into options
options.WH.input_fp_per_chuck = results_in.WH.res_fp;

% remove full WH fingerprint from input ml structure
for ic = options.chuck_usage.chuck_id_used
    results_out.WH.fp(ic) = ovl_combine_linear(options.WH.input_fp_per_chuck(ic), results_out.WH.lambda);
    results_out.interfield_residual(ic) = ovl_sub(results_out.interfield_residual(ic),results_out.WH.fp(ic));
end

results_out.WH.residual = results_out.interfield_residual;