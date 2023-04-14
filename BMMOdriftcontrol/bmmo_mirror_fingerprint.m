function mlo = bmmo_mirror_fingerprint(mli, MI_map, options, EdgeRemoval)
% function mlo = bmmo_mirror_fingerprint(mli, MI_map, options, EdgeRemoval)
%
% Given an ml input and a MI map in parmc format,
% generate a mirror fingerprint
%
% Input: 
%  MI_map: SBC mirror map
%  mli: input ml structure
%  options: BMMO/BL3 option structure
%
% Optional Input
%  EdgeRemoval: Removes edge if EdgeRemoval = 1
%
% Output:
%  mlo: single-layer, single-wafer mirror fingerprint ml structure

if nargin<4
    EdgeRemoval = 0;
end

mlo = mli;

factor = -1;
ml_curved_slit = bmmo_apply_curved_slit_correction(mlo, options, factor);
mlo.layer.wr.dx = interp1(MI_map.x_mirr.y, MI_map.x_mirr.dx, ml_curved_slit.wd.yw, 'linear', 'extrap');
mlo.layer.wr.dy = interp1(MI_map.y_mirr.x, MI_map.y_mirr.dy, mlo.wd.xc, 'linear', 'extrap');

if EdgeRemoval
    mlo = ovl_remove_edge(mlo, options.edge_clearance);
end
