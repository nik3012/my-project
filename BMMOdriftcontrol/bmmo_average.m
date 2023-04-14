function mlo = bmmo_average(mli)
% function mlo = bmmo_average(mli)
%
% Cut-down, optimized version of ovl_average that works with empty
% structures.
%
% Input:
%   mli: overlay structure
%
% Output
%   mlo: overlay structure with wafers in mli (if any) averaged to a single
%   wafer

mlo = mli;

tmp_nwafer = 0;
waf = struct('dx', [], 'dy', []);
layer = struct('wr', repmat(waf, 1, tmp_nwafer));
newlayer = repmat(layer, 1, mli.nlayer);
mlo.layer = newlayer;
mlo.nwafer = tmp_nwafer;

for il = 1:mli.nlayer
    dxmat = horzcat(mli.layer(il).wr.dx);
    dymat = horzcat(mli.layer(il).wr.dy);
    
    nw = double(size(dxmat, 2) > 0);
    for iw = 1:nw
        mlo.layer(il).wr(nw).dx = nanmean_r12(dxmat, 2);
        mlo.layer(il).wr(nw).dy = nanmean_r12(dymat, 2);
    end
    mlo.nwafer = nw;
end

