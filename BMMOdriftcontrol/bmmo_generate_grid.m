function [ml_res, ka_grid_out, ml_KA] = bmmo_generate_grid(mli, fit_coeffs, options)
% function [ml_res, ka_grid_out, ml_KA] = bmmo_generate_grid(mli, fit_coeffs, options)
%
% This function evaluates the fitted KA coefficients on to te KA grid
% layout. It uses the same algorithm as NXE3400/3600 for actuating KA
% corrections
%
% Input:
% mli: input ml struct
% fit_coeffs: KA fit coefficients from as ouput by bmmo_combined_model
% options
%
% Output:
% ml_res: Residue after KA model
% ka_grid_out: modeled KA grid
% ml_KA:  modeled KA fpt on mli layout
%
% For details of the model and definitions of in/out interfaces, refer to
% D000810611 EDS BMMO NXE drift control model

if nargin < 3
    options = bmmo_default_options_structure;
end

% create zeroed KA grid using defined KA pitch
ka_grid = bmmo_KA_grid(options.KA_start, options.KA_pitch);

ml_target = bmmo_KA_grid_to_ml(ka_grid);

if any(contains(options.submodel_sequence,'MIKA_EDGE'))
    fps_ka = bmmo_construct_FPS_KA(ml_target, options);
    fps_edge = bmmo_construct_FPS_GaussianEDGE(ml_target, options);
    fps = [fps_ka fps_edge];
else
    fps = bmmo_construct_FPS_KA(ml_target, options);
end

for i = 1:length(fps)
    M(:, i) = sub_make_columns(fps{i});
end

ovl = M*fit_coeffs;

% copy distortion map from resampled input into KA grid
ml_target.layer.wr.dx = ovl(1:length(ovl)/2);
ml_target.layer.wr.dy = ovl(length(ovl)/2 + 1:end);

if any(contains(options.submodel_sequence,'MIKA_EDGE'))
    ml_target = ovl_remove_edge(ml_target, options.edge_clearance);
    ml_target = bmmo_extrapolate_nan(ml_target, 'nearest');
    [~, coeff_10par_KA_bound] = bmmo_fit_model(ovl_remove_edge(ml_target, options.KA.BAO_edge_removal), options, '10par');
    ml_target = bmmo_apply_model(ml_target, coeff_10par_KA_bound, -1, options);
    ml_target = ovl_remove_edge(ml_target, options.KA_bound); % in case EFO workaround implemeted on LCP
else
    ml_target = bmmo_fit_model(ml_target, options, '10par');
end

ka_grid_out = bmmo_mlKA_to_grid(ml_target);

% subtract the modelled KA grid to get the residual
ml_KA = feval(options.KA_actuation.fnhandle, ka_grid_out, mli, options);
ml_res = ovl_sub(mli, ml_KA);

function o = sub_make_columns(mli)

o = [mli.layer.wr.dx ; mli.layer.wr.dy];