function ka_grid_meas = bmmo_KA_grid_expose_to_meas(ka_grid_exp, options)
%function ka_grid_meas = bmmo_KA_grid_expose_to_meas(ka_grid_exp, options)
%
% This function generates KA@M correction using KA@E correction of a chuck.
% BMMO or BL3 KA@M corrections are generated based on the provided BMMO or BL3
% option structures, respectively.
%
% Input:
%  ka_grid_exp: KA@E grid correction (one chuck only)
%  options: BMMO/BL3 option structure
% 
% Output:
% ka_grid_meas: KA@M grid correction (one chuck only)

ka_grid_meas = bmmo_KA_grid_subset(ka_grid_exp, options.KA_meas_start);

ka_grid_meas.dx = -1*ka_grid_meas.dx;
ka_grid_meas.dy = -1*ka_grid_meas.dy;

ka_grid_meas = bmmo_KA_fix_interpolant(ka_grid_meas);