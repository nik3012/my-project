var sourceData713 = {"FileContents":["function test_suite = test_bmmo_wh_options\r","suite = initTestSuite2016(localfunctions);\r","if nargout==0\r","    suite.run();\r","else\r","    test_suite = suite;\r","end\r","\r","\r","function test_bmmo_wh_options_case1\r","\r","load([bmmo_testdata_root filesep 'bmmo_2_layer_data.mat']);\r","load([bmmo_testdata_root filesep 'TC09_01_in.mat']);\r","mli.raw = mlraw;\r","mli = bmmo_phase_2_input(mli);\r","options = bmmo_default_options_structure;\r","options.intrafield_reticle_layout = options.reduced_reticle_layout;\r","\r","options.mark_type = 'unknown';\r","options = bmmo_ml_options(mli, options);\r","\r","% Temporary fix for k factor mapping\r","for iw = 1:6\r","    options.WH_K_factors.wafer(iw).field(90:174) = options.WH_K_factors.wafer(iw).field(1:85);\r","end\r","\r","% convert k-factors to new format\r","options.WH_K_factors = bmmo_k_factors_to_xml(options.WH_K_factors, 6, 174);\r","\r","options = bmmo_wh_options(mli, options);\r","% options.WH.raw = rmfield(options.WH.raw, 'expinfo');\r","% \r","% assert(logical(options.WH.use_raw));\r","% bmmo_assert_equal(mlo, options.WH.raw)"],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[2,3,4,5,6,12,13,14,15,16,17,19,20,23,24,28,30],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}