function FP_INTERF = bmmo_construct_FPS_INTERF(ml, options)
% function FP_INTERF = bmmo_construct_FPS_INTERF(ml, options)
%
% The function generates the raw INTERF fingerprint for the combined model
%
% Input: 
%  ml: input ml structure
%  options: structure containing the fields:
%           INTERF.name: 1xN cell array of interfield parameter names
%           INTERF.scaling: 1xN double vector of scaling factors
%
% Output: 
%  FP_INTERF: INTERF fingerprint (1xN cell array of ml structs}

FP_INTERF = bmmo_construct_FPS_parlist(ml, options.INTERF.name, ones(size(options.INTERF.name)), options);

