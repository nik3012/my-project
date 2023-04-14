var sourceData303 = {"FileContents":["classdef testBmmoKaFingerprint < BMMO_XY.tools.testSuite\r","\r","    methods(Test)\r","        \r","        %% Test that ml input only provides the layout\r","        function Case1(obj)\r","            % Given\r","            mli1 = ovl_create_dummy('marklayout', 'BA-XY-DYNA-13X19', 'nlayer', 1); % generate a single-layer, single-wafer zeroed structure mli1 with no chuck info\r","            mli2 = ovl_create_dummy('marklayout', 'BA-XY-DYNA-13X19', 'nlayer', 1); % generate a single-layer, single-wafer structure mli2 with the same layout, but filled distortion values\r","            mli2.layer.wr.dx = mli2.layer.wr.dx + 1e7;\r","            mli2.layer.wr.dy = mli2.layer.wr.dx;\r","            options = bmmo_default_options_structure;\r","            parmc = ovl_metro_par_mc('KA_pitch',options.KA_pitch);                  % generate a parmc with only 2de information, convert to tlg            \r","            parmc.KA.raw.grid_2de(1).dx = parmc.KA.raw.grid_2de(1).dx + 1e-7;       % add some simple distortion\r","            parmc.KA.raw.grid_2de(1).dy = parmc.KA.raw.grid_2de(1).dy + 1e-7;            \r","            ka_grid = bmmo_KA_corr_to_grid(parmc.KA.raw.grid_2de(1));\r","            \r","            % When\r","            KA_fp1 = bmmo_KA_LOC_fingerprint(ka_grid, mli1, options);               % verify that parmc produces the same KA fingerprint with mli1 and mli2\r","            KA_fp2 = bmmo_KA_LOC_fingerprint(ka_grid, mli2, options);         \r","            \r","            % Then\r","            obj.verifyWithinTol(KA_fp1, KA_fp2);           \r","        end\r","        \r","        %% Case 2\r","        function Case2(obj)\r","            \r","            % Given\r","            load([bmmo_testdata_root filesep 'KA_fingerprint.mat']);            \r","            options = bmmo_default_options_structure;            \r","            ka_grid = bmmo_KA_corr_to_grid(Calib_KA);\r","            ka_fp = bmmo_KA_LOC_fingerprint(ka_grid, ml, options);\r","            \r","            % When\r","            test_out_ml_ka_res = ovl_sub(ml, ka_fp);            \r","            ovl = ovl_calc_overlay( ovl_sub(test_out_ml_ka_res,out_ml_ka_res));  \r","            \r","            % Then\r","            obj.verifyWithinTol( 1e9*ovl.ox100, 0 , 'tol',  0.05);\r","            obj.verifyWithinTol( 1e9*ovl.ox997, 0 , 'tol',  0.05);\r","            obj.verifyWithinTol( 1e9*ovl.oxm3s, 0 , 'tol',  0.05);\r","            obj.verifyWithinTol( 1e9*ovl.ox3sd, 0 , 'tol',  0.05);\r","            obj.verifyWithinTol( 1e9*ovl.oy100, 0 , 'tol',  0.05);\r","            obj.verifyWithinTol( 1e9*ovl.oy997, 0 , 'tol',  0.05);\r","            obj.verifyWithinTol( 1e9*ovl.oym3s, 0 , 'tol',  0.05);\r","            obj.verifyWithinTol( 1e9*ovl.oy3sd, 0 , 'tol',  0.05);           \r","            obj.verifyWithinTol(out_ml_ka_res.layer, test_out_ml_ka_res.layer);           \r","        end\r","        \r","    end\r","    \r","end"],"CoverageData":{"CoveredLineNumbers":[8,9,10,11,12,13,14,15,16,19,20,23,30,31,32,33,36,37,40,41,42,43,44,45,46,47,48],"UnhitLineNumbers":[],"HitCount":[0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,1,1,0,0,1,0,0,0,0,0,0,1,1,1,1,0,0,1,1,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0]}}