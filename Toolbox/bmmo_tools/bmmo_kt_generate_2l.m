function mlo = bmmo_kt_generate_2l(mli, phase)
% function mlo = bmmo_kt_generate_2l(mli, phase)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%

if nargin < 2
    phase = 1;
end

disp('downsampling and removing edge');
mlo = ovl_remove_edge(mli);
mlo = bmmo_generate_2l_dyna25_input(mlo);

if phase == 1
    disp('extracting 1-layer input')

    mlo.raw = mlo;
    mlo = sub_get_fields(mlo, [1:87 125 136]);
end

function mlo = sub_get_fields(mli, fieldnos)

mlo = ovl_get_fields(mli, fieldnos);

% for iwafer = 1:mli.nwafer
%     mlo.info.report_data.WH_K_factors.wafer(iwafer).field = mlo.info.report_data.WH_K_factors.wafer(iwafer).field(fieldnos);
% end

mlo.info.report_data.Scan_direction = mlo.info.report_data.Scan_direction(fieldnos);
mlo.expinfo.xc =  mlo.expinfo.xc(fieldnos);
mlo.expinfo.yc = mlo.expinfo.yc(fieldnos);
mlo.expinfo.v = mlo.expinfo.v(fieldnos);
mlo.expinfo.map_fieldtoexp = mlo.expinfo.map_fieldtoexp(fieldnos);