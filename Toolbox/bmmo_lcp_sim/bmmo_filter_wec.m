function mlo = bmmo_filter_wec(mli, tol)
% function mlo = bmmo_filter_wec(mli, tol)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%

mlo = mli;

% Set every mark not in wec_xy to NaN
xy = [mli.wd.xw mli.wd.yw];
xy = round(xy, tol);

for iw = 1:mlo.nwafer
    wecfile = ['WEC_KTBLMMO00' num2str(iw) '_LS_OV_RINT_20160412_1302_v1_4.xml'];

    wec = xml_load(wecfile);

    wec_pos = bmmo_get_nominal_from_wec_rec(wec);  
    wec_pos = round(wec_pos, tol);

    wecids = ismember(xy, wec_pos, 'rows');

    assert(all(isnan(mlo.layer.wr(iw).dx(~wecids)) | isnan(mlo.layer.wr(iw).dy(~wecids))), 'Mark positions missing from wec file for wafer %d', iw);

end