var sourceData255 = {"FileContents":["classdef testBmmoBaoSign < BMMO_XY.tools.testSuite\r","    \r","    methods(Test)\r","        \r","        function Case1 (obj)\r","            % Given\r","            mlz = bmmo_default_input;   \r","            tenpar.tx = 1e-9;   % Add some positive BAO content\r","            tenpar.ty = 2e-9;\r","            tenpar.rs = 3e-9;\r","            tenpar.ra = 4e-9;\r","            tenpar.ms = 5e-9;\r","            tenpar.ma = 6e-9;\r","            tenpar.rws = 7e-9;\r","            tenpar.rwa = 8e-9;\r","            tenpar.mws = 9e-9;\r","            tenpar.mwa = 10e-9;\r","            input = ovl_model(mlz, 'apply', tenpar);    % Run the bmmo model on the data\r","            input.info.previous_correction = bmmo_add_missing_corr(input.info.previous_correction);            \r","            out = bmmo_nxe_drift_control_model(input);            \r","            baodata = out.corr.BAO(1);       \r","            \r","            % When\r","            tp = bmmo_BAO_to_10par(baodata);            \r","            fn = fieldnames(tp);    % verify that the BAO correction is negative\r","            \r","            % Then\r","            for i = 1:length(fn)\r","                obj.verifyTrue(tp.(fn{i}) < 0);\r","            end\r","        end\r","        \r","    end\r","    \r","end"],"CoverageData":{"CoveredLineNumbers":[7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,24,25,28,29],"UnhitLineNumbers":[],"HitCount":[0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,0,0,1,10,0,0,0,0,0,0]}}