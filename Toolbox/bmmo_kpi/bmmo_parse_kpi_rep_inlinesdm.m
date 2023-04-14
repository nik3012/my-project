function kpi_applied = bmmo_parse_kpi_rep_inlinesdm(kpi_rep_inlinesdm)

% parse inline SDM (not per chuck) kpis
kpi_applied.InlineSDM.maxLensCorr.dx = str2double(kpi_rep_inlinesdm.ProjectionOpticsBox.Correction.Max.X.Value) * 1e-9;
kpi_applied.InlineSDM.maxLensCorr.dy = str2double(kpi_rep_inlinesdm.ProjectionOpticsBox.Correction.Max.Y.Value) * 1e-9;
kpi_applied.InlineSDM.maxLensRes.dx = str2double(kpi_rep_inlinesdm.ProjectionOpticsBox.Residual.Max.X.Value) * 1e-9;
kpi_applied.InlineSDM.maxLensRes.dy = str2double(kpi_rep_inlinesdm.ProjectionOpticsBox.Residual.Max.Y.Value) * 1e-9;
kpi_applied.InlineSDM.Z2_2 = str2double(kpi_rep_inlinesdm.ProjectionOpticsBox.Z2_2.Value) * 1e-9;
kpi_applied.InlineSDM.Z3_2 = str2double(kpi_rep_inlinesdm.ProjectionOpticsBox.Z3_2.Value) * 1e-9;
% parse inline SDM (per chuck) kpis
fds1 = {'HigherOrderCorrections', 'Total' };
fds2 = fieldnames(kpi_rep_inlinesdm(1).(fds1{1}));

% map field and sub-fields from job report to match the kpi structure
job_fields = [fds1(1), fds1(1), fds1(2), fds1(2)];
job_sub_fields = [fds2(1), fds2(2), fds2(1), fds2(2)];
kpi_fields = { 'MaxCorrHoc', 'MaxResHoc', 'MaxCorrTotal', 'MaxResTotal', 'Fading'};
chuck = { 'Chuck1', 'Chuck2'};

for ic = 1:2
    for ifd = 1:length(kpi_fields)-1
        kpi_applied.InlineSDM.(kpi_fields{ifd})(ic).dx = str2double(kpi_rep_inlinesdm.(job_fields{ifd}).(job_sub_fields{ifd}).Max.X.(chuck{ic})) * 1e-9;
        kpi_applied.InlineSDM.(kpi_fields{ifd})(ic).dy = str2double(kpi_rep_inlinesdm.(job_fields{ifd}).(job_sub_fields{ifd}).Max.Y.(chuck{ic})) * 1e-9;
    end
    kpi_applied.InlineSDM.(kpi_fields{end})(ic).x = str2double(kpi_rep_inlinesdm.(kpi_fields{end}).Msd.X.(chuck{ic})) * 1e-9;
    kpi_applied.InlineSDM.(kpi_fields{end})(ic).y = str2double(kpi_rep_inlinesdm.(kpi_fields{end}).Msd.Y.(chuck{ic})) * 1e-9;
end