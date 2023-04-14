var sourceData338 = {"FileContents":["classdef testBmmoUndoSbcCorrection < BMMO_XY.tools.testSuite\r","    \r","    methods(Static)\r","        \r","        %% Sub function\r","        function [options_out, model_results] = sub_configure(mli, options_in, delta_R)\r","            options_out = options_in;            \r","            options_out.mark_type = 'udbo';         % add new required fields to options\r","            options_out.x_shift = [0 0 ; 0 0];\r","            options_out.y_shift = [0 0; 0 0];\r","            options_out.layer_fields{1} = 1:87;\r","            options_out.layer_fields{2} = 88;\r","            options_out.fieldsize = [0.0260    0.0330];\r","            options_out.combined_model_contents = {};\r","            options_out.submodel_sequence = {'WH', 'SUSD', 'MI', 'KA', 'BAO', 'INTRAF'};\r","            tmp_options = bmmo_default_options_structure;\r","            options_out.filter = tmp_options.filter;\r","            mli = bmmo_phase_2_input(mli);\r","            options_out = bmmo_phase_2_options(options_out);\r","            options_out.bl3_model = 0;\r","            options_out.susd_control = 0;\r","            options_out.KA_control = 0;\r","            options_out.invert_MI_wsm_sign = 0;\r","            options_out.KA_orders = tmp_options.KA_orders;\r","            options_out.model_shift = tmp_options.model_shift;\r","            options_out = bmmo_ml_options(mli, options_out);\r","            options_out.WH.use_input_fp                  = 0;\r","            options_out.WH.fp                            = [];\r","            options_out.WH.use_raw                       = 0;\r","            options_out.WH_K_factors = bmmo_k_factors_to_xml(options_out.WH_K_factors, mli.nwafer, mli.nfield);\r","            tmp_sensitivity = options_out.IR2EUVsensitivity;\r","            options_out = bmmo_wh_options(mli, options_out);\r","            options_out.IR2EUVsensitivity = tmp_sensitivity;\r","            options_out.IFO_scan_direction = [-1 1 -1 1];\r","            options_out.KA_actuation = tmp_options.KA_actuation;\r","            options_out.platform = tmp_options.platform;\r","            options_out.FIWA_mark_locations = tmp_options.FIWA_mark_locations;\r","            options_out.KA_resample_options = tmp_options.KA_resample_options;\r","            options_out.KA_meas_start = tmp_options.KA_meas_start;\r","            for ic = 1:2                            % convert BAO previous correction to new format\r","                newBAO(ic) = bmmo_10par_to_BAO(options_out.previous_correction.BAO(ic));\r","            end\r","            options_out.previous_correction = rmfield(options_out.previous_correction, 'BAO');\r","            options_out.previous_correction.BAO = newBAO;            \r","            options_out.previous_correction = bmmo_get_18p_intraf(options_out.previous_correction);            \r","            model_results.WH.lambda = delta_R / options_out.IR2EUVsensitivity;\r","            model_results.WH.Calib_WH = delta_R;\r","            temp_out = bmmo_default_output_structure(options_out);      % add SUSD to previous correction\r","            options_out.previous_correction.SUSD = temp_out.corr.SUSD;\r","        end\r","        \r","    end\r","    \r","    properties\r","    \r","        model_results\r","    \r","    end\r","    \r","    methods(Test)\r","        \r","        %% Test case 1\r","        function Case1(obj)\r","            % Given\r","            load([bmmo_testdata_root filesep 'undo_sbc_correction.mat']);            \r","            mli = ml;            \r","            delta_R=0.2;    % assume 20% drift in WH Ratio\r","            [options, model_results] = obj.sub_configure(mli, options, delta_R);            \r","            \r","            % When\r","            t_mlo = bmmo_undo_sbc_correction(mli, options);\r","            \r","            % Then\r","            obj.verifyWithinTol(t_mlo.layer, mlo.layer, 'tol', 5e-11);\r","        end\r","        \r","        \r","        %% Test case 2\r","        function Case2(obj)\r","            % Given\r","            load([bmmo_testdata_root filesep 'undo_sbc_correction.mat']);\r","            mli = ml;\r","            mli.info.F.chuck_operation='USE_BOTH_CHUCK';\r","            mli.info.F.chuck_id{1}='CHUCK_ID_2';\r","            mli.info.F.chuck_id{2}='CHUCK_ID_1';\r","            mli.info.F.chuck_id{3}='CHUCK_ID_2';\r","            mli.info.F.chuck_id{4}='CHUCK_ID_1';\r","            mli.info.F.chuck_id{5}='CHUCK_ID_2';\r","            mli.info.F.chuck_id{6}='CHUCK_ID_1';\r","            for i=1:2:mli.nwafer\r","                mli.info.report_data.WH_K_factors.wafer(i) = ml.info.report_data.WH_K_factors.wafer(i+1);\r","                mli.info.report_data.WH_K_factors.wafer(i+1) = ml.info.report_data.WH_K_factors.wafer(i);\r","            end            \r","            delta_R=0.2;            % assume 20% drift in WH Ratio\r","            [options, model_results] = obj.sub_configure(mli, options, delta_R);            \r","            \r","            % When\r","            t_mlo = bmmo_undo_sbc_correction(mli, options);            \r","            mloo = mlo;\r","            for i=1:2:mli.nwafer\r","                mloo.layer.wr(i) = mlo.layer.wr(i+1);\r","                mloo.layer.wr(i+1) = mlo.layer.wr(i);\r","            end            \r","            \r","            % Then\r","            obj.verifyWithinTol(t_mlo.layer, mloo.layer, 'tol', 5e-11);\r","        end\r","        \r","        %% Test case 3\r","        function Case3(obj)\r","            % Given\r","            load([bmmo_testdata_root filesep 'undo_sbc_correction.mat']);            \r","            mli = ovl_get_wafers(ml, [1 3 5]);\r","            mli.info.F.chuck_operation='USE_SINGLE_CHUCK';\r","            mli.info.F = rmfield(mli.info.F, 'chuck_id');\r","            mli.info.F.chuck_id{1}='CHUCK_ID_1';\r","            mli.info.F.chuck_id{2}='CHUCK_ID_1';\r","            mli.info.F.chuck_id{3}='CHUCK_ID_1';\r","            mli.info.report_data.WH_K_factors = rmfield(mli.info.report_data.WH_K_factors, 'wafer');\r","            for i=1:mli.nwafer\r","                mli.info.report_data.WH_K_factors.wafer(i) = ml.info.report_data.WH_K_factors.wafer(1);\r","            end            \r","            delta_R=0.2;            % assume 20% drift in WH Ratio\r","            [options, model_results] = obj.sub_configure(mli, options, delta_R);            \r","            \r","            % When\r","            t_mlo = bmmo_undo_sbc_correction(mli, options);              \r","            mloo = ovl_get_wafers(mlo, [1 3 5]);\r","            mloo_wh(1) = mlo_wh(1);\r","            mloo_wh(2) = ovl_combine_linear(mlo_wh(2),0);\r","            mloo_intra(1) = mlo_intra(1);\r","            mloo_intra(2) = ovl_combine_linear(mlo_intra(2), 0 );            \r","            \r","            % Then\r","            obj.verifyWithinTol(t_mlo.layer.wr, mloo.layer.wr);\r","        end\r","        \r","        \r","        %% Test case 4\r","        function Case4(obj)\r","            % Given\r","            load([bmmo_testdata_root filesep 'undo_sbc_correction.mat']);            \r","            mli = ovl_get_wafers(ml, [2 4 6]);\r","            mli.info.F.chuck_operation='USE_SINGLE_CHUCK';\r","            mli.info.F = rmfield(mli.info.F, 'chuck_id');\r","            mli.info.F.chuck_id{1}='CHUCK_ID_2';\r","            mli.info.F.chuck_id{2}='CHUCK_ID_2';\r","            mli.info.F.chuck_id{3}='CHUCK_ID_2';\r","            mli.info.report_data.WH_K_factors = rmfield(mli.info.report_data.WH_K_factors, 'wafer');\r","            for i=1:mli.nwafer\r","                mli.info.report_data.WH_K_factors.wafer(i) = ml.info.report_data.WH_K_factors.wafer(2);\r","            end\r","            delta_R=0.2;            % assume 20% drift in WH Ratio\r","            [options, model_results] = obj.sub_configure(mli, options, delta_R); \r","            \r","            % When\r","            t_mlo = bmmo_undo_sbc_correction(mli, options);                 \r","            mloo = ovl_get_wafers(mlo, [2 4 6]);\r","            mloo_wh(1) = ovl_combine_linear(mlo_wh(1),0);\r","            mloo_wh(2) = mlo_wh(2);\r","            mloo_intra(1) = ovl_combine_linear(mlo_intra(2), 0 );\r","            mloo_intra(2) = mlo_intra(2);     \r","            \r","            % Then\r","            obj.verifyWithinTol(t_mlo.layer.wr, mloo.layer.wr, 'tol', 5e-11);\r","        end\r","        \r","    end\r","    \r","end"],"CoverageData":{"CoveredLineNumbers":[7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,43,44,45,46,47,48,49,65,66,67,68,71,74,81,82,83,84,85,86,87,88,89,90,91,92,94,95,98,99,100,101,102,106,112,113,114,115,116,117,118,119,120,121,123,124,127,128,129,130,131,132,135,142,143,144,145,146,147,148,149,150,151,153,154,157,158,159,160,161,162,165],"UnhitLineNumbers":[],"HitCount":[0,0,0,0,0,0,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,8,0,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,1,0,0,1,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,3,3,0,1,1,0,0,1,1,1,3,3,0,0,0,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,3,0,1,1,0,0,1,1,1,1,1,1,0,0,1,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,3,0,1,1,0,0,1,1,1,1,1,1,0,0,1,0,0,0,0,0]}}