var sourceData487 = {"FileContents":["function [sbc2, sbc2ref] = bmmo_kt_compare_LCP_sbc_with_injected(ADEL_monitor_sbc, ml_zero)\r","% function [sbc2, sbc2ref] = bmmo_kt_compare_LCP_sbc_with_injected(ADEL_monitor_sbc, ml_zero)\r","% <help_update_needed>\r","%\r","% <short description>\r","% input:\r","% output:\r","%\r","%\r","if nargin < 2\r","    % create a dummy layout with full coverage, for constructing fingerprints\r","    ml_zero = ovl_create_dummy('marklayout','BA-XY-DYNA-13X19','nwafer',6,'nlayer',1,'inner_rad',144);\r","end\r","\r","%read in the xml SBC2 ADEL recipe \r","disp('reading ADEL SBC2 from LCP');\r","sbc2 = bmmo_kt_process_SBC2(ADEL_monitor_sbc);\r","\r","% read in the injected SBC2\r","disp('reading injected data');\r","sbc2ref = bmmo_kt_get_injected_corr;\r","\r","%%Produce plotting required to compare the two SBC2 correction sets\r","disp('producing fingerprint plots');\r","%\r","bmmo_kt_compare_sbc_corrections(sbc2, sbc2ref, 'LCP generated SBC2', 'Injected SBC2', 1); \r","\r","bmmo_kt_compare_WH_total_fp(ml_zero,  sbc2ref, sbc2, 'Injected SBC2', 'LCP SBC2');\r","\r","end"],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[10,12,16,17,20,21,24,26,28],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}