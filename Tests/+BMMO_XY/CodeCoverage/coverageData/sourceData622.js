var sourceData622 = {"FileContents":["% Changelog\r","% 2015-06-30  SELR  creation from test_bmmo_nxe_drift_control_model\r","% 2020-11-24  ANBZ  added a test case for MIKA 1L with NCE removal \r"," \r","function test_suite = test_bl3_nxe_drift_control_model    %#ok<STOUT>\r","suite = initTestSuite2016(localfunctions);\r","if nargout==0\r","    suite.run();\r","else\r","    test_suite = suite;\r","end\r","    \r","\r","\r","% Only KA ON scenarios, only difference with BMMO currently\r","%% 1L - SUSD OFF - KA ON\r","function test_bl3_1L_largeSUSD_MIKA % ok<DEFNU>\r","\r","load([bmmo_testdata_root filesep 'test_bl3_nxe_drift_control_model_1']);\r","mli.info.previous_correction.KA.grid_2dc = bmmo_KA_corr_subset(mli.info.previous_correction.KA.grid_2dc);\r","\r","ml = bmmo_turn_off_l2(mli);\r","ml.info.configuration_data.KA_correction_enabled = 1;\r","ml.info.configuration_data.susd_correction_enabled = 0;\r","ml.info.report_data.cet_residual = bmmo_empty_cet_residual(ml);\r","test_out = bmmo_nxe_drift_control_model(ml);\r","\r","[test_out, test_out_k_factors] = bmmo_remove_k_factors_from_output(test_out);\r","[SUSDOFF_KAON_1L, SUSDOFF_KAON_1L_k_factors] = bmmo_remove_k_factors_from_output(SUSDOFF_KAON_1L);\r","bmmo_assert_equal(test_out,SUSDOFF_KAON_1L, 5e-13);\r","bmmo_assert_kfactor_equal(test_out_k_factors, SUSDOFF_KAON_1L_k_factors, sub_get_intraf_act_order(test_out.report.KPI));\r","\r","\r","\r","\r","%% 1L - SUSD ON - KA ON\r","function test_bl3_1L_largeSUSD_susd_control_enabled_MIKA % ok<DEFNU>\r","\r","load([bmmo_testdata_root filesep 'test_bl3_nxe_drift_control_model_1']);\r","mli.info.previous_correction.KA.grid_2dc = bmmo_KA_corr_subset(mli.info.previous_correction.KA.grid_2dc);\r","ml = bmmo_turn_off_l2(mli);\r","ml.info.configuration_data.susd_correction_enabled = 1;\r","ml.info.configuration_data.KA_correction_enabled = 1;\r","ml.info.report_data.cet_residual = bmmo_empty_cet_residual(ml);\r","test_out = bmmo_nxe_drift_control_model(ml);\r","\r","[test_out, test_out_k_factors] = bmmo_remove_k_factors_from_output(test_out);\r","[SUSDON_KAON_1L, SUSDON_KAON_1L_k_factors] = bmmo_remove_k_factors_from_output(SUSDON_KAON_1L);\r","bmmo_assert_equal(test_out,SUSDON_KAON_1L, 5e-13);\r","bmmo_assert_kfactor_equal(test_out_k_factors, SUSDON_KAON_1L_k_factors, sub_get_intraf_act_order(test_out.report.KPI));\r","\r","\r","\r","\r","%% 2L - SUSD OFF - KA ON\r","function test_bl3_2L_largeSUSD_MIKA % ok<DEFNU>\r","\r","load([bmmo_testdata_root filesep 'test_bl3_nxe_drift_control_model_1']);\r","mli.info.previous_correction.KA.grid_2dc = bmmo_KA_corr_subset(mli.info.previous_correction.KA.grid_2dc);\r","ml = mli;\r","ml.info.configuration_data.KA_correction_enabled = 1;\r","ml.info.configuration_data.susd_correction_enabled = 0;\r","ml.info.report_data.cet_residual = bmmo_empty_cet_residual(ml);\r","test_out = bmmo_nxe_drift_control_model(ml);\r","\r","[test_out, test_out_k_factors] = bmmo_remove_k_factors_from_output(test_out);\r","[SUSDOFF_KAON_2L, SUSDOFF_KAON_2L_k_factors] = bmmo_remove_k_factors_from_output(SUSDOFF_KAON_2L);\r","bmmo_assert_equal(test_out,SUSDOFF_KAON_2L, 5e-13);\r","bmmo_assert_kfactor_equal(test_out_k_factors, SUSDOFF_KAON_2L_k_factors, sub_get_intraf_act_order(test_out.report.KPI));\r","\r","\r","%% 2L - SUSD ON - KA ON\r","function test_bl3_2L_largeSUSD_susd_control_enabled_MIKA % ok<DEFNU>\r","\r","load([bmmo_testdata_root filesep 'test_bl3_nxe_drift_control_model_1']);\r","mli.info.previous_correction.KA.grid_2dc = bmmo_KA_corr_subset(mli.info.previous_correction.KA.grid_2dc);\r","ml = mli;\r","ml.info.configuration_data.susd_correction_enabled = 1;\r","ml.info.configuration_data.KA_correction_enabled = 1;\r","ml.info.report_data.cet_residual = bmmo_empty_cet_residual(ml);\r","test_out = bmmo_nxe_drift_control_model(ml);\r","\r","[test_out, test_out_k_factors] = bmmo_remove_k_factors_from_output(test_out);\r","[SUSDON_KAON_2L, SUSDON_KAON_2L_k_factors] = bmmo_remove_k_factors_from_output(SUSDON_KAON_2L);\r","bmmo_assert_equal(test_out,SUSDON_KAON_2L, 5e-13);\r","bmmo_assert_kfactor_equal(test_out_k_factors, SUSDON_KAON_2L_k_factors, sub_get_intraf_act_order(test_out.report.KPI));\r","\r","\r","%% 1L - SUSD ON - KA ON (with NCE interpolation & removal, use ADElwfrgrid KA NCE)\r","function test_bl3_1L_largeSUSD_susd_control_enabled_MIKA_NCE % ok<DEFNU>\r","\r","load([bmmo_testdata_root filesep 'test_bl3_nxe_drift_control_model_1']);\r","ml = mli_nce;\r","ml.info.configuration_data.susd_correction_enabled = 1;\r","ml.info.configuration_data.KA_correction_enabled = 1;\r","test_out = bmmo_nxe_drift_control_model(ml);\r","\r","[test_out, test_out_k_factors] = bmmo_remove_k_factors_from_output(test_out);\r","[SUSDON_KAON_1L_NCE, SUSDON_KAON_1L_NCE_k_factors] = bmmo_remove_k_factors_from_output(SUSDON_KAON_1L_NCE);\r","bmmo_assert_equal(test_out,SUSDON_KAON_1L_NCE, 5e-13);\r","bmmo_assert_kfactor_equal(test_out_k_factors, SUSDON_KAON_1L_NCE_k_factors, sub_get_intraf_act_order(test_out.report.KPI));\r","\r","\r","%% Get actuation order for bmmo_assert_kfactor_equal\r","function intraf_actuation_order = sub_get_intraf_act_order(kpi_struct)\r","% Determine actuation order of the KPI structure\r","if isfield(kpi_struct, 'Intra_33par_NCE')\r","    intraf_actuation_order  = 5;\r","else\r","    intraf_actuation_order  = 3;\r","end"],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[6,7,8,9,10,19,20,22,23,24,25,26,28,29,30,31,39,40,41,42,43,44,45,47,48,49,50,58,59,60,61,62,63,64,66,67,68,69,75,76,77,78,79,80,81,83,84,85,86,92,93,94,95,96,98,99,100,101,107,108,109,110],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}