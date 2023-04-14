var sourceData309 = {"FileContents":["classdef testBmmoMiSign < BMMO_XY.tools.testSuite\r","\r","    methods(Test)\r","        \r","        %% Test Case\r","        function Case1(obj)\r","            % Given\r","            mlz = bmmo_default_input;            \r","            ka_dx_vec = mlz.wd.yw .^ 2 * 1e-6;              % Add some positive MI-like content\r","            ka_dy_vec = mlz.wd.xc .^ 2 * 1e-6;              % Add some positive MI-like content            \r","            input = mlz;\r","            for iw = 1:mlz.nwafer\r","                input.layer.wr(iw).dx = ka_dx_vec;\r","                input.layer.wr(iw).dy = ka_dy_vec;\r","            end            \r","            input.info.previous_correction = bmmo_add_missing_corr(input.info.previous_correction);\r","            out = bmmo_nxe_drift_control_model(input);\r","            \r","            % When\r","            mixdata = out.corr.MI.wse(1).x_mirr;\r","            miydata = out.corr.MI.wse(1).y_mirr;\r","            \r","            % Then\r","            obj.verifyTrue(nanmedian(mixdata.dx) < 0);      % verify that the MI correction is predominantly negative\r","            obj.verifyTrue(nanmedian(miydata.dy) < 0);      % verify that the MI correction is predominantly negative\r","        end\r","        \r","    end\r","    \r","end"],"CoverageData":{"CoveredLineNumbers":[8,9,10,11,12,13,14,16,17,20,21,24,25],"UnhitLineNumbers":[],"HitCount":[0,0,0,0,0,0,0,1,1,1,1,1,6,6,0,1,1,0,0,1,1,0,0,1,1,0,0,0,0,0]}}