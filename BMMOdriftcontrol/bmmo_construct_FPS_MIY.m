function FP_MIY = bmmo_construct_FPS_MIY(ml, options)
% function FP_MIY = bmmo_construct_FPS_MIY(ml, options)
%
% Generate the raw MIY fingerprint for the combined model
%
% Input:
%  ml: input ml structure
%  options: structure defined in BMMO/BL3 default option structure 
%
% Output:
%  FP_MIY: MIY fingerprint (1xN cell array of ml structs}

params.pitch =  options.map_param.pitch;
params.min =    options.xty_spline_params.x_start;     
params.max =    options.xty_spline_params.x_end;
params.nr_seg = options.xty_spline_params.nr_segments;
params.vq =     'dy';
params.xq =     'xc';
params.name =   'MIY';

FP_MIY = bmmo_construct_FPS_MI(ml, params, options);

 