function new_corr = bmmo_ewma_filter(delta_corr, prev_corr, coefficients)
% function new_corr = bmmo_ewma_filter(delta_corr, prev_corr, coefficients)
%
% Given previous correction, modelled delta correction, and filter coefficients, 
% apply an EWMA filter on the input data
% 
% new_corr = coefficients * (delta_corr + prev_corr) + 
%               (1 - coefficients) * prev_corr
% 
% Input:
%   delta_corr: delta correction in BMMO/BL3 output format
%   prev_corr: previous SBC correction in BMMO/BL3 output format
%   coefficients: filter coefficients per correction component
%
% Output:
%   new_corr: new SBC correction

inv_coefficients = bmmo_get_inverse_filter(coefficients);

new_corr = bmmo_add_output_corr(bmmo_apply_time_filter(bmmo_add_output_corr(delta_corr, prev_corr), coefficients), ...
    bmmo_apply_time_filter(prev_corr, inv_coefficients));

