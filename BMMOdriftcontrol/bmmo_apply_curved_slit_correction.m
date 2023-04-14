function mlo = bmmo_apply_curved_slit_correction(mli, options, factor)
% function mlo = bmmo_apply_curved_slit_correction(mli, options, factor)
%
% The function corrects for the errors resulting from exposure curved slit
% on the given overlay structure (used for constructing MI fingerprint).
% Refactored from bmmo_construct_FPS_MI
%
% Input:
%  mli: overlay structure
%  options: BMMO/BL3 option structure
%
% Output:
%  mlo: curved slit corrected mli

if nargin < 3
    factor = 1;
end

mlo = mli;

P = polyfit(options.Q_grid.x, options.Q_grid.y, 4);
x = mli.wd.xf;
y_shift = polyval(P, x);
mlo.wd.yw = mlo.wd.yw + factor*y_shift;

