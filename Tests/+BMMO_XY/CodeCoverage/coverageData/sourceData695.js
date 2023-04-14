var sourceData695 = {"FileContents":["% Changelog\r","% 2015-11-16  SBPR  creation\r","% 2018-12-20  SELR  fixed options\r","% 2020-02-04  LUDU  updated and added new test with MI@M sign inv\r","% 2020-07-09  ANBZ  updated for KA@M Correction\r","% 2020-10-27  OGIE  fix option by adding options.intraf_actuation_order\r","\r","function test_suite = test_bmmo_process_output\r","suite = initTestSuite2016(localfunctions);\r","if nargout==0\r","    suite.run();\r","else\r","    test_suite = suite;\r","end\r","\r","% regression-only test with 87-field 2de input\r"," %MI@M = MI@E and KA@M OFF\r","function test_bmmo_process_output_case1 % ok<DEFNU>\r","\r","load([bmmo_testdata_root filesep 'TC_output_processing_in.mat']);\r","load([bmmo_testdata_root filesep 'TC_output_processing_out.mat']);\r","\r","model_results.outlier_stats = stats;\r","model_results.interfield_residual = model_results.BAO.interfield;\r","model_results.INTRAF.residual = model_results.INTRAF.intrafield;\r","model_results.MI.res = model_results.interfield_residual;\r","model_results.outlier_stats = sub_add_type(model_results.outlier_stats);\r","\r","model_results.INTRAF = rmfield(model_results.INTRAF, 'Calib_Kfactors');\r","tmp_options = bmmo_default_options_structure;\r","for chuck_id = 1:2\r","    [~, model_results.INTRAF.Calib_Kfactors(chuck_id)] = bmmo_fit_model(model_results.INTRAF.Calib_intra(chuck_id), tmp_options, '20par');\r","end\r","\r","options.WH.use_input_fp                  = 0;\r","options.WH.fp                            = [];\r","options.WH.use_raw                       = 0;\r","wh_fp = bmmo_construct_wh_fp(ml, options);\r","\r","model_results.WH.fp_per_chuck = bmmo_average_chuck(wh_fp, options);\r","tmp_options = bmmo_default_options_structure;\r","options.filter = tmp_options.filter;\r","options = bmmo_phase_2_options(options);\r","options = bmmo_wh_options(ml, options);\r","options.layer_fields = {1:87};\r","options.no_layer_to_use = 1;\r","options.bl3_model = 0;\r","options.susd_control = 0;\r","options.invert_MI_wsm_sign = 0;\r","options.KA_control = 0;\r","options.KA_measure_enabled = 0;\r","options.IFO_scan_direction = [-1 1 -1 1];\r","options.model_shift = tmp_options.model_shift;\r","options.platform = tmp_options.platform;\r","options.FIWA_mark_locations = tmp_options.FIWA_mark_locations;\r","options = bmmo_options_intraf(options,3);\r","options.KA_meas_start = tmp_options.KA_meas_start;\r","\r","mr = bmmo_default_model_result(ml, options);\r","model_results.sub_model_input = mr.sub_model_input;\r","model_results.KA.Calib_KA_meas = mr.KA.Calib_KA_meas;\r","\r","temp_out = bmmo_default_output_structure(options);\r","\r","% add filter coefficients\r","submodels = {'WH', 'MI', 'KA', 'INTRAF', 'BAO'};\r","for isub = 1:length(submodels)\r","    options.filter_coefficients.(submodels{isub}) = 1;\r","end\r","\r","options.previous_correction.SUSD = temp_out.corr.SUSD;\r","out.corr.SUSD = temp_out.corr.SUSD;\r","model_results.SUSD.Monitor_SUSD = model_results.SUSD.Calib_SUSD;\r","options.previous_correction.KA.grid_2dc = temp_out.corr.KA.grid_2dc;\r","out.corr.KA.grid_2dc = temp_out.corr.KA.grid_2dc;\r","\r","% add new flags\r","options.undo_before_modelling = false; \r","options.parlist = bmmo_parlist;\r","options.intraf_resample_options = tmp_options.intraf_resample_options;\r","options.KA_actuation = tmp_options.KA_actuation;\r","options.ERO = tmp_options.ERO;\r","\r","model_results = sub_update_model_results(model_results);\r","\r","options.KA_actuation = tmp_options.KA_actuation;\r","options.intraf_actuation = tmp_options.intraf_actuation;\r","\r","test_out = bmmo_process_output(ml, model_results, options);\r","\r","% subtract previous correction from test_out\r","% (time filtering is not taken into account for test output data)\r","fn = fieldnames(test_out.corr.BAO);\r","for ic = 1:2\r","    for ifield = 1:length(fn)\r","        test_out.corr.BAO(ic).(fn{ifield}) = test_out.corr.BAO(ic).(fn{ifield}) - options.previous_correction.BAO(ic).(fn{ifield});\r","    end\r","end\r","\r","bmmo_assert_equal(test_out.corr.IR2EUV, out.corr.IR2EUV);\r","bmmo_assert_equal(test_out.corr.BAO, out.corr.BAO);\r","bmmo_assert_equal(test_out.corr.MI, out.corr.MI);\r","bmmo_assert_equal(test_out.corr.KA, out.corr.KA);\r","bmmo_assert_equal(bmmo_ffp_to_ml_simple(test_out.corr.ffp), ovl_model(bmmo_ffp_to_ml_simple(out.corr.ffp), 'perwafer'));\r","\r","\r","% regression-only test with 87-field 2de input\r","%  MI@M = -MI@E and KA@M ON\r","function test_bmmo_process_output_case2 % ok<DEFNU>\r","\r","load([bmmo_testdata_root filesep 'TC_output_processing_in_1.mat']);\r","load([bmmo_testdata_root filesep 'TC_output_processing_out_1.mat']);\r","\r","model_results.outlier_stats = stats;\r","model_results.interfield_residual = model_results.BAO.interfield;\r","model_results.INTRAF.residual = model_results.INTRAF.intrafield;\r","model_results.MI.res = model_results.interfield_residual;\r","model_results.outlier_stats = sub_add_type(model_results.outlier_stats);\r","\r","model_results.INTRAF = rmfield(model_results.INTRAF, 'Calib_Kfactors');\r","tmp_options = bmmo_default_options_structure;\r","for chuck_id = 1:2\r","    [~, model_results.INTRAF.Calib_Kfactors(chuck_id)] = bmmo_fit_model(model_results.INTRAF.Calib_intra(chuck_id), tmp_options, '20par');\r","end\r","\r","options.WH.use_input_fp                  = 0;\r","options.WH.fp                            = [];\r","options.WH.use_raw                       = 0;\r","wh_fp = bmmo_construct_wh_fp(ml, options);\r","model_results.WH.fp_per_chuck = bmmo_average_chuck(wh_fp, options);\r","tmp_options = bmmo_default_options_structure;\r","options.filter = tmp_options.filter;\r","options.invert_MI_wsm_sign = tmp_options.invert_MI_wsm_sign; % 1\r","options.KA_control = 1;\r","options.KA_measure_enabled = 1; %1\r","options = bmmo_phase_2_options(options);\r","options = bmmo_wh_options(ml, options);\r","\r","options.layer_fields = {1:87};\r","options.bl3_model = 0;\r","options.no_layer_to_use = 1;\r","options.susd_control = 0;\r","options.IFO_scan_direction = [-1 1 -1 1];\r","options.model_shift = tmp_options.model_shift;\r","options.platform = tmp_options.platform;\r","options.KA_meas_start = tmp_options.KA_meas_start;\r","options = bmmo_options_intraf(options,3);\r","\r","mr = bmmo_default_model_result(ml, options);\r","model_results.sub_model_input = mr.sub_model_input;\r","\r","temp_out = bmmo_default_output_structure(options);\r","\r","% add filter coefficients\r","submodels = {'WH', 'MI', 'KA', 'INTRAF', 'BAO'};\r","for isub = 1:length(submodels)\r","    options.filter_coefficients.(submodels{isub}) = 1;\r","end\r","\r","options.previous_correction.SUSD = temp_out.corr.SUSD;\r","out.corr.SUSD = temp_out.corr.SUSD;\r","model_results.SUSD.Monitor_SUSD = model_results.SUSD.Calib_SUSD;\r","\r","model_results = sub_update_model_results(model_results);\r","% add new flags\r","options.undo_before_modelling = false; \r","options.parlist = bmmo_parlist;\r","options.intraf_resample_options = tmp_options.intraf_resample_options;\r","options.KA_actuation = tmp_options.KA_actuation;\r","options.intraf_actuation = tmp_options.intraf_actuation;\r","options.ERO = tmp_options.ERO;\r","test_out = bmmo_process_output(ml, model_results, options);\r","\r","% subtract previous correction from test_out\r","% (time filtering is not taken into account for test output data)\r","fn = fieldnames(test_out.corr.BAO);\r","for ic = 1:2\r","    for ifield = 1:length(fn)\r","        test_out.corr.BAO(ic).(fn{ifield}) = test_out.corr.BAO(ic).(fn{ifield}) - options.previous_correction.BAO(ic).(fn{ifield});\r","    end\r","end\r","\r","bmmo_assert_equal(test_out.corr.IR2EUV, out.corr.IR2EUV);\r","bmmo_assert_equal(test_out.corr.BAO, out.corr.BAO);\r","bmmo_assert_equal(test_out.corr.MI, out.corr.MI);\r","bmmo_assert_equal(test_out.corr.KA, out.corr.KA);\r","bmmo_assert_equal(bmmo_ffp_to_ml_simple(test_out.corr.ffp), ovl_model(bmmo_ffp_to_ml_simple(out.corr.ffp), 'perwafer'));\r","\r","\r","function stats_out = sub_add_type(stats_in)\r","\r","stats_out = stats_in;\r","for il = 1:length(stats_in.layer)\r","    for iw = 1:length(stats_in.layer(il).wafer)\r","        stats_out.layer(il).wafer(iw).type = ones(size(stats_in.layer(il).wafer(iw).x));\r","    end\r","end\r","\r","\r","function model_results = sub_update_model_results(model_results)\r","\r","model_results.KA.Calib_KA = sub_update_KA_model_result(model_results.KA.Calib_KA);\r","model_results.KA.Calib_KA_meas = sub_update_KA_model_result(model_results.KA.Calib_KA_meas);\r","\r","\r","function KA_grid = sub_update_KA_model_result(KA_corr)\r","\r","ka_grid1 = bmmo_KA_corr_to_grid(KA_corr(1));\r","ka_grid2 = bmmo_KA_corr_to_grid(KA_corr(2));\r","KA_grid = [ka_grid1 ka_grid2];\r","\r",""],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[9,10,11,12,13,20,21,23,24,25,26,27,29,30,31,32,35,36,37,38,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,59,60,61,63,66,67,68,71,72,73,74,75,78,79,80,81,82,84,86,87,89,93,94,95,96,100,101,102,103,104,111,112,114,115,116,117,118,120,121,122,123,126,127,128,129,130,131,132,133,134,135,136,137,139,140,141,142,143,144,145,146,147,149,150,152,155,156,157,160,161,162,164,166,167,168,169,170,171,172,176,177,178,179,183,184,185,186,187,192,193,194,195,202,203,208,209,210],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}