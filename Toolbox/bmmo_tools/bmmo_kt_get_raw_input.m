function mlo = bmmo_kt_get_raw_input(kt_wafers_out, adeller)
% function mlo = bmmo_kt_get_raw_input(kt_wafers_out, adeller)
%
% From kt_wafers_out and adeller, generate a basic input with ml.raw
%
% Input: kt_wafers_out: full path of kt_wafers_out file
%        adeller: full path of ADELler
%
% Output: mlo: ml structure with the following fields:
%           nlayer
%           nfield
%           nwafer
%           nmark
%           wd
%           layer
%           tlgname
%           raw
%
% 20160419 SBPR Creation

disp('reading ADELler');
expinfo = bmmo_expinfo_from_adeller(adeller);

disp('reading KT_wafers_out');
mlt = bmmo_get_meas_data(kt_wafers_out, expinfo);

mlt.tlgname = '';


% if mlo.nfield is greater than 89, split into two (second element will
% have LS_OV_RINT_NOWEC targets
if mlt.nfield > 89
    l1_fields = [1:87 125 136];
    
    mlo = ovl_get_fields(mlt, l1_fields);
    mlo.raw = mlt;
else
    mlo = mlt;
end




