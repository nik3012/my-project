var sourceData699 = {"FileContents":["function test_suite = test_bmmo_read_lcp_zip\r","suite = initTestSuite2016(localfunctions);\r","if nargout==0\r","    suite.run();\r","else\r","    test_suite = suite;\r","end\r","\r","\r","% regression-only test for reading OTAS SBC2\r","% zip_files without the IR2EUVscalingsensitivity\r","% Input: Intel SBC2, 2 wafers, Recover job, 2L Exp, 2L Readout\r","function test_sbc2_default_2wafersn_wo_ir2euvsens % ok<DEFNU>\r","\r","load([bmmo_testdata_root filesep 'TC01_input_zips' filesep 'TC01_Intel_SBC2_out_3_no_ir2euvsens_1']);\r","\r","zip_path = [bmmo_testdata_root filesep 'TC01_input_zips' filesep 'TC01_Intel_SBC2_no_ir2euvsens.zip'];\r","[~, test_in, ~, test_sbc_out, test_job_report, test_invalids] = evalc('bmmo_read_lcp_zip(zip_path)');\r","\r","bmmo_assert_equal(test_in, in);\r","bmmo_assert_equal(test_sbc_out, sbc_out);\r","bmmo_assert_equal(test_job_report.Header, job_report.Header);\r","bmmo_assert_equal(test_invalids, invalids);\r","\r","% regression-only test for reading OTAS and LIS SBC2a\r","%Input: 5 wafers, Adjustable Control, 2L Exp, 1L Readout\r","function test_compare_otas_lis_matlab % ok<DEFNU>\r","\r","load([bmmo_testdata_root filesep 'TC01_input_zips' filesep 'TC02_Alpha_test_5wafers_out_3_1.mat']);\r","\r","zip_path = [bmmo_testdata_root filesep 'TC01_input_zips' filesep 'TC02_Alpha_test_5wafers.zip'];\r","[~, test_in, ~, test_sbc_out, test_job_report, test_invalids] = evalc('bmmo_read_lcp_zip(zip_path)');\r","\r","bmmo_assert_equal(test_in, in);\r","bmmo_assert_equal(test_sbc_out, sbc_out);\r","bmmo_assert_equal(test_job_report.Header, job_report.Header);\r","bmmo_assert_equal(test_invalids, invalids);\r","\r","% assert LIS and OTAS BMMO inputs are same\r","zip_path_lis = [bmmo_testdata_root filesep 'TC01_input_zips' filesep 'TC02_Alpha_test_5wafers_LIS.zip'];\r","[~, test_in_lis] = evalc('bmmo_read_lcp_zip(zip_path_lis)');\r","\r","% remove WH time filter value from OTAS input since LIS omits it for 1L case\r","test_in.info.configuration_data.filter = rmfield(test_in.info.configuration_data.filter,'coeff_WH');\r","test_in.info.configuration_data = rmfield(test_in.info.configuration_data, 'platform');\r","test_in_lis.info.configuration_data = rmfield(test_in_lis.info.configuration_data, 'platform');\r","bmmo_assert_equal(test_in, test_in_lis);\r","\r","\r","% Test for reading LIS SBC2a\r","% Input: Intel SBC2a, 2 wafers, Default Control job, 1L Exp, 1L Readout\r","function test_lis_sbc2a % ok<DEFNU>\r","\r","load([bmmo_testdata_root filesep 'TC01_input_zips' filesep 'TC03_Intel_SBC2a_out_3_1.mat']);\r","\r","zip_path = [bmmo_testdata_root filesep 'TC01_input_zips' filesep 'TC03_Intel_SBC2a.zip'];\r","[~, test_in, ~, test_sbc_out, test_job_report, test_invalids] = evalc('bmmo_read_lcp_zip(zip_path)');\r","\r","bmmo_assert_equal(test_in, in);\r","bmmo_assert_equal(test_sbc_out, sbc_out);\r","bmmo_assert_equal(test_job_report.Header, job_report.Header);\r","bmmo_assert_equal(test_invalids, invalids);\r","\r","\r","% Test for reading m9739 zip\r","% Input:  2 wafers, 1L Readout (no configuration_data field)\r","function test_1L_readout_2wafers % ok<DEFNU>\r","\r","load([bmmo_testdata_root filesep 'TC01_input_zips' filesep 'no_config_zip' filesep 'TC04_m9739_out_3_1']);\r","\r","zip_path = [bmmo_testdata_root filesep 'TC01_input_zips' filesep 'no_config_zip' filesep 'TC04_BMMO-NXE_9739.zip'];\r","[~, test_in, ~, test_sbc_out, test_job_report, test_invalids] = evalc('bmmo_read_lcp_zip(zip_path)');\r","\r","bmmo_assert_equal(test_in, in);\r","bmmo_assert_equal(test_sbc_out, sbc_out);\r","bmmo_assert_equal(test_job_report.Header, job_report.Header);\r","bmmo_assert_equal(test_invalids, invalids);\r","\r","\r","% regression-only test for reading\r","% Input: 4 wafers, 1L, recover job\r","function test_1L_readout_4wafers_recover % ok<DEFNU>\r","\r","load([bmmo_testdata_root filesep 'TC01_input_zips' filesep 'no_config_zip' filesep 'TC05_mBK85_out_3_1']);\r","\r","zip_path = [bmmo_testdata_root filesep 'TC01_input_zips' filesep 'no_config_zip' filesep 'TC05_BMMO-NXE_BK85'];\r","[~, test_in, ~, test_sbc_out, test_job_report, test_invalids] = evalc('bmmo_read_lcp_zip(zip_path)');\r","\r","bmmo_assert_equal(test_in, in);\r","bmmo_assert_equal(test_sbc_out, sbc_out);\r","bmmo_assert_equal(test_job_report.Header, job_report.Header);\r","bmmo_assert_equal(test_invalids, invalids);\r",""],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[2,3,4,5,6,15,17,18,20,21,22,23,29,31,32,34,35,36,37,40,41,44,45,46,47,54,56,57,59,60,61,62,69,71,72,74,75,76,77,84,86,87,89,90,91,92],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}