function [ml_apply, ml_res, ml_cet_nce] = bmmo_KA_LOC_CET_fingerprint(ka_grid, ml_input, options)
% function [ml_apply, ml_res, ml_cet_nce] = bmmo_KA_LOC_CET_fingerprint(ka_grid, ml_input, options)
%
% Given the modelled KA grid in testlog format, get the KA fingerprint
% after LOC and CET actuation
%
% Input:
%   ka_grid: KA grid in testlog format
%   ml_input: input ml structure
%   options: structure containing at least the following field:
%       fieldsize: 1 * 2 array with x and y fieldsize
%       CET_marklayout
%       wafer_radius_in_mm
%       KA_actuation.type
%       
% Output:
%   ml_apply: KA fingerprint after LOC and CET actuation
%
% Optional Outputs:
%   ml_res : KA residual after LOC correction and CET actuation
%   ml_cet_nce: KA CET actuation residual(only)


ml_cet_input = ovl_create_dummy(ml_input, 'marklayout', options.CET_marklayout, 'edge', options.wafer_radius_in_mm);
ml_out_F = ovl_create_dummy(ml_input, 'edge', options.wafer_radius_in_mm);

ml_cet_loc_corr = bmmo_KA_LOC_fingerprint(ka_grid, ml_cet_input, options); % LOC corrrection in CET layout
[~, cs] = bmmo_cet_model(ml_cet_loc_corr, options.KA_actuation.type);% CET actuation in CET layout
cs = arrayfun(@(x) x.poly2spline(), cs);
ml_apply = bmmo_cet_model(ml_out_F, cs, options.KA_actuation.type, 'return_corrections', true); % replay trajectories on ml_out_F layout/meas layout

if nargout > 1
    [ml_loc_corr, ml_loc_res] = bmmo_KA_LOC_fingerprint(ka_grid, ml_input, options);
    ml_cet_nce = ovl_sub(ml_loc_corr, ml_apply); %CET NCE with KA LOC corrected input
    ml_res = ovl_add(ml_loc_res, ml_cet_nce); % add LOC res and CET nce
end

