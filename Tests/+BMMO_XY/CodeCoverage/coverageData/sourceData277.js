var sourceData277 = {"FileContents":["%% 1 test with simple translation of small structure\r","classdef testBmmoFitModelPerwafer < BMMO_XY.tools.testSuite\r","    \r","    methods(Test)\r","        \r","        function AllTestCases(obj)\r","            \r","            %% 1. test against ovl_model 10par with random large structure, single wafer\r","            \r","            % Given\r","            mld = ovl_create_dummy('marklayout','BA-XY-DYNA-13X19','nwafer', 1,'nlayer', 1);\r","            options.parlist = bmmo_parlist;            \r","            mld.layer.wr.dx = 1e-9 * randn(size(mld.layer.wr.dx));\r","            mld.layer.wr.dy = 1e-9 * randn(size(mld.layer.wr.dx));            \r","            options.parlist = bmmo_parlist;        \r","            \r","            % When\r","            mlo = ovl_model(mld, '10par', 'perwafer');            \r","            ml_out = bmmo_fit_model_perwafer(mld, options, '10par'); \r","            \r","            % Then\r","            obj.verifyWithinTol(ml_out, mlo);\r","            \r","            %% 2. test against ovl_model 10par with random large structure, multiple wafers\r","            \r","            % Given\r","            mld = ovl_create_dummy('marklayout','BA-XY-DYNA-13X19','nwafer', 6,'nlayer', 1);\r","            options.parlist = bmmo_parlist;\r","            for iw = 1:6\r","                mld.layer.wr(iw).dx = 1e-9 * randn(size(mld.layer.wr(iw).dx));\r","                mld.layer.wr(iw).dy = 1e-9 * randn(size(mld.layer.wr(iw).dx));\r","            end\r","            options.parlist = bmmo_parlist;\r","            \r","            % When\r","            mlo = ovl_model(mld, '10par', 'perwafer');\r","            ml_out = bmmo_fit_model_perwafer(mld, options, '10par');        % entire structure\r","            \r","            % Then\r","            obj.verifyWithinTol(mlo, ml_out);\r","        end\r","        \r","    end\r","    \r","end\r",""],"CoverageData":{"CoveredLineNumbers":[11,12,13,14,15,18,19,22,27,28,29,30,31,33,36,37,40],"UnhitLineNumbers":[],"HitCount":[0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,1,1,0,0,1,0,0,0,0,1,1,1,6,6,0,1,0,0,1,1,0,0,1,0,0,0,0,0,0]}}