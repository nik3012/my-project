function mlo = bmmo_fill_layout(ml)
% function mlo = bmmo_fill_layout(ml)
%
% Given an overlay structure with minimal field centre and intrafield coordinate definitions,
% (e.g. a raw readout from ADEL metrology) return an equivalent structure with all wafer coordinates defined and 
% NaN overlay values for the new coordinate positions
%
% Input:
%   ml: overlay structure
%
% Output:
%   mlo: overlay structure with full layout definition
%
% 20170519 SBPR Added documentation

[u_xc_yc, index_c] = unique([ml.wd.xc, ml.wd.yc], 'rows');
[u_xf_yf, index_m] = unique([ml.wd.xf, ml.wd.yf], 'rows');

ml.nfield = size(u_xc_yc, 1);
ml.nmark = size(u_xf_yf, 1);

[xcg, xfg] = meshgrid(ml.wd.xc(index_c), ml.wd.xf(index_m));
[ycg, yfg] = meshgrid(ml.wd.yc(index_c), ml.wd.yf(index_m));

mlo = ml;
mlo.wd.xc = xcg(:);
mlo.wd.yc = ycg(:);
mlo.wd.xf = xfg(:);
mlo.wd.yf = yfg(:);
mlo.wd.xw = mlo.wd.xc + mlo.wd.xf;
mlo.wd.yw = mlo.wd.yc + mlo.wd.yf;

newc = [mlo.wd.xw mlo.wd.yw];
oldc = [ml.wd.xw ml.wd.yw];

I = knnsearch(newc, oldc);

for il = 1:mlo.nlayer
    for iw = 1:mlo.nwafer
        mlo.layer(il).wr(iw).dx = nan * mlo.wd.xc;
        mlo.layer(il).wr(iw).dy = nan * mlo.wd.xc;
        mlo.layer(il).wr(iw).dx(I) = ml.layer(il).wr(iw).dx;
        mlo.layer(il).wr(iw).dy(I) = ml.layer(il).wr(iw).dy;
    end
end


