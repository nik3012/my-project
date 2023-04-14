function mlo = bmmo_remove_layout_nans(mli)
% function mlo = bmmo_remove_layout_nans(mli)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%

mlo = mli;

validindex = false(size(mli.wd.xw));

for iw = 1:mli.nwafer
    validindex = validindex | ~isnan(mli.layer.wr(iw).dx) | ~isnan(mli.layer.wr(iw).dy);
end

mlo.wd.xc = mlo.wd.xc(validindex);
mlo.wd.yc = mlo.wd.yc(validindex);
mlo.wd.xf = mlo.wd.xf(validindex);
mlo.wd.yf = mlo.wd.yf(validindex);
mlo.wd.xw = mlo.wd.xw(validindex);
mlo.wd.yw = mlo.wd.yw(validindex);

for iw = 1:mli.nwafer
    mlo.layer.wr(iw).dx = mlo.layer.wr(iw).dx(validindex);
    mlo.layer.wr(iw).dy = mlo.layer.wr(iw).dy(validindex);
end