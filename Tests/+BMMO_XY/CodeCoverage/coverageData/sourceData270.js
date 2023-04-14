var sourceData270 = {"FileContents":["classdef testBmmoFfBaoCorrection < BMMO_XY.tools.testSuite\r","    \r","    methods(Test)\r","        \r","        %% MI@M = MI@E and KA@M OFF\r","        function Case1(obj)\r","            % Given\r","            load([bmmo_testdata_root filesep 'TC07_01_in.mat']);  % BAO, Intra, WH combined input\r","            load([bmmo_testdata_root filesep 'TC07_01_out.mat']);\r","            \r","            % When\r","            for ichk = 1:2\r","                test_out_pars_6(ichk) = bmmo_ff_bao_correction(MI_map(ichk), KA_map(ichk), options);\r","            end\r","            \r","            % Then\r","            obj.verifyWithinTol(test_out_pars_6, out_pars_6, 'tol', 0.5*1e-11);\r","            \r","        end\r","        \r","        %% MI@M = -MI@E and KA@M ON\r","        function Case2(obj)\r","            % Given\r","            load([bmmo_testdata_root filesep 'TC07_02_in.mat']);  % BAO, Intra, WH combined input\r","            load([bmmo_testdata_root filesep 'TC07_02_out.mat']);\r","            \r","            % When\r","            for ichk = 1:2\r","                [test_out_pars_6_MI(ichk), test_out_pars_6_KA(ichk)] = bmmo_ff_bao_correction(MI_map(ichk), KA_map(ichk), options);\r","                test_out_pars_6(ichk) = bmmo_add_BAOs(test_out_pars_6_MI(ichk), test_out_pars_6_KA(ichk));\r","            end\r","            \r","            % Then\r","            obj.verifyWithinTol(test_out_pars_6, out_pars_6, 'tol', 0.5*1e-11);\r","        end\r","        \r","        %% Test 3\r","        function test_input_validation(obj)\r","            % Given\r","            load([bmmo_testdata_root filesep 'TC07_01_in.mat']);  % BAO, Intra, WH combined input\r","            \r","            % When\r","            options.FIWA_mark_locations.x = [];\r","            \r","            % Then\r","            obj.verifyError(@() bmmo_ff_bao_correction(MI_map(1), KA_map(1), options), '');\r","        end\r","        \r","    end\r","    \r","end\r","\r",""],"CoverageData":{"CoveredLineNumbers":[8,9,12,13,17,24,25,28,29,30,34,40,43,46],"UnhitLineNumbers":[],"HitCount":[0,0,0,0,0,0,0,1,1,0,0,1,2,0,0,0,1,0,0,0,0,0,0,1,1,0,0,1,2,2,0,0,0,1,0,0,0,0,0,1,0,0,1,0,0,1,0,0,0,0,0,0,0]}}