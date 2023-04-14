var sourceData265 = {"FileContents":["classdef testBmmoConstructWhFps < BMMO_XY.tools.testSuite\r","    \r","    methods(TestClassSetup)\r","        \r","        function setup(obj)\r","\r","            load([bmmo_testdata_root filesep 'TC09_01_in.mat']);\r","            load([bmmo_testdata_root filesep 'TC09_01_out.mat']);            \r","            obj.setup_data.options = bmmo_default_options_structure;\r","            obj.setup_data.options.intrafield_reticle_layout = obj.setup_data.options.reduced_reticle_layout;\r","            obj.setup_data.out_WHFP = out_WHFP;\r","            obj.setup_data.mli = mli;\r","        end\r","        \r","    end\r","    \r","    properties\r","        \r","        setup_data\r","        \r","    end\r","    \r","    methods(Test)\r","        \r","        function test_TC09_01(obj)\r","            % Given\r","            mli = bmmo_phase_2_input(obj.setup_data.mli);\r","            options = bmmo_ml_options(mli, obj.setup_data.options);            \r","            options.WH_K_factors = bmmo_k_factors_to_xml(options.WH_K_factors, ...      % convert k-factors to new format\r","                mli.nwafer, length(options.WH_K_factors.wafer(1).field));     \r","            \r","            %  When\r","            test_out_WHFP = bmmo_construct_wh_fp(mli, options);            \r","            for iwaf = 1:length(test_out_WHFP)\r","                test_out_WHFP = ovl_remove_edge(test_out_WHFP);    % output fp has edge removed\r","                \r","                % Then\r","                obj.verifyWithinTol(obj.setup_data.out_WHFP(iwaf).layer, test_out_WHFP(iwaf).layer);\r","            end\r","        end\r","        \r","        function test_use_input_fp(obj)\r","            % Given\r","            mli = bmmo_phase_2_input(obj.setup_data.mli);\r","            options = bmmo_ml_options(mli, obj.setup_data.options);\r","            options.WH_K_factors = bmmo_k_factors_to_xml(options.WH_K_factors, ...      % convert k-factors to new format\r","                mli.nwafer, length(options.WH_K_factors.wafer(1).field));            \r","            options.WH.use_input_fp = 1;\r","            \r","            % When\r","            test_out_WHFP = bmmo_construct_wh_fp(mli, options);            \r","            for iwaf = 1:length(test_out_WHFP)\r","                test_out_WHFP = ovl_remove_edge(test_out_WHFP);     % output fp has edge removed\r","                \r","                % Then\r","                obj.verifyWithinTol(obj.setup_data.out_WHFP(iwaf).layer, test_out_WHFP(iwaf).layer);\r","            end\r","        end\r","        \r","    end\r","    \r","end"],"CoverageData":{"CoveredLineNumbers":[7,8,9,10,11,12,27,28,29,30,33,34,35,38,44,45,46,47,48,51,52],"UnhitLineNumbers":[53,56],"HitCount":[0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,1,1,1,0,0,1,0,0,0,0,0,1,1,1,1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0]}}