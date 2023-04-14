var sourceData677 = {"FileContents":["function test_suite = test_bmmo_kpi_patch\r","\r","suite = initTestSuite2016(localfunctions);\r","if nargout==0\r","    suite.run();\r","else\r","    test_suite = suite;\r","end\r","\r","% test the model uses old ir2euv for decorrection, and new ir2euv for\r","% correction\r","function test_bmmo_p334968\r","\r","input_struct = bmmo_default_input;\r","[mlp, options] = bmmo_process_input(input_struct);\r","\r","% set wh fp to 1\r","for iw = 1:mlp.nwafer\r","    options.WH.fp.layer.wr(iw).dx = 1e-9 * ones(size(options.WH.fp.layer.wr(iw).dx));\r","end\r","options.WH.input_fp_per_chuck = bmmo_average_chuck(options.WH.fp, options);\r","\r","options.previous_correction.IR2EUV = -1;\r","options.IR2EUVsensitivity = 1;\r","\r","model_results = bmmo_run_submodels(mlp, options);\r","\r","model_results.WH.Calib_WH = 5;\r","\r","out = bmmo_process_output(input_struct, model_results, options);\r","\r","bmmo_assert_equal(out.report.KPI.uncontrolled.waferheating.ovl_exp_grid_dx_whc_uncontrolled, 1e-9);\r","bmmo_assert_equal(out.report.KPI.correction.total_unfiltered.total.ovl_chk1_997_x, 6e-9);\r","\r","% test that the model uses input layout for calculating KPI correction\r","% statistics\r","function test_bmmo_p334971\r","\r","input_struct = bmmo_default_input;\r","[mlp, options] = bmmo_process_input(input_struct);\r","\r","out = bmmo_default_output_structure(options);\r","\r","fp = bmmo_INTRAF_SBC_fingerprint(mlp, out.corr.ffp, options);\r","\r","for iw = 1:mlp.nwafer\r","   assert(all(~isnan(mlp.layer.wr(iw).dx) | isnan(fp.layer.wr(iw).dx)));\r","   assert(all(~isnan(fp.layer.wr(iw).dx) | isnan(mlp.layer.wr(iw).dx)));\r","   assert(all(~isnan(mlp.layer.wr(iw).dy) | isnan(fp.layer.wr(iw).dy)));\r","   assert(all(~isnan(fp.layer.wr(iw).dy) | isnan(mlp.layer.wr(iw).dy)));\r","end\r","\r","% test that the mi kpi stats are calculated on absolute values\r","function test_bmmo_p334973\r","\r","input_struct = bmmo_default_input;\r","[mlp, options] = bmmo_process_input(input_struct);\r","model_results = bmmo_run_submodels(mlp, options);\r","\r","% ensure negative mi map\r","for ic = 1:2\r","    model_results.MI.Calib_MI(ic).x_mirr.dx = 1e-9 * ones(size(model_results.MI.Calib_MI(ic).x_mirr.dx));\r","    model_results.MI.Calib_MI(ic).y_mirr.dy = 1e-9 * ones(size(model_results.MI.Calib_MI(ic).y_mirr.dy));\r","end\r","\r","out = bmmo_process_output(input_struct, model_results, options);\r","\r","bmmo_assert_equal(out.report.KPI.correction.total_unfiltered.mirror.exp.ovl_exp_xty_997_full_chk1, 1e-9);\r","bmmo_assert_equal(out.report.KPI.correction.total_unfiltered.mirror.exp.ovl_exp_ytx_997_full_chk1, 1e-9);\r","bmmo_assert_equal(out.report.KPI.correction.total_unfiltered.mirror.exp.ovl_exp_xty_997_full_chk2, 1e-9);\r","bmmo_assert_equal(out.report.KPI.correction.total_unfiltered.mirror.exp.ovl_exp_ytx_997_full_chk2, 1e-9);\r","\r",""],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[3,4,5,6,7,14,15,18,19,21,23,24,26,28,30,32,33,39,40,42,44,46,47,48,49,50,56,57,58,61,62,63,66,68,69,70,71],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}