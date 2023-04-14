var sourceData674 = {"FileContents":["function test_suite = test_bmmo_invalid_input\r","suite = initTestSuite2016(localfunctions);\r","if nargout==0\r","    suite.run();\r","else\r","    test_suite = suite;\r","end\r","\r","%All marks NaN on one wafer\r","function test_bmmo_one_invalid_wafer\r","\r","ml = bmmo_default_input;\r","ml = bmmo_add_random_noise(ml);\r","\r","for iw = 1:ml.nwafer\r","   mlt = sub_set_wafers_nan(ml, iw); \r","   out = bmmo_nxe_drift_control_model(mlt);  \r","   %disp(['Outlier coverage: ', num2str(out.report.KPI.input.outlier_coverage)]);\r","\r","end\r","\r","\r","%All marks NaN on one wafer per chuck\r","function test_bmmo_one_invalid_per_chuck\r","\r","ml = bmmo_default_input;\r","ml = bmmo_add_random_noise(ml);\r","\r","% generate permutations of chuck wafers\r","c1 = [1 3 5];\r","c2 = [2 4 6];\r","[c1g, c2g] = meshgrid(c1, c2);\r","w_perm = [c1g(:) c2g(:)];\r","\r","for iw = 1:size(w_perm, 1)\r","    mlt = sub_set_wafers_nan(ml, w_perm(iw, :));    \r","    out = bmmo_nxe_drift_control_model(mlt);\r","    %disp(['Outlier coverage: ', num2str(out.report.KPI.input.outlier_coverage)]);\r","\r","end\r","\r","\r","% Two wafers NaN on a chuck\r","function test_bmmo_two_invalid_on_chuck\r","\r","ml = bmmo_default_input;\r","ml = bmmo_add_random_noise(ml);\r","\r","% generate permutations of 2 wafers on a single chuck \r","c1 = combnk([1 3 5], 2);\r","c2 = combnk([2 4 6], 2);\r","w_perm = [c1; c2];\r","\r","for iw = 1:size(w_perm, 1)\r","    mlt = sub_set_wafers_nan(ml, w_perm(iw, :));    \r","    out = bmmo_nxe_drift_control_model(mlt);\r","    %disp(['Outlier coverage: ', num2str(out.report.KPI.input.outlier_coverage)]);\r","\r","end\r","\r","% Two wafers NaN on two chucks\r","function test_bmmo_two_invalid_both_chuck\r","\r","ml = bmmo_default_input;\r","ml = bmmo_add_random_noise(ml);\r","\r","% generate permutations of 2 wafers on two chucks \r","p = combnk([1 3 5], 2);\r","q = combnk([2 4 6], 2);\r","[t1, t2] = meshgrid(1:3, 1:3);\r","t = [t1(:) t2(:)];\r","w_perm = [p(t(:,1), :) q(t(:,2), :)];\r","\r","for iw = 1:size(w_perm, 1)\r","    mlt = sub_set_wafers_nan(ml, w_perm(iw, :));    \r","    out = bmmo_nxe_drift_control_model(mlt);\r","    %disp(['Outlier coverage: ', num2str(out.report.KPI.input.outlier_coverage)]);\r","\r","end\r","\r","% % All wafers NaN on one chuck\r","% function test_bmmo_all_invalid_on_chuck\r","% \r","% ml = bmmo_default_input;\r","% ml = bmmo_add_random_noise(ml);\r","% \r","% % generate permutations of 2 wafers on two chucks \r","% w_perm = [1 3 5; 2 4 6];\r","% \r","% \r","% for iw = 1:size(w_perm, 1)\r","%     mlt = sub_set_wafers_nan(ml, w_perm(iw, :));    \r","%     out = bmmo_nxe_drift_control_model(mlt);\r","% end\r","% \r","% % All wafers NaN \r","% function test_bmmo_all_invalid\r","% \r","% ml = bmmo_default_input;\r","% ml = bmmo_add_random_noise(ml);\r","% \r","% % generate permutations of 2 wafers on two chucks \r","% w_perm = 1:6;\r","% \r","% \r","% for iw = 1:size(w_perm, 1)\r","%     mlt = sub_set_wafers_nan(ml, w_perm(iw, :));    \r","%     out = bmmo_nxe_drift_control_model(mlt);\r","% end\r","\r","\r","function mlo = sub_set_wafers_nan(ml, wafers)\r","\r","mlo = ml;\r","for iw = 1:length(wafers)\r","    mlo.layer.wr(wafers(iw)).dx = nan *  ml.wd.xw;\r","    mlo.layer.wr(wafers(iw)).dy = nan * ml.wd.xw;\r","end\r",""],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[2,3,4,5,6,12,13,15,16,17,26,27,30,31,32,33,35,36,37,46,47,50,51,52,54,55,56,64,65,68,69,70,71,72,74,75,76,114,115,116,117],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}