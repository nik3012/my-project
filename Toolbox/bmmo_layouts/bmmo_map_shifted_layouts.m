function mlo = bmmo_map_shifted_layouts(mli, mlt, shift)
% function mlo = bmmo_map_shifted_layouts(mli, mlt, shift)
%
% Map layout mli to mlt using a KD search tree, copying the overlay data to the new layout,
% returning the result in mlo
%
% Input
%   mli: input overlay structure
%   mlt: target overlay structure
%
% Optional input
%   shift: threshold distance for shift in m (default: 1e-5)
%
% Output
%   mlo: mli mapped to layout of mlt
%
% 20170516 SBPR Creation

if nargin < 3
    shift = 0.002;
end

mlo = mli;
mlo.wd = mlt.wd;
mlo.nfield = mlt.nfield;
mlo.nmark = mlt.nmark;

layout_in = [mli.wd.xw mli.wd.yw];
target_layout = [mlt.wd.xw mlt.wd.yw];

[I, D] = knnsearch(target_layout, layout_in);

% assert(all(D < shift));
% assert(length(unique(I)) == length(I));

valid = D < shift;

default_overlay = nan * mlt.layer(1).wr(1).dx;

for il = 1:mli.nlayer
    for iw = 1:mli.nwafer
        mlo.layer(il).wr(iw).dx = default_overlay;
        mlo.layer(il).wr(iw).dy = default_overlay;
        mlo.layer(il).wr(iw).dx(I(valid)) = mli.layer(il).wr(iw).dx(valid);
        mlo.layer(il).wr(iw).dy(I(valid)) = mli.layer(il).wr(iw).dy(valid);
    end
end