var sourceData644 = {"FileContents":["%% history\r","%   2015-07-03  JIMI    creation\r","%   2018-11-30  SELR    added test_input_validation\r","%   2020-02-04  LUDU    added test_TC07_02\r","%   2020-07-09  ANBZ    updated test for KA@M ff 6 par\r","\r","\r","function test_suite = test_bmmo_ff_bao_correction\r","suite = initTestSuite2016(localfunctions);\r","if nargout==0\r","    suite.run();\r","else\r","    test_suite = suite;\r","end\r","\r","\r","function test_TC07_01  % ok<DEFNU>\r","% MI@M = MI@E and KA@M OFF\r","% addpath('C:\\Localdata\\DE_Metro\\DE-FC-065-E\\DE-FC-065-E-GDC\\sandbox\\testUtilities');\r","load([bmmo_testdata_root filesep 'TC07_01_in.mat']);  % BAO, Intra, WH combined input\r","load([bmmo_testdata_root filesep 'TC07_01_out.mat']);\r","\r","for ichk = 1:2\r","    test_out_pars_6(ichk) = bmmo_ff_bao_correction(MI_map(ichk), KA_map(ichk), options);   \r","end\r","bmmo_assert_equal(test_out_pars_6, out_pars_6, 0.5*1e-2*1e-9);\r","\r","\r","function test_TC07_02  % ok<DEFNU>\r","% MI@M = -MI@E and KA@M ON\r","% addpath('C:\\Localdata\\DE_Metro\\DE-FC-065-E\\DE-FC-065-E-GDC\\sandbox\\testUtilities');\r","load([bmmo_testdata_root filesep 'TC07_02_in.mat']);  % BAO, Intra, WH combined input\r","load([bmmo_testdata_root filesep 'TC07_02_out.mat']);\r","\r","for ichk = 1:2\r","    [test_out_pars_6_MI(ichk), test_out_pars_6_KA(ichk)] = bmmo_ff_bao_correction(MI_map(ichk), KA_map(ichk), options);\r","    test_out_pars_6(ichk) = bmmo_add_BAOs(test_out_pars_6_MI(ichk), test_out_pars_6_KA(ichk));    \r","end\r","bmmo_assert_equal(test_out_pars_6, out_pars_6, 0.5*1e-2*1e-9);\r","\r","\r","function test_input_validation\r","load([bmmo_testdata_root filesep 'TC07_01_in.mat']);  % BAO, Intra, WH combined input\r","options.FIWA_mark_locations.x = [];\r","\r","try\r","   bmmo_ff_bao_correction(MI_map(1), KA_map(1), options);\r","catch ME\r","    if strcmp(ME.message, 'options.FIWA_mark_locations structure incomplete or missing')\r","        assert(true)\r","    else\r","        rethrow(ME);\r","    end\r","end"],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[9,10,11,12,13,20,21,23,24,26,32,33,35,36,37,39,43,44,46,47,48,49,50,51,52],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}