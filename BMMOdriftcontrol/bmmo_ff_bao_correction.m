function [pars6_MI, pars6_KA] = bmmo_ff_bao_correction(MI_maps, KA_grid, options)
%function [pars6_MI, pars6_KA] = bmmo_ff_bao_correction(MI_maps, KA_grid, options)
%
% This function calculates FIWA 6-par offset needed for the mirror and KA 
% grid maps to be applied on the measure side.
%
% Input:
% MI_maps: input mirror map on a chuck
% KA_grid:  input KA grid on a chuck
% options: BMMO/BL3 default options structure 
%
% Output :
% pars_6_MI : FIWA 6-par offset with MI_maps
% pars_6_KA : FIWA 6-par offset with KA_grid
%
% For details of the model and definitions of in/out interfaces, refer to
% D000810611 EDS BMMO NXE drift control model

if ~isfield(options.FIWA_mark_locations, 'x') || ~isfield(options.FIWA_mark_locations, 'y') ||...
        isempty(options.FIWA_mark_locations.x) || isempty(options.FIWA_mark_locations.y)
    error('options.FIWA_mark_locations structure incomplete or missing');
end

% Construct wd struture with BF marks
ml_target.wd.xc = options.FIWA_mark_locations.x';
ml_target.wd.yc = options.FIWA_mark_locations.y';
ml_target.wd.xf = zeros(size(ml_target.wd.xc));
ml_target.wd.yf = ml_target.wd.xf;
ml_target.wd.xw = options.FIWA_mark_locations.x';
ml_target.wd.yw = options.FIWA_mark_locations.y';
ml_target.nwafer = 1;
ml_target.nlayer = 1;
ml_target.nmark =  1;
ml_target.nfield = length(ml_target.wd.xc);

% Interpolate to FIWA marks using MI_maps
vx   = ~isnan( MI_maps.y_mirr.dy);
pos  = MI_maps.y_mirr.x;
meas = MI_maps.y_mirr.dy;
ml_out = ml_target;
ml_out.layer.wr.dy = interp1(pos(vx), meas(vx), ml_target.wd.xw);

vx   = ~isnan( MI_maps.x_mirr.dx);
pos  = MI_maps.x_mirr.y;
meas = MI_maps.x_mirr.dx;
ml_out.layer.wr.dx = interp1(pos(vx), meas(vx), ml_target.wd.yw);

%Estimate 6parwafer for MI maps offset in FIWA postions
ml_out = ovl_combine_linear(ml_out,-1);
[~, pars6_MI]  =   ovl_model(ml_out,'6parwafer');
pars6_MI = rmfield(pars6_MI,'d3');

% Interpolate to FIWA marks using KA_grid
% Bilinear interpolation
KA_grid = bmmo_KA_fix_interpolant(KA_grid);
ml_out2 = ml_target;
ml_out2.layer.wr.dx = KA_grid.interpolant_x(ml_out2.wd.xw, ml_out2.wd.yw);
ml_out2.layer.wr.dy = KA_grid.interpolant_y(ml_out2.wd.xw, ml_out2.wd.yw);

%Estimate 6parwafer for KA grid offset in FIWA postions
ml_out2 = ovl_combine_linear(ml_out2,-1);
[~, pars6_KA ]  =   ovl_model(ml_out2,'6parwafer');
pars6_KA = rmfield(pars6_KA,'d3');
