var sourceData528 = {"FileContents":["function mlo = bmmo_undo_prev_sbc(mli)\r","% function mlo = bmmo_undo_prev_sbc(mli)\r","% <help_update_needed>\r","%\r","% <short description>\r","% input:\r","% output:\r","%\r","%\r","\r","[mlp, options] = bmmo_process_input(mli);\r","\r","% use WH fp per wafer for de-correction\r","options.WH.use_input_fp_per_wafer = 1;\r","\r","% use ADELwafergrid KA for de-correction (BL3)\r","if options.bl3_model && isfield(options, 'KA_act_corr')\r","    options.previous_correction.KA = rmfield(options.previous_correction.KA, 'grid_2de');\r","    options.previous_correction.KA.act_corr = options.KA_act_corr;\r","end\r","\r","mlo = bmmo_undo_sbc_corr_inlineSDM(mlp, options);"],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[11,14,17,18,19,22],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}