function FP_KA = bmmo_construct_FPS_KA_nonlinear(ml, options)
%function FP_KA = bmmo_construct_FPS_KA_nonlinear(ml, options)
%
% The function generates the raw KA fingerprint for the combined model
% without the linear terms (First KA order is excluded)
%
% Input: 
%  ml: input ml structure
%  options: structure containing the fields 
%           KA_orders: KA orders
%           scaling_factor: scaling factor
% 
% Output: 
%  FP_KA: KA fingerprint (1xN cell array of ml structs}

tmp_options = options;
tmp_options.KA_orders(tmp_options.KA_orders == 1) = [];

FP_KA =  bmmo_construct_FPS_KA(ml, tmp_options);

