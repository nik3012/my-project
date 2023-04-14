function options_out = bmmo_wh_options(ml, options_in)
% function options_out = bmmo_wh_options(ml, options_in)
%
% Add the WH fingerprint to the options structure.
% This function was refactored from bmmo_ml_options to allow field
% reconstruction to take place before constructing the WH fp from K-factors
% (for backwards compatibility with unit tests)
%
% Input: 
%   ml:          standard overlay structure
%   options_in:  bmmo options structure as output by bmmo_ml_options
%
% Output: 
%   options_out: options_in with field WH.input_fp_per_chuck added

options_out = options_in;

% calculate IR2EUVsensitivity
options_out.IR2EUVsensitivity = bmmo_calculate_WH_sensitivity(options_out);

% generate WH fingerprint per chuck
whfp = bmmo_construct_wh_fp(ml, options_out);
options_out.WH.input_fp_per_chuck = bmmo_average_chuck(whfp, options_out);
options_out.WH.fp = whfp;

% we can now remove the field WH_K_factors from options_out, since it will
% no longer be used
options_out = rmfield(options_out, 'WH_K_factors');