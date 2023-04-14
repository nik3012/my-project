function [mlo, pars] = bmmo_6par_wafer( mli, options)
% function [mlo, pars] = bmmo_6par_wafer(mli, options)
%
% Wrapper for ovl_model to do BAO modelling (6parwafer) on Baseliner data 
% with '7x7' layout .This offers a common interface for BAO modelling 
% (which may change).
%
% Input:
%   mli: standard overlay structure
%   options: BMMO/BL3 option structure
%
% Output:
%   mlo: mli after removing interfield/intrafield content using 6parwafer
%   pars: BAO parameters

if nargin < 2
    options.reduced_reticle_layout = '7x7';
end

[~, pars] = ovl_model(bmmo_get_layout(mli, options.reduced_reticle_layout, options), '6parwafer');
mlo = ovl_model(mli, 'apply', pars, -1);


