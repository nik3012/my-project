function [ml_apply, ml_res] = bmmo_KA_LOC_fingerprint(ka_grid, ml_input, options)
% function ml_apply = bmmo_KA_fingerprint(ml_KA, ml_input, options)
%
% Given the modelled KA grid in testlog format, get the KA fingerprint
%
% Input:
%   ml_KA: KA grid in testlog format
%   ml_input: input ml structure
%   options: structure containing at least the following field:
%       fieldsize: 1 * 2 array with x and y fieldsize
%
% Output:
%   ml_apply: KA fingerprint
%
%  NOTE:
%  According to the BMMO-NXE EDS, ml_input.info.F does not contain 'field_shift_Cn'
%  which ovl_metro_add_chuck_info used to determine field shifts for chuck
%  n. In addition, callers of this function are not necessarily aware of the
%  chuck context. Therefore, per-chuck field shifts should be applied
%  outside this function if necessary.
%
% SBPR 2015-10-26 Refactored from ovl_metro_par_mc_apply
% JIMI 2020-04-23 Include bmmo_gxy_mc_apply_KA (worked by ANBZ)
% JIMI 2020-07-10 update with actuation/CET NCE
% SELR 2020-10-12 created from bmmo_KA_fingerprint

% The tool ovl_create_dummy by default uses 3mm edge clearance, which is not what we want. But this script must 
% also be able to model on TIS location, so we provide an 'infinite' value for 'edge'.
% (Comment copied from ovl_metro_par_mc_apply)
ml_zero = ovl_create_dummy(ml_input, 'edge', 1500);
ml_apply  = ml_zero;

ml_KA = bmmo_KA_grid_to_ml(ka_grid);
ml_KA_expose_actuation = bmmo_apply_KA(ml_KA, ml_zero, 'exposure', options.fieldsize, 'none');

% now apply to this wafer/layer
ml_apply.layer.wr.dx = ml_KA_expose_actuation.layer.wr.dx;
ml_apply.layer.wr.dy = ml_KA_expose_actuation.layer.wr.dy;

if nargout > 1
    dx_out = ka_grid.interpolant_x(ml_zero.wd.xw, ml_zero.wd.yw);
    dy_out = ka_grid.interpolant_y(ml_zero.wd.xw, ml_zero.wd.yw);
    ml_out_F = ml_zero;
    ml_out_F.layer.wr.dx = dx_out;
    ml_out_F.layer.wr.dy = dy_out;
    ml_res = ovl_sub(ml_out_F, ml_apply);
end

