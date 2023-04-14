function mlo = bmmo_filter_rec_positions(mli, tol)
% function mlo = bmmo_filter_rec_positions(mli, tol)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%

mlo = mli;

%recfile = 'ADELreticleErrorCorrection_62055031K001_LS_OV_RINT_NXE_Dummy_20160412T091449_zero_v4.xml';
recfile = 'ADELreticleErrorCorrection_62055031K001_LS_OV_RINT_NXE_Dummy_nonzero_v5.xml';
rec = xml_load(recfile);

rec_xy = bmmo_get_nominal_from_wec_rec(rec);

% Set every mark not in wec_xy to NaN
xy = [mli.wd.xf mli.wd.yf];

% round to nearest tol
rec_xy = round(rec_xy, tol);
xy = round(xy, tol);


recids = ismember(xy, rec_xy, 'rows');

assert(all(recids), 'Input has intrafield positions not found in REC file');

% for iw = 1:mli.nwafer
%     mlo.layer.wr(iw).dx(~recids) = NaN;
%     mlo.layer.wr(iw).dy(~recids) = NaN;
% end