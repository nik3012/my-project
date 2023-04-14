function FP_INTERF = bmmo_construct_FPS_INTERFMAG(ml, options)
% function FP_INTERF = bmmo_construct_FPS_INTERFMAG(ml, options)
%
% The function generates the raw INTERF magnification(mws,mwa) 
% fingerprint for the combined model
%
% Input: 
%  ml: input ml structure
%  options: structure containing the fields 
%           INTERF.name: 1xN cell array of interfield magnification parameter names
%           INTERF.scaling: 1xN double vector of scaling factors
%
% Output:
%  FP_INTERF: INTERFMAG fingerprint (1xN cell array of ml structs}

FP_INTERF = bmmo_construct_FPS_parlist(ml, options.INTERFMAG.name, ones(size(options.INTERFMAG.name)), options);

