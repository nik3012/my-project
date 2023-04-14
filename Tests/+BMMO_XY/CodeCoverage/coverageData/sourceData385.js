var sourceData385 = {"FileContents":["function kpi_input = bmmo_parse_kpi_rep_input(kpi_rep_input)\r","%\r","% function kpi_input = bmmo_parse_kpi_rep_input(kpi_rep_input)\r","%\r","%Given the Controlled input KPIs from the OTAS job report, parse the\r","%contents into a BMMO-NXE kpi structure\r","% Input:\r","%   kpi_rep_input  : Controlled input KPIs from the job report\r","% \r","% Output:\r","%   kpi_input :  KPI Controlled overlay structure as generated by\r","%   BMMO model\r","%\r","% Changelog\r","% 20171030 SBPR Creation\r","\r","chuckstr = {'Chuck1','Chuck2'};\r","\r","kpi_input.outlier_coverage = str2double(kpi_rep_input.OutlierCoverage.ExposureGrid.Min.Value) * 1e-2;\r","\r","kpi_input.overlay = bmmo_parse_kpi_overlay(kpi_rep_input.ExposureGrid);\r","\r","for ichuck = 1:2\r","    kpi_input.w2w.(['ovl_exp_grid_chk' num2str(ichuck) '_max_w2w_var']) =   str2double(kpi_rep_input.W2wVariation.ExposureGrid.Max.(chuckstr{ichuck})) * 1e-9;\r","\r","\r","    kpi_input.valid.(['ovl_exp_grid_chk' num2str(ichuck) '_nr_valids']) =    str2double(kpi_rep_input.DataPoints.ExposureGrid.Valids.(chuckstr{ichuck}));\r","    kpi_input.valid.(['ovl_exp_grid_chk' num2str(ichuck) '_nr_readout_nans']) =  str2double(kpi_rep_input.DataPoints.ExposureGrid.ReadoutNans.(chuckstr{ichuck}));\r","    kpi_input.valid.(['ovl_exp_grid_chk' num2str(ichuck) '_nr_invalids']) =  str2double(kpi_rep_input.DataPoints.ExposureGrid.Invalids.(chuckstr{ichuck}));\r","    kpi_input.valid.(['ovl_exp_grid_chk' num2str(ichuck) '_nr_outliers']) =  str2double(kpi_rep_input.DataPoints.ExposureGrid.Outliers.(chuckstr{ichuck}));\r","end\r","\r","\r",""],"CoverageData":{"CoveredLineNumbers":[17,19,21,23,24,27,28,29,30],"UnhitLineNumbers":[],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,2,0,2,0,2,4,0,0,4,4,4,4,0,0,0,0]}}