var sourceData751 = {"FileContents":["function input_struct = bmmo_input_to_bl3(input_struct, neutralize_KA)\r","% function input_struct = bmmo_input_to_bl3(input_struct, neutralize_KA)\r","%\r","% Input:\r","% input_struct: BMMO NXE input structure\r","% neutralize_KA: Zero the previous KA correction and actuation reportm(default 1)\r","%\r","% Output: input_structure with all flags set to run the BL3 model \r","%\r","\r","if nargin < 2\r","    neutralize_KA = 1;\r","end\r","\r","hires_corr = bmmo_default_output_structure(bl3_default_options_structure);\r","hires_sbc = hires_corr.corr;\r","\r","if neutralize_KA\r","    input_struct.info.previous_correction.KA = hires_sbc.KA;\r","else\r","    for ic = 1:2\r","        ka_grid = bmmo_KA_corr_to_grid(input_struct.info.previous_correction.KA.grid_2de(ic));\r","        input_struct.info.previous_correction.KA.grid_2de(ic).x = hires_sbc.KA.grid_2de(ic).x;\r","        input_struct.info.previous_correction.KA.grid_2de(ic).y = hires_sbc.KA.grid_2de(ic).y;\r","        input_struct.info.previous_correction.KA.grid_2de(ic).dx = ka_grid.interpolant_x(hires_sbc.KA.grid_2de(ic).x, hires_sbc.KA.grid_2de(ic).y);\r","        input_struct.info.previous_correction.KA.grid_2de(ic).dy = ka_grid.interpolant_x(hires_sbc.KA.grid_2de(ic).x, hires_sbc.KA.grid_2de(ic).y);\r","        \r","        input_struct.info.previous_correction.KA.grid_2dc(ic).x = hires_sbc.KA.grid_2dc(ic).x;\r","        input_struct.info.previous_correction.KA.grid_2dc(ic).y = hires_sbc.KA.grid_2dc(ic).y;\r","        input_struct.info.previous_correction.KA.grid_2dc(ic).dx = hires_sbc.KA.grid_2dc(ic).dx;\r","        input_struct.info.previous_correction.KA.grid_2dc(ic).dy = hires_sbc.KA.grid_2dc(ic).dy;\r","    end\r","end\r","\r","input_struct.info.configuration_data.bl3_model = 1;\r","input_struct.info.configuration_data.KA_correction_enabled = 1;\r","input_struct.info.configuration_data.susd_correction_enabled = 1;\r","input_struct.info.configuration_data.platform = 'LIS';\r","\r","zero_inline_sdm_residual = input_struct.info.previous_correction.ffp;\r","for ic = 1:2\r","   zero_inline_sdm_residual(ic).dx =  zero_inline_sdm_residual(ic).dx * 0;\r","   zero_inline_sdm_residual(ic).dy =  zero_inline_sdm_residual(ic).dy * 0;\r","end\r","input_struct.info.report_data.inline_sdm_residual = zero_inline_sdm_residual;\r","\r","zero_residual_cet_grid = bmmo_empty_cet_residual(input_struct);\r","input_struct.info.report_data.cet_residual = zero_residual_cet_grid;\r","\r","if neutralize_KA\r","    input_struct.info.report_data.KA_cet_corr = zero_residual_cet_grid;\r","    input_struct.info.report_data.KA_cet_nce = zero_residual_cet_grid;\r","end\r",""],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[11,12,15,16,18,19,20,21,22,23,24,25,26,28,29,30,31,35,36,37,38,40,41,42,43,45,47,48,50,51,52],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}