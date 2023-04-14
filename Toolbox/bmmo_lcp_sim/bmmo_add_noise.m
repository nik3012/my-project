function mlo = bmmo_add_noise(mli)
% function mlo = bmmo_add_noise(mli)
%
% Add DCO budget noise per wafer to the input
%
%
% Input
%   mli: overlay structure
%
% Output
%   mlo: overlay struture with noise added
%
% 2016???? SBPR Creation


disp('adding noise');  
scaled = DCO_budget_noise(ovl_get_wafers(mli, 1), 'nwafer', mli.nwafer);
   
mlo = ovl_add(mli, scaled.total);
