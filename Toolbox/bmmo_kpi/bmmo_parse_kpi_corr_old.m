function kpi_corr = bmmo_parse_kpi_corr_old(kpi_rep_corr)
% function kpi_corr = bmmo_parse_kpi_corr_old(kpi_rep_corr)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%

% do monitoring
kpi_corr.monitor.susd.ovl_exp_grid_chk1_ty_susd = str2double(kpi_rep_corr.Monitoring.SuSd.ExposureGrid.Translation.Y.AbsoluteDelta.Chuck1) * 1e-9;
kpi_corr.monitor.susd.ovl_exp_grid_chk2_ty_susd = str2double(kpi_rep_corr.Monitoring.SuSd.ExposureGrid.Translation.Y.AbsoluteDelta.Chuck2) * 1e-9;




