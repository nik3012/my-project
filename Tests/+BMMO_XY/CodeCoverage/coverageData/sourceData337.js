var sourceData337 = {"FileContents":["classdef testBmmoSusdFingerprint < BMMO_XY.tools.testSuite\r","    \r","    methods(Test)\r","        \r","        %% Test case 1\r","        function test_zero_susd(obj)\r","            % Given\r","            [mli, options] = bmmo_process_input(bmmo_default_input);\r","            \r","            % When\r","            ty = 0;\r","            mlo = bmmo_SUSD_fingerprint(mli, options.Scan_direction, ty);\r","            \r","            % Then\r","            obj.verifyWithinTol(mli, mlo);\r","        end\r","        \r","        %% Test case 2\r","        function test_same_susd_different_sign(obj)\r","            % Given\r","            [mli, options] = bmmo_process_input(bmmo_default_input);\r","            \r","            % When\r","            ty = 1;            \r","            mlo_pos = bmmo_SUSD_fingerprint(mli, options.Scan_direction, ty);\r","            ovl_pos = ovl_calc_overlay(mlo_pos);            \r","            mlo_neg = bmmo_SUSD_fingerprint(mli, options.Scan_direction, -1*ty);\r","            ovl_neg = ovl_calc_overlay(mlo_neg);\r","            \r","            % Then\r","            obj.verifyWithinTol(ovl_pos, ovl_neg);\r","        end\r","        \r","    end\r","    \r","end"],"CoverageData":{"CoveredLineNumbers":[8,11,12,15,21,24,25,26,27,28,31],"UnhitLineNumbers":[],"HitCount":[0,0,0,0,0,0,0,1,0,0,1,1,0,0,1,0,0,0,0,0,1,0,0,1,1,1,1,1,0,0,1,0,0,0,0,0]}}