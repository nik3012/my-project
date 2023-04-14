function [mlo, pars] = bmmo_model_BAO(mli, options)
% function [mlo, pars] = bmmo_model_BAO(mli, options)
%
% Wrapper for ovl_model to do BAO modelling
% This offers a common interface for BAO modelling (which may change)
% 
% Input: 
%   mli: standard overlay structure
%   options: bmmo options structure as defined in bmmo_default_options_structure
%
% Output:
%   mlo: mli after BAO modelling
%   pars: BAO parameters

if nargin < 2
    options = bmmo_default_options_structure;
end

%[unused, pars] = ovl_model(ovl_get_layout(mli, options.reduced_reticle_layout));
[unused, pars] = bmmo_fit_model(bmmo_get_layout(mli, options.reduced_reticle_layout, options), options, '10par');

%mlo = ovl_model(mli, 'apply', pars, -1);

mlo = bmmo_apply_model(mli, pars, -1, options);

% bmmo_assert_equal(mlo, mlo_t);