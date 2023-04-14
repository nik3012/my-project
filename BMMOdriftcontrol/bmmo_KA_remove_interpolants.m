function corr = bmmo_KA_remove_interpolants(corr)
% function corr = bmmo_KA_remove_interpolants(corr)
%
% This function converts a KA grid in tlg format with interpolants to KA
% grid layout format
%
% Input:
%  corr: KA grid tlg (1x2 struct, containing fields: grid_2de, grid_2dc)
%
% Output:
%  ka_grid_out: corr converted to KA layout format without interpolants

NUMBER_CHUCKS = 2;
new_KA_corr = repmat(struct('x', [], 'y', [], 'dx', [], 'dy', []), 1, NUMBER_CHUCKS);
new_KA_measure_corr = new_KA_corr;

for ic = 1:NUMBER_CHUCKS
    new_KA_corr(ic).x = corr.KA.grid_2de(ic).x;
    new_KA_corr(ic).y = corr.KA.grid_2de(ic).y;
    new_KA_corr(ic).dx = corr.KA.grid_2de(ic).dx;
    new_KA_corr(ic).dy = corr.KA.grid_2de(ic).dy;
    if isfield(corr.KA, 'grid_2dc')
        new_KA_measure_corr(ic).x = corr.KA.grid_2dc(ic).x;
        new_KA_measure_corr(ic).y = corr.KA.grid_2dc(ic).y;
        new_KA_measure_corr(ic).dx = corr.KA.grid_2dc(ic).dx;
        new_KA_measure_corr(ic).dy = corr.KA.grid_2dc(ic).dy;
    end
end
corr.KA.grid_2de = new_KA_corr;
if isfield(corr.KA, 'grid_2dc')
    corr.KA.grid_2dc = new_KA_measure_corr;
end