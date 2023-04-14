function [fit_coeffs, fitted_fps, residuals] = bmmo_combined_model(ml_ch, fps, options, C)
% function [fit_coeffs, fitted_fps, residuals] = bmmo_combined_model(ml_ch, fps, options, C)
%
% This function fits the input data to the WH fingerprint, MI and
% interfield, intrafield and data delay effects using combined model.
%
% Input :
%   ml_ch : standard ovl structure, averaged per chuck (1 * number chucks array)
%   fps : Vector of ml structures:
%       Fingerprints containing WH, basis for mirror x and y, interfield,
%       intrafield and dd components. Same layout as mli
%   options : BMMO/BL3 default options structure
%
% Optional input:
%   C: Constraint matrix
%
% Output :
%   fit_coeffs: structure containing one field for each entry in
%       options.combined_model_contents (e.g. WH, MIX, MIY, INTRAF, INTERF)
%       Each field is a 1x2 double array containing the fit coefficient per
%       chuck for that combined model element
%   fitted_fps: structure containing one field for each entry in
%       options.combined_model_contents (e.g. WH, MIX, MIY, INTRAF, INTERF)
%       Each field is a 1x2 ml structure array containing the fitted fingerprint per
%       chuck for that combined model element
%   residuals: 1x2 ml structure array, containing the residuals for the full combined model, per chuck
%
% For details of the model and definitions of in/out interfaces, refer to
% D000810611  EDS BMMO NXE drift control model


if nargin < 4
    C= [];
end

% make chuck_id_used horizontal, for compatibility with unit test data
options.chuck_usage.chuck_id_used = reshape(options.chuck_usage.chuck_id_used, 1, []);

% Calculate the fitted fingerprints
[fit_coeffs, fitted_fps, residuals] = bmmo_fit_fingerprints(ml_ch, fps, options, C);
