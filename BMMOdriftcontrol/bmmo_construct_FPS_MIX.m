function FP_MIX = bmmo_construct_FPS_MIX(ml, options)
% function FPS_MIX = bmmo_construct_FPS_MIX(ml, options)
%
% Generate the raw MIX fingerprint for the combined model
%
% Input: 
%  ml: input ml structure
%  options: structure defined in BMMO/BL3 default option structure
%
% Output:
%  FP_MIX: MIX fingerprint (1xN cell array of ml structs}

params.pitch =  options.map_param.pitch;
params.min =    options.ytx_spline_params.x_start;     
params.max =    options.ytx_spline_params.x_end;
params.nr_seg = options.ytx_spline_params.nr_segments;
params.vq =     'dx';
params.xq =     'yw';
params.name =   'MIX';

FP_MIX = bmmo_construct_FPS_MI(ml, params, options);

