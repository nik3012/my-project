function mlo = bmmo_kt_intra_fp(corr, name, ic)
% function mlo = bmmo_kt_intra_fp(corr, name, ic)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%

mlo.wd.xf = corr.ffp(ic).x;
mlo.wd.yf = corr.ffp(ic).y;
mlo.wd.xw = mlo.wd.xf;
mlo.wd.yw = mlo.wd.yf;
mlo.wd.xc = zeros(size(mlo.wd.xf));
mlo.wd.yc = mlo.wd.xc;

mlo.nwafer = 1;
mlo.nfield = 1;
mlo.nlayer = 1;
mlo.nmark = length(mlo.wd.xf);

mlo.layer.wr.dx = corr.ffp(ic).dx;
mlo.layer.wr.dy = corr.ffp(ic).dy;

mlo.tlgname = name;