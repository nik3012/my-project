var sourceData716 = {"FileContents":["function tests = test_bmmo_convergence_input\r","tests = functiontests(localfunctions);\r","end\r","% Test BMMO model and sub-model convergence in the default setting over 20 runs with different inputs and levels of noise\r","\r","%1. zero input with 1 nm noise\r","function test_bmmo_convergence_20x_zero_1nm_noise(test)\r","\r","mli = bmmo_default_input;\r","assert(sub_evaluate_full_convergence_run(mli, 1));\r","end\r","\r","% 2. random input\r","function test_bmmo_convergence_20x_random_input(test)\r","\r","mli = bmmo_default_input;\r","mli = bmmo_add_random_noise(mli);\r","\r","assert(sub_evaluate_full_convergence_run(mli, 0));\r","end\r","\r","% 3. Generated 'Bad BAO' data\r","function test_bmmo_convergence_20x_bad_bao(test)\r","\r","mli = bmmo_bad_bao_input;\r","assert(sub_evaluate_full_convergence_run(mli, 0));\r","end\r","\r","% 4. Proto test convergence run 1\r","function test_bmmo_convergence_20x_proto(test)\r","\r","load([bmmo_testdata_root filesep 'proto_convergence_input.mat']);\r","input_struct.configurable_options.x_shift = [0 -260e-6; 0 -260e-6];\r","input_struct.configurable_options.y_shift = [0 -40e-6; 0 -40e-6];\r","\r","input_struct = bmmo_turn_off_l2(input_struct);\r","input_struct.info.previous_correction = bmmo_add_missing_corr(input_struct.info.previous_correction);\r","\r","input_struct.configurable_options.submodel_sequence = {'MI', 'BAO', 'INTRAF'};\r","\r","assert(sub_evaluate_full_convergence_run(input_struct, 0));\r","end\r","\r","% 5. Simulated injected data\r","function test_bmmo_convergence_20x_simulated_data(test)\r","\r","% use random input with noise\r","input_struct = bmmo_default_input;\r","input_struct = bmmo_add_default_whff(input_struct);\r","mi_input = bmmo_simulate_random_input(input_struct, 'WMBI', 1);\r","\r","assert(sub_evaluate_full_convergence_run(mi_input, 0));\r","end\r","\r","% 6. 'bad BAO' data with control to baseline filter\r","function test_bmmo_convergence_20x_badbao_control(test)\r","\r","mli = bmmo_bad_bao_input;\r","mli.info.report_data.time_filtering_enabled = 1;\r","assert(sub_evaluate_full_convergence_run(mli, 0));\r","end\r","\r","% 7. simulated injected data with control to baseline filter\r","function test_bmmo_convergence_20x_sim_control_mb(test)\r","\r","input_struct = bmmo_default_input;\r","input_struct = bmmo_add_default_whff(input_struct);\r","input_struct.info.report_data.time_filtering_enabled = 1;\r","\r","% use random input with noise\r","mi_input = bmmo_simulate_random_input(input_struct, 'WMBI', 1);\r","assert(sub_evaluate_full_convergence_run(mi_input, 0));\r","end\r","\r","% 8. simulated injected data with control to baseline filter, mirror only\r","function test_bmmo_convergence_20x_sim_control_m(test)\r","\r","input_struct = bmmo_default_input;\r","input_struct.info.report_data.time_filtering_enabled = 1;\r","\r","% use random input with noise\r","mi_input = bmmo_simulate_random_input(input_struct, 'M', 1);\r","assert(sub_evaluate_full_convergence_run(mi_input, 0));\r","end\r","\r","% 9. simulated injected data with control to baseline filter 1L SUSD control\r","function test_bmmo_convergence_20x_sim_control_SMBI_1L(test)\r","\r","input_struct = bmmo_default_input;\r","input_struct = bmmo_turn_off_l2(input_struct);\r","input_struct.info.report_data.time_filtering_enabled = 1;\r","input_struct.info.configuration_data.susd_correction_enabled = 1;\r","\r","% use random input with noise\r","mi_input = bmmo_simulate_random_input(input_struct, 'SMBI', 1);\r","assert(sub_evaluate_full_convergence_run(mi_input, 0));\r","end\r","\r","% 10. simulated injected data with recover to baseline filter 1L SUSD control\r","function test_bmmo_convergence_20x_sim_recover_SMBI_1L(test)\r","\r","input_struct = bmmo_default_input;\r","input_struct = bmmo_turn_off_l2(input_struct);\r","input_struct.info.configuration_data.susd_correction_enabled = 1;\r","\r","% use random input with noise\r","mi_input = bmmo_simulate_random_input(input_struct, 'SMBI', 1);\r","assert(sub_evaluate_full_convergence_run(mi_input, 0));\r","end\r","\r","% 11. simulated injected data with control to baseline filter 1L SUSD\r","% control with MIKA-combo model\r","function test_bmmo_convergence_20x_sim_control_SMBI_1L_MIKA(test)\r","\r","input_struct = bmmo_default_input;\r","input_struct = bmmo_turn_off_l2(input_struct);\r","input_struct.info.report_data.time_filtering_enabled = 1;\r","input_struct.info.configuration_data.susd_correction_enabled = 1;\r","input_struct.info.configuration_data.KA_correction_enabled = 1;\r","\r","% use random input with noise\r","mi_input = bmmo_simulate_random_input(input_struct, 'SMKBI', 1);\r","assert(sub_evaluate_full_convergence_run(mi_input, 0));\r","end\r","\r","% 12. simulated injected data with recover to baseline filter 1L SUSD control\r","% control with MIKA-combo model\r","function test_bmmo_convergence_20x_sim_recover_SMBI_1L_MIKA(test)\r","\r","input_struct = bmmo_default_input;\r","input_struct = bmmo_turn_off_l2(input_struct);\r","input_struct.info.configuration_data.susd_correction_enabled = 1;\r","input_struct.info.configuration_data.KA_correction_enabled = 1;\r","\r","% use random input with noise\r","mi_input = bmmo_simulate_random_input(input_struct, 'SMKBI', 1);\r","assert(sub_evaluate_full_convergence_run(mi_input, 0));\r","end\r","\r","% 13. simulated injected data with control to baseline filter 2L SUSD\r","% control with MIKA-combo model\r","function test_bmmo_convergence_20x_sim_control_SMBI_2L_MIKA(test)\r","\r","input_struct = bmmo_default_input;\r","input_struct = bmmo_add_default_whff(input_struct);\r","input_struct.info.report_data.time_filtering_enabled = 1;\r","input_struct.info.configuration_data.susd_correction_enabled = 1;\r","input_struct.info.configuration_data.KA_correction_enabled = 1;\r","\r","% use random input with noise\r","mi_input = bmmo_simulate_random_input(input_struct, 'WSMKBI', 1);\r","assert(sub_evaluate_full_convergence_run(mi_input, 0));\r","end\r","\r","% 14. simulated injected data with recover to baseline filter 2L SUSD\r","% control with MIKA-combo model\r","function test_bmmo_convergence_20x_sim_recover_SMBI_2L_MIKA(test)\r","\r","input_struct = bmmo_default_input;\r","input_struct = bmmo_add_default_whff(input_struct);\r","input_struct.info.configuration_data.susd_correction_enabled = 1;\r","input_struct.info.configuration_data.KA_correction_enabled = 1;\r","\r","% use random input with noise\r","mi_input = bmmo_simulate_random_input(input_struct, 'WSMKBI', 1);\r","assert(sub_evaluate_full_convergence_run(mi_input, 0));\r","end\r","\r","% 14. simulated injected data with control to baseline filter 2L SUSD\r","% control\r","function test_bmmo_convergence_20x_sim_control_SMBI_2L(test)\r","\r","input_struct = bmmo_default_input;\r","input_struct = bmmo_add_default_whff(input_struct);\r","input_struct.info.report_data.time_filtering_enabled = 1;\r","input_struct.info.configuration_data.susd_correction_enabled = 1;\r","input_struct.info.configuration_data.KA_correction_enabled = 1;\r","\r","% use random input with noise\r","mi_input = bmmo_simulate_random_input(input_struct, 'WSMKBI', 1);\r","assert(sub_evaluate_full_convergence_run(mi_input, 0));\r","end\r","\r","% 15. simulated injected data with recover to baseline filter 2L SUSD control\r","function test_bmmo_convergence_20x_sim_recover_SMBI_2L(test)\r","\r","input_struct = bmmo_default_input;\r","input_struct = bmmo_add_default_whff(input_struct);\r","input_struct.info.configuration_data.susd_correction_enabled = 1;\r","input_struct.info.configuration_data.KA_correction_enabled = 0;\r","\r","% use random input with noise\r","mi_input = bmmo_simulate_random_input(input_struct, 'WSMBI', 1);\r","assert(sub_evaluate_full_convergence_run(mi_input, 0));\r","end\r","\r","\r","function pass = sub_evaluate_full_convergence_run(mli, noise)\r","\r","runs_to_compare = [2 10 19 20];\r","fps = bmmo_convergence_run(mli, 20, noise, runs_to_compare);\r","\r","fn = fieldnames(fps);\r","\r","pass = true;\r","\r","% diff threshold is a function of noise\r","thresh = 7e-11 + (1e-9 * (noise / 3)); %TODO check value\r","\r","for ii = 1:length(fn)\r","    \r","    % only compare intermediate runs if recover to baseline filter is\r","    % active. Otherwise the models take longer to converge\r","    if ~mli.info.report_data.time_filtering_enabled\r","        % compare the ovl of run 2 and 20, all sub-models and total\r","        pass = pass && sub_compare_runs(fps, 4, 1, fn{ii}, thresh);\r","\r","        % compare the ovl of run 10 and 20, all sub-models and total\r","        pass =  pass && sub_compare_runs(fps, 4, 2, fn{ii}, thresh);\r","    end\r","    \r","    % compare the ovl of run 19 and 20, all sub-models and total\r","    pass =  pass && sub_compare_runs(fps, 4, 3, fn{ii}, thresh);\r","end\r","end\r","\r","function pass = sub_compare_runs(fps, n1, n2, fname, thresh)\r","\r","diff = ovl_sub(fps(n1).(fname), fps(n2).(fname));\r","ov_diff = ovl_calc_overlay(diff);\r","pass = ((ov_diff.ox997 < thresh) & (ov_diff.oy997 < thresh));\r","end"],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[2,9,10,16,17,19,25,26,32,33,34,36,37,39,41,48,49,50,52,58,59,60,66,67,68,71,72,78,79,82,83,89,90,91,92,95,96,102,103,104,107,108,115,116,117,118,119,122,123,130,131,132,133,136,137,144,145,146,147,148,151,152,159,160,161,162,165,166,173,174,175,176,177,180,181,187,188,189,190,193,194,200,201,203,205,208,210,214,216,219,223,229,230,231],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}