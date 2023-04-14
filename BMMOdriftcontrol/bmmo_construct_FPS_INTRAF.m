function FP_INTRAF = bmmo_construct_FPS_INTRAF(ml, options)
% function FP_INTRAF = bmmo_construct_FPS_INTRAF(ml, options)
%
% The function generates the raw INTRAF fingerprint for the combined model
%
% Input:
%  ml: input ml structure
%  options: structure containing the fields 
%           INTRAF.name: 1xN cell array of intrafield parameter names
%           INTRAF.scaling: 1xN double vector of scaling factors
%
% Output: 
%  FP_INTRAF: INTRAF fingerprint (1xN cell array of ml structs}

FP_INTRAF = bmmo_construct_FPS_parlist(ml, options.INTRAF.name, options.INTRAF.scaling, options);

