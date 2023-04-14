var sourceData62 = {"FileContents":["function FP_MIX = bmmo_construct_FPS_MIX(ml, options)\r","% function FPS_MIX = bmmo_construct_FPS_MIX(ml, options)\r","%\r","% Generate the raw MIX fingerprint for the combined model\r","%\r","% Input: \r","%  ml: input ml structure\r","%  options: structure defined in BMMO/BL3 default option structure\r","%\r","% Output:\r","%  FP_MIX: MIX fingerprint (1xN cell array of ml structs}\r","\r","params.pitch =  options.map_param.pitch;\r","params.min =    options.ytx_spline_params.x_start;     \r","params.max =    options.ytx_spline_params.x_end;\r","params.nr_seg = options.ytx_spline_params.nr_segments;\r","params.vq =     'dx';\r","params.xq =     'yw';\r","params.name =   'MIX';\r","\r","FP_MIX = bmmo_construct_FPS_MI(ml, params, options);\r","\r",""],"CoverageData":{"CoveredLineNumbers":[13,14,15,16,17,18,19,21],"UnhitLineNumbers":[],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,277,277,277,277,277,277,277,0,277,0,0]}}