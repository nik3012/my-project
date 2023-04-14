var sourceData706 = {"FileContents":["function test_suite = test_bmmo_save_wfrdatamaps    %#ok<STOUT>\r","suite = initTestSuite2016(localfunctions);\r","if nargout==0\r","    suite.run();\r","else\r","    test_suite = suite;\r","end\r","\r","\r","function setup_data = setup\r","load([bmmo_testdata_root filesep 'input_large_SUSD_drift.mat'], 'input_struct');\r","setup_data.mli = input_struct;\r","setup_data.tmp_dir = [tempname '_BMMO_WDMS'];\r","mkdir(setup_data.tmp_dir);\r","setup_data.mli.diagnostics_path = setup_data.tmp_dir;\r","\r","\r","function teardown(setup_data)\r","cleanupTempDir = onCleanup(@()rmdir(setup_data.tmp_dir, 's'));\r","\r","\r","% Regression tests for every possible waferdatamap\r","function test_default_configuration(setup_data)\r","setup_data.mli.info.configuration_data.invert_MI_wsm_sign = 0;\r","setup_data.mli.info.configuration_data.KA_measure_enabled = 0;\r","bmmo_nxe_drift_control_model(setup_data.mli);\r","wdm_2L_default = [bmmo_testdata_root filesep 'Wfrdatamaps' filesep  '2L_default'];\r","sub_compare_mat_files(wdm_2L_default, setup_data.tmp_dir)\r","\r","\r","function test_2L_SUSD_KA_on(setup_data)\r","setup_data.mli.info.configuration_data.KA_correction_enabled = 1;\r","setup_data.mli.info.configuration_data.susd_correction_enabled = 1;\r","setup_data.mli.info.configuration_data.invert_MI_wsm_sign = 0;\r","setup_data.mli.info.configuration_data.KA_measure_enabled = 0;\r","bmmo_nxe_drift_control_model(setup_data.mli);\r","wdm_2L_SUSD_KA = [bmmo_testdata_root filesep 'Wfrdatamaps' filesep '2L_SUSD_KA'];\r","sub_compare_mat_files(wdm_2L_SUSD_KA, setup_data.tmp_dir)\r","\r","\r","function test_1L_SUSD_on_KA_on(setup_data)\r","mli_1L = bmmo_turn_off_l2(setup_data.mli);\r","mli_1L.info.configuration_data.KA_correction_enabled = 1;\r","mli_1L.info.configuration_data.susd_correction_enabled = 1;\r","mli_1L.info.configuration_data.invert_MI_wsm_sign = 0;\r","mli_1L.info.configuration_data.KA_measure_enabled = 0;\r","bmmo_nxe_drift_control_model(mli_1L);\r","wdm_1L_SUSD_KA = [bmmo_testdata_root filesep 'Wfrdatamaps' filesep '1L_SUSD_KA'];\r","sub_compare_mat_files(wdm_1L_SUSD_KA, setup_data.tmp_dir)\r","\r","\r","function test_default_configuration_MI_M_sign_inv(setup_data)\r","setup_data.mli.info.configuration_data.invert_MI_wsm_sign = 1;\r","setup_data.mli.info.configuration_data.KA_measure_enabled = 0;\r","bmmo_nxe_drift_control_model(setup_data.mli);\r","wdm_2L_default_MI_sign_inv = [bmmo_testdata_root filesep 'Wfrdatamaps' filesep  '2L_default_MI_sign_inv'];\r","sub_compare_mat_files(wdm_2L_default_MI_sign_inv, setup_data.tmp_dir)\r","\r","\r","function test_2L_SUSD_KA_on_KA_M(setup_data)\r","setup_data.mli.info.configuration_data.KA_correction_enabled = 1;\r","setup_data.mli.info.configuration_data.susd_correction_enabled = 1;\r","setup_data.mli.info.configuration_data.invert_MI_wsm_sign = 0;\r","setup_data.mli.info.configuration_data.KA_measure_enabled = 1;\r","bmmo_nxe_drift_control_model(setup_data.mli);\r","wdm_2L_SUSD_KA_KA_Meas = [bmmo_testdata_root filesep 'Wfrdatamaps' filesep '2L_SUSD_KA_KA_Meas'];\r","sub_compare_mat_files(wdm_2L_SUSD_KA_KA_Meas, setup_data.tmp_dir)\r","\r","\r","function sub_compare_mat_files(dir1, dir2)\r","list = dir(dir1);\r","allfiles = {list.name};\r","allfiles = allfiles(~isnan(cell2num(strfind(allfiles, '.mat'))));\r","\r","for ifile = 1:length(allfiles)\r","    file_name = allfiles{ifile};\r","    dir1_file = load([dir1 filesep file_name]);\r","    dir2_file = load([dir2 filesep file_name]);\r","    bmmo_assert_equal(dir1_file, dir2_file)\r","end"],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[2,3,4,5,6,11,12,13,14,15,19,24,25,26,27,28,32,33,34,35,36,37,38,42,43,44,45,46,47,48,49,53,54,55,56,57,61,62,63,64,65,66,67,71,72,73,75,76,77,78,79],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}