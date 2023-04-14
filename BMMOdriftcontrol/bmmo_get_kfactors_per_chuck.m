function [kfactors, ml_corr] = bmmo_get_kfactors_per_chuck(ml, options)
% function [kfactors, ml_corr] = bmmo_get_kfactors_per_chuck(ml, options)
%
% Given an ml struct, get the 20par fit per chuck and the 20par correctable
%
% Input:
%   ml: overlay structure
%   options: BMMO/BL3 options structure
%
% Output:
%   kfactors: K-factor coefficients per chuck
%   ml_corr: 20par correctible

ml_corr = ovl_get_wafers(ml, []);

for ic = 1:2
    wafers_this_chuck = find(options.chuck_usage.chuck_id == ic);
    ml_chuck = ovl_get_wafers(ml, wafers_this_chuck);
     [res, kfactors_temp(ic)] = ovl_model(ml_chuck, options.intraf_CETparfull.name, 'no_norm');
     kfactors(ic) = rmfield(kfactors_temp(ic), {'rs', 'ra', 'ms', 'ma', 'rws', 'rwa', 'mws', 'mwa'}); 
    ml_corr = ovl_combine_wafers(ml_corr, ovl_sub(ml_chuck, res));
end