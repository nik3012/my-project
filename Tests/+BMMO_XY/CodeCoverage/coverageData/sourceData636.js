var sourceData636 = {"FileContents":["function test_suite = test_bmmo_construct_13x19_layout\r","suite = initTestSuite2016(localfunctions);\r","if nargout==0\r","    suite.run();\r","else\r","    test_suite = suite;\r","end\r","% Test Case 1: one-mark-many-fields\r","function test_bmmo_construct_13x19_layout_case_1\r","load([bmmo_testdata_root filesep 'TC08_01_in.mat']);\r","options = bmmo_default_options_structure;\r","mlo = bmmo_construct_layout_from_ml(ml, options);\r","for il = 1:length(mlo)\r","    assert(mlo(il).nmark == 247);\r","    assert(length(mlo(il).wd.xw) == mlo(il).nfield*247);\r","    assert(length(mlo(il).wd.yw) == length(mlo(il).wd.xw));\r","    xw_yw = mlo(il).wd.xw + 1i * mlo(il).wd.yw;\r","    assert(length(unique(xw_yw)) == length(xw_yw)); \r","end\r","    \r","assert(length(mlo) == 2);\r","ml2 = ovl_combine_fields(mlo(1), mlo(2));\r","assert(ml2.nfield == 89);\r","% % Test Case 2: 87x336 mark layout\r","% % DEPRECATED\r","% function test_bmmo_construct_13x19_layout_case_2\r","% \r","% load([bmmo_testdata_root filesep 'TC_YS_data.mat']);\r","% \r","% mlo = bmmo_construct_13x19_layout(ml);\r","% \r","% assert(mlo.nmark == 247);\r","% assert(length(mlo.wd.xw) == mlo.nfield*247);\r","% assert(length(mlo.wd.yw) == mlo.nfield*247);\r","% \r","% xw_yw = mlo.wd.xw + i * mlo.wd.yw;\r","% assert(length(unique(xw_yw)) == length(xw_yw)); \r","% Test Case 3: 89-field 13x19 layout: layout should be unchanged\r","% after layer recombination\r","function test_bmmo_construct_13x19_layout_case_3\r","load([bmmo_testdata_root filesep 'TC08_01_out.mat']);\r","out.info.report_data = [];\r","out.info.previous_correction = [];\r","options = bmmo_default_options_structure;\r","mlo = bmmo_construct_layout_from_ml(out, options);\r","ml2 = ovl_combine_fields(mlo(1), mlo(2));\r","bmmo_assert_equal(ml2.wd, out.wd);"],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[2,3,4,5,6,10,11,12,13,14,15,16,17,18,21,22,23,41,42,43,44,45,46,47],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}