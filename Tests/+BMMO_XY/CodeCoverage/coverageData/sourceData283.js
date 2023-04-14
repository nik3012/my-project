var sourceData283 = {"FileContents":["classdef testBmmoGenerateMirrors < BMMO_XY.tools.testSuite\r","    \r","    methods(Test)\r","        \r","        %% Test case\r","        function test_bmmo_generate_mirrors_correctable_MI(obj)\r","            % Given\r","            load([bmmo_testdata_root filesep 'generate_mirrors.mat']);\r","            \r","            % When\r","            for ichuck = 1:2\r","                [test_res(ichuck), test_MI_map(ichuck), test_fp(ichuck)] = bmmo_generate_mirrors(mli(ichuck), ...\r","                    fit_coeffs.MIX{ichuck}, fit_coeffs.MIY{ichuck}, options);\r","            end\r","            \r","            % Then\r","            obj.verifyWithinTol(res, test_res)\r","            obj.verifyWithinTol(MI_map, test_MI_map)\r","            obj.verifyWithinTol(fp, test_fp)\r","        end\r","        \r","    end\r","    \r","end\r","\r",""],"CoverageData":{"CoveredLineNumbers":[8,11,12,13,17,18,19],"UnhitLineNumbers":[],"HitCount":[0,0,0,0,0,0,0,1,0,0,1,2,2,0,0,0,1,1,1,0,0,0,0,0,0,0]}}