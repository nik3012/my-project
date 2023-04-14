var sourceData649 = {"FileContents":["% Changelog\r","% 2015-07-03  JIMI  creation\r","% 2018-12-10  SELR  added setup_options, fixed reticle layout\r","\r","\r","function test_suite = test_bmmo_fit_fingerprints\r","suite = initTestSuite2016(localfunctions);\r","if nargout==0\r","    suite.run();\r","else\r","    test_suite = suite;\r","end\r","\r","\r","function test_bmmo_fit_fingerprints_oulier_removal\r","\r","load([bmmo_testdata_root filesep 'construct_FPS.mat']);\r","load([bmmo_testdata_root filesep 'fit_fingerprints.mat']);\r","\r","wafer = 1;\r","options2 = options;\r","options2.chuck_usage.chuck_id = options2.chuck_usage.chuck_id(wafer);\r","options2.chuck_usage.chuck_id_used = options2.chuck_usage.chuck_id;\r","options2.chuck_usage.nr_chuck_used = 1;\r","\r","[test_coefficients_c1, test_fps_fit_c1, test_ml_res_c1] = bmmo_fit_fingerprints(mli_drift, FPS, options2, C);\r","bmmo_assert_equal(test_coefficients_c1, coefficients_c1)\r","bmmo_assert_equal(test_ml_res_c1, ml_res_c1)\r","bmmo_assert_equal(test_fps_fit_c1, fps_fit_c1)\r","\r","wafer = 2;\r","options3 = options;\r","options3.chuck_usage.chuck_id = options3.chuck_usage.chuck_id(wafer);\r","options3.chuck_usage.chuck_id_used = options3.chuck_usage.chuck_id;\r","options3.chuck_usage.nr_chuck_used = 1;\r","\r","[test_coefficients_c2, test_fps_fit_c2, test_ml_res_c2] = bmmo_fit_fingerprints(mli_drift, FPS, options3, C);\r","\r","bmmo_assert_equal(test_coefficients_c2, coefficients_c2)\r","bmmo_assert_equal(test_ml_res_c2, ml_res_c2)\r","bmmo_assert_equal(test_fps_fit_c2, fps_fit_c2)\r","\r","function test_bmmo_fit_fingerprints_combined_model\r","\r","load([bmmo_testdata_root filesep 'construct_FPS.mat']);\r","load([bmmo_testdata_root filesep 'fit_fingerprints.mat']);\r","\r","\r","[test_coefficients, test_fps_fit, test_ml_res] = bmmo_combined_model(mli_drift, FPS, options, C);\r","bmmo_assert_equal(test_coefficients, coefficients)\r","bmmo_assert_equal(test_ml_res, ml_res)\r","bmmo_assert_equal(test_fps_fit, fps_fit)\r",""],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[7,8,9,10,11,17,18,20,21,22,23,24,26,27,28,29,31,32,33,34,35,37,39,40,41,45,46,49,50,51,52],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}