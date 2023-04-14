function mlo = bmmo_convert_to_smf(mli)
% function mlo = bmmo_convert_to_smf(mli)
%
% The function converts the standard ml structure to single mark field (SMF) layout
% Unlike the function bmmo_map_to_smf, this function does not not map to
% a given template of SMF structure.
%
% Input: 
%  mli: overlay ml structure
%
% Output:
%  mlo: mli converted to single mark field layout

nanids = true(size(mli.wd.xw));

for iw = 1:mli.nwafer
    nanids = nanids & (isnan(mli.layer.wr(iw).dx) & isnan(mli.layer.wr(iw).dy));
end

mlo = mli;

valid = ~nanids;

mlo.wd.xc = mlo.wd.xc(valid);
mlo.wd.yc = mli.wd.yc(valid);
mlo.wd.xf = mlo.wd.xf(valid);
mlo.wd.yf = mli.wd.yf(valid);
mlo.wd.xw = mlo.wd.xw(valid);
mlo.wd.yw = mli.wd.yw(valid);


for iw = 1:mli.nwafer
    mlo.layer.wr(iw).dx = mlo.layer.wr(iw).dx(valid);
    mlo.layer.wr(iw).dy = mlo.layer.wr(iw).dy(valid);
end

mlo.nmark = 1;
mlo.nfield = length(mlo.wd.xc);