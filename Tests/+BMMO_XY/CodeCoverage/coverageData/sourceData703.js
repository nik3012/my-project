var sourceData703 = {"FileContents":["%% history \r","%   2015-10-09  JIMI creation\r","%   2020-10-23  OGIE add the options argument to function call\r","%   2021-03-19  OGIE add TC18_02, rename datafiles\r","\r","function test_suite = test_bmmo_repair_intrafield_nans\r","suite = initTestSuite2016(localfunctions);\r","if nargout==0\r","    suite.run();\r","else\r","    test_suite = suite;\r","end\r","\r","function test_TC18_01  % ok<DEFNU>\r","% addpath('C:\\Localdata\\DE_Metro\\DE-FC-065-E\\DE-FC-065-E-GDC\\sandbox\\testUtilities');\r","load([bmmo_testdata_root filesep 'bmmo_repair_intrafield_nans_in.mat']);\r","load([bmmo_testdata_root filesep 'bmmo_repair_intrafield_nans_out_1.mat']);\r","\r","options = bmmo_default_options_structure;\r","\r","t_mlo = bmmo_repair_intrafield_nans (mli,options);\r","\r","bmmo_assert_equal(mlo, t_mlo)\r","\r","function test_TC18_02  % ok<DEFNU>\r","load([bmmo_testdata_root filesep 'bmmo_repair_intrafield_nans_in.mat']);\r","load([bmmo_testdata_root filesep 'bmmo_repair_intrafield_nans_out_2.mat']);\r","\r","options = bl3_default_options_structure;\r","\r","t_mlo = bmmo_repair_intrafield_nans(mli,options);\r","\r","bmmo_assert_equal(mlo, t_mlo)"],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[7,8,9,10,11,16,17,19,21,23,26,27,29,31,33],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}