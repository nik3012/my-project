function mlo = bmmo_kt_generate_1l(mli, phase)
% function mlo = bmmo_kt_generate_1l(mli, phase)
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
mlo = rmfield(mlo, 'raw');

if length(mlo.info.report_data.WH_K_facfors.wafer(1).field) > 89
    mlo = sub_get_k_factor_fields(mlo, [1:87 125 136]);
end


function mlo = sub_get_k_factor_fields(mli, fieldnos)

for iwafer = 1:mli.nwafer
    mlo.info.report_data.WH_K_factors.wafer(iwafer).field = mlo.info.report_data.WH_K_factors.wafer(iwafer).field(fieldnos);
end

