function output_struct = bmmo_remodel_with_filter(input_struct, filter_flag)
% function output_struct = bmmo_remodel_with_filter(input_struct, filter_flag)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%

input_struct_recover = input_struct;
input_struct_recover.info.report_data.time_filtering_enabled = filter_flag;
output_struct = bmmo_nxe_drift_control_model(input_struct_recover);

SBC2 = output_struct.corr;

% replace ffp with modelled inline SDM fingerprint and apply
flds = ovl_combine_linear(bmmo_ffp_to_ml(SBC2.ffp), -1);

[~, ~, ~, ~, res] = BMMO_model_inlineSDM(ovl_get_wafers(flds, 1), ovl_get_wafers(flds, 2), 'LFP', 0);

sbcnew = SBC2;
for ic = 1:2
    sbcnew.ffp(ic).dx = SBC2.ffp(ic).dx + res.TotalRes(ic).dx;
    sbcnew.ffp(ic).dy = SBC2.ffp(ic).dy + res.TotalRes(ic).dy;
end

output_struct.corr = sbcnew;