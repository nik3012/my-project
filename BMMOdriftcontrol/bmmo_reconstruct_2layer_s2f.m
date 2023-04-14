function mlo = bmmo_reconstruct_2layer_s2f(mli, options)
% function mlo = bmmo_reconstruct_2layer_s2f(mli, options)
%
% Reconstruct s2f data from '2-layer' non-WEC-corrected input
%
% Input:
%   mli:        ml structure with 167 fields: layer 1 in fields 1-87, layer 2 in
%               fields 88-167
%   options:    bmmo options structure as defined in
%               bmmo_default_options_structure
%   
%  Output:
%   mlo:        ml structure with 87 fields: shifted s2f data, should be same
%               layout as WH fp and input


ml_l1 = ovl_get_fields(mli, options.layer_fields{1});
ml_l2 = ovl_get_fields(mli, options.layer_fields{2}:mli.nfield);

ml_l1 = bmmo_shift_fields(ml_l1, options.WH.l1_shift_x, options.WH.l1_shift_y);
ml_l2 = bmmo_shift_fields(ml_l2, options.WH.l2_shift_x, options.WH.l2_shift_y);

mlo = ovl_combine_linear(ovl_sub(ml_l1, ml_l2), -1); % preserve field ordering from layer 1