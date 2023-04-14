function mlo = bmmo_SUSD_fingerprint(mli, scan_direction, ty)
% function mlo = bmmo_SUSD_fingerprint(mli, scan_direction, ty)
%
% Given the modelled SUSD value, apply the SUSD fingerprint to the mli
%
% Input:
%    mli: input ml structure
%   scan_direction: nx1 double containing the scan direction per field in mli
%                   n = mli.nfield
%   ty : +ty applied to up fields, -ty to down fields
%
% Output:
%   mlo: Input mli with SUSD fingerprint applied

scan_direction = scan_direction(1:mli.nfield);

ml_up = ovl_get_fields(mli, find(scan_direction > 0));
ml_do = ovl_get_fields(mli, find(scan_direction < 0));

for iwafer = 1:length(ml_up.layer.wr)
    ml_up.layer.wr(iwafer).dy = ml_up.layer.wr(iwafer).dy + ty;
end
for iwafer = 1:length(ml_do.layer.wr)
    ml_do.layer.wr(iwafer).dy = ml_do.layer.wr(iwafer).dy - ty;
end

mlo = ovl_combine_fields(ml_up, ml_do, mli);