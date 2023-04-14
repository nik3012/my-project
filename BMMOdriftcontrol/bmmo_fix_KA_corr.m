function corr = bmmo_fix_KA_corr(corr)
%function corr = bmmo_fix_KA_corr(corr)
% 
% The function fixes the interpolants in KA@E & K@M corrections, 
% as per the grid size (sqrt(numel(ka_grid.x))). This fix for interpolants 
% is needed for the 5th order actuation when KA is off.
%
% Input
%  corr: KA SBC correction, as given in bmmo_default_output_structure
% 
% Output
%  corr: KA SBC corrections with fixed interpolants

for ic = 1:2
    corr.KA.grid_2de(ic) = bmmo_KA_fix_interpolant(corr.KA.grid_2de(ic));
    if isfield(corr.KA, 'grid_2dc')
        corr.KA.grid_2dc(ic) = bmmo_KA_fix_interpolant(corr.KA.grid_2dc(ic));
    end
end
