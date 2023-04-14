function [ml_apply, ml_res] = bmmo_KA_HOC_fingerprint(ka_grid, ml_input, options)
% function [ml_apply, ml_res] = bmmo_KA_HOC_fingerprint(ka_grid, ml_input, options)
%
% Given the modelled KA grid in testlog format, get the KA fingerprint
%
% Input:
%   ka_grid:    ka_grid correction with interpolants
%   ml_input:   input ml structure
%   options:    structure containing at least the following field:
%               fieldsize: 1 * 2 array with x and y fieldsize
%
% Output:
%   ml_apply:   KA fingerprint
%   ml_res :    KA actuaiton residual
%
%  NOTE:
%  According to the BMMO-NXE EDS, ml_input.info.F does not contain 'field_shift_Cn'
%  which ovl_metro_add_chuck_info used to determine field shifts for chuck
%  n. In addition, callers of this function are not necessarily aware of the
%  chuck context. Therefore, per-chuck field shifts should be applied
%  outside this function if necessary.

% The tool ovl_create_dummy by default uses 3mm edge clearance, which is not what we want. But this script must
% also be able to model on TIS location, so we provide an 'infinite' value for 'edge'.
% (Comment copied from ovl_metro_par_mc_apply)

ml_out = ovl_create_dummy(ml_input, 'marklayout', options.CET_marklayout, 'edge', options.wafer_radius_in_mm); % <- cet grid stretches to 33mm
ml_out_F = ovl_create_dummy(ml_input, 'edge', options.wafer_radius_in_mm);

ml_out.layer.wr.dx = ka_grid.interpolant_x(ml_out.wd.xw, ml_out.wd.yw);
ml_out.layer.wr.dy = ka_grid.interpolant_y(ml_out.wd.xw, ml_out.wd.yw);
ml_out_F.layer.wr.dx = ka_grid.interpolant_x(ml_out_F.wd.xw, ml_out_F.wd.yw);
ml_out_F.layer.wr.dy = ka_grid.interpolant_y(ml_out_F.wd.xw, ml_out_F.wd.yw);

[~, cs] = bmmo_cet_model(ml_out, options.KA_actuation.type);
cs = arrayfun(@(x) x.poly2spline(), cs);
ml_apply = bmmo_cet_model(ml_out_F, cs, options.KA_actuation.type, 'return_corrections', true); % replay trajectories, 'PLAYBACK' matches TS, may have delta with DB

ml_res = ovl_sub(ml_out_F, ml_apply);
