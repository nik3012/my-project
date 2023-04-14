function [ml_apply, ml_res] = bmmo_KA_33par_fingerprint(ka_grid, ml_input, options)
% function [ml_apply, ml_res] = bmmo_KA_33par_fingerprint(ka_grid, ml_input, options)
%
% Given the modelled KA grid in testlog format, get the KA fingerprint
% using 33par
%
% Input:
%   ka_grid: BMMO KA grid with interpolants (see bmmo_ka_grid)
%   ml_input: input ml structure
%   options: structure containing at least the following field:
%       fieldsize: 1 * 2 array with x and y fieldsize
%
% Output:
%   ml_apply: KA fingerprint
%   ml_res : KA actuaiton residual
%
%  NOTE:
%  According to the BMMO-NXE EDS, ml_input.info.F does not contain 'field_shift_Cn'
%  which ovl_metro_add_chuck_info used to determine field shifts for chuck
%  n. In addition, callers of this function are not necessarily aware of the
%  chuck context. Therefore, per-chuck field shifts should be applied
%  outside this function if necessary.

ml_out = ovl_create_dummy(ml_input, 'edge', options.wafer_radius_in_mm);
ml_apply = ml_out;

ml_out.layer.wr.dx = ka_grid.interpolant_x(ml_out.wd.xw, ml_out.wd.yw);
ml_out.layer.wr.dy = ka_grid.interpolant_y(ml_out.wd.xw, ml_out.wd.yw);

[~, par] = ovl_model(ml_out, options.CET33par.name, 'perfield');
par = bmmo_add_field_positions_to_parlist(par, ml_apply);
ml_apply = ovl_model(ml_apply, 'apply', par);

ml_res = ovl_sub(ml_out, ml_apply);
