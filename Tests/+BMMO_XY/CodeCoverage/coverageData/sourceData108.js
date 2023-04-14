var sourceData108 = {"FileContents":["function [res, MI_map, fp] = bmmo_generate_mirrors(mli_chk, fit_coeffs_MIX, fit_coeffs_MIY, options)\r","%function [res, MI_map, fp] = bmmo_generate_mirrors(mli_chk, fit_coeffs_MIX, fit_coeffs_MIY, options)\r","%\r","% This function models mirror shapes for x-mirror and y-mirror. It uses\r","% the natural cubic splines(f''=0 at the end point) with given number of\r","% segments for mirror x and mirror y with a fixed pitch of 0.001m.\r","%\r","% Input:\r","%  mli_chk : input ml struct (double layer and single wafer)\r","%  fit_coeffs_MIX : MIX fit coeffs as outputted from bmmo_combined_model\r","%  fit_coeffs_MIY : MIY fit coeffs as outputted from bmmo_combined_model\r","%  options : BMMO/BL3 options structure\r","%\r","% Output:\r","%  res : residue after mirror model\r","%  MI_map : modeled x-mirror and y-mirror from the input\r","%  fp: mirror fingerprint\r","%\r","% For details of the model and definitions of in/out interfaces, refer to\r","% D000810611 EDS BMMO NXE drift control model\r","\r","% Use the fit\r","map_param.start_position            = options.map_param.start_position;  %-0.2\r","map_param.pitch                     = options.map_param.pitch;\r","params.x_start                      = options.ytx_spline_params.x_start;       % -0.15\r","params.x_end                        = options.ytx_spline_params.x_end;\r","params.nr_segments                  = options.ytx_spline_params.nr_segments;\r","map_length                          = options.map_table_length;\r","coeff                               = fit_coeffs_MIX;\r","[MI_map.x_mirr.y, MI_map.x_mirr.dx] = sub_eval_mirrors(coeff,params, map_param, map_length, options);\r","\r","map_param.start_position            = options.map_param.start_position;\r","map_param.pitch                     = options.map_param.pitch;\r","params.x_start                      = options.xty_spline_params.x_start;\r","params.x_end                        = options.xty_spline_params.x_end;\r","params.nr_segments                  = options.xty_spline_params.nr_segments;\r","map_length                          = options.map_table_length;\r","coeff                               = fit_coeffs_MIY;\r","[MI_map.y_mirr.x, MI_map.y_mirr.dy] = sub_eval_mirrors(coeff, params, map_param, map_length, options);\r","\r","fp                                  = bmmo_mirror_fingerprint(mli_chk, MI_map, options);\r","res                                 = ovl_sub(mli_chk, fp);\r","\r","\r","% End of main function, subfunctions below\r","% Model mirrors with splines\r","function [result_pos, result_meas] = sub_eval_mirrors(coeff, params, map_param, map_length, options)\r","% Determine points for measure\r","x = [0:(map_length - 1)]*map_param.pitch + map_param.start_position;\r","M = bmmo_base_spline(x, params.x_start, params.x_end, params.nr_segments, options);\r","result_meas = full(M*coeff);\r","result_meas=result_meas/options.scaling_factor;\r","\r","result_pos = [map_param.start_position:map_param.pitch:(map_param.start_position + map_param.pitch * (map_length - 1))]';\r",""],"CoverageData":{"CoveredLineNumbers":[23,24,25,26,27,28,29,30,32,33,34,35,36,37,38,39,41,42,49,50,51,52,54],"UnhitLineNumbers":[],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,234,234,234,234,234,234,234,234,0,234,234,234,234,234,234,234,234,0,234,234,0,0,0,0,0,0,468,468,468,468,0,468,0]}}