function [res, MI_map, fp] = bmmo_generate_mirrors(mli_chk, fit_coeffs_MIX, fit_coeffs_MIY, options)
%function [res, MI_map, fp] = bmmo_generate_mirrors(mli_chk, fit_coeffs_MIX, fit_coeffs_MIY, options)
%
% This function models mirror shapes for x-mirror and y-mirror. It uses
% the natural cubic splines(f''=0 at the end point) with given number of
% segments for mirror x and mirror y with a fixed pitch of 0.001m.
%
% Input:
%  mli_chk : input ml struct (double layer and single wafer)
%  fit_coeffs_MIX : MIX fit coeffs as outputted from bmmo_combined_model
%  fit_coeffs_MIY : MIY fit coeffs as outputted from bmmo_combined_model
%  options : BMMO/BL3 options structure
%
% Output:
%  res : residue after mirror model
%  MI_map : modeled x-mirror and y-mirror from the input
%  fp: mirror fingerprint
%
% For details of the model and definitions of in/out interfaces, refer to
% D000810611 EDS BMMO NXE drift control model

% Use the fit
map_param.start_position            = options.map_param.start_position;  %-0.2
map_param.pitch                     = options.map_param.pitch;
params.x_start                      = options.ytx_spline_params.x_start;       % -0.15
params.x_end                        = options.ytx_spline_params.x_end;
params.nr_segments                  = options.ytx_spline_params.nr_segments;
map_length                          = options.map_table_length;
coeff                               = fit_coeffs_MIX;
[MI_map.x_mirr.y, MI_map.x_mirr.dx] = sub_eval_mirrors(coeff,params, map_param, map_length, options);

map_param.start_position            = options.map_param.start_position;
map_param.pitch                     = options.map_param.pitch;
params.x_start                      = options.xty_spline_params.x_start;
params.x_end                        = options.xty_spline_params.x_end;
params.nr_segments                  = options.xty_spline_params.nr_segments;
map_length                          = options.map_table_length;
coeff                               = fit_coeffs_MIY;
[MI_map.y_mirr.x, MI_map.y_mirr.dy] = sub_eval_mirrors(coeff, params, map_param, map_length, options);

fp                                  = bmmo_mirror_fingerprint(mli_chk, MI_map, options);
res                                 = ovl_sub(mli_chk, fp);


% End of main function, subfunctions below
% Model mirrors with splines
function [result_pos, result_meas] = sub_eval_mirrors(coeff, params, map_param, map_length, options)
% Determine points for measure
x = [0:(map_length - 1)]*map_param.pitch + map_param.start_position;
M = bmmo_base_spline(x, params.x_start, params.x_end, params.nr_segments, options);
result_meas = full(M*coeff);
result_meas=result_meas/options.scaling_factor;

result_pos = [map_param.start_position:map_param.pitch:(map_param.start_position + map_param.pitch * (map_length - 1))]';
