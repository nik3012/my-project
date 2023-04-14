function FP = bmmo_construct_FPS_parlist(ml, parnames, scaling, options)
%function FP = bmmo_construct_FPS_parlist(ml, parnames, scaling, options)
%
% The function generates raw fingerprints for the combined model, 
% given vectors of parameter names and scaling factors
%
% Input: 
%  ml: input ml structure
%  parnames: 1xN cell array of interfield/intrafield parameter names
%  scaling: 1xN double vector of scaling factors
%  options: BMMO/BL3 options
%
% Output:
%  FP: fingerprint (1xN cell array of ml structs}

if nargin < 4
    options = bmmo_default_options_structure;
end

dummy = ml;

% interfield parameters
FP = cell(1, length(parnames));
for ii = 1:length(parnames)
    pars = struct(parnames{ii}, scaling(ii));
    tmp = ovl_model(dummy, 'apply', pars);
    tmp.what = parnames{ii};
    FP{ii} = ovl_combine_linear(tmp, 1/options.scaling_factor);
end