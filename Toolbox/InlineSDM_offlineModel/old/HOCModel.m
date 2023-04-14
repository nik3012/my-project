function [ml_HOC_res, ml_field_HOC_corr, intra_par_HOC, HOCrespart_z2z3] = HOCModel(ml_input_HOC, lensdata, CET_model)

if nargin<3
    CET_model ='';
end

if isempty(CET_model)
    [ml_HOC_res, intra_par_HOC] = ovl_metro_model(ml_input_HOC,'sdmhoc');
elseif contains(CET_model,'ovo')
%     [ml_HOC_res, intra_par_HOC] = ovl_cet_model(ml_input_HOC, CET_model);
    % calculate the correction to be applied
    [~, cs] = ovl_cet_model(ml_input_HOC, CET_model);
    % return the correction on the bmmo grid
    % intra_par_HOC is bogus here; will clean up with resdesign 
    [ml_HOC_res, intra_par_HOC] = ovl_cet_model(ml_input_HOC, cs.poly2spline(), CET_model); % replay trajectories, 'PLAYBACK' matches TS, may have delta with DB
elseif strcmp(CET_model, '33par')
    options = bl3_default_options_structure;
    [ml_HOC_res, intra_par_HOC] = ovl_model(ml_input_HOC, options.CET33par.name, 'perwafer', 'perfield');
else
    disp('error : the model type does not exist.');
end
ml_field_HOC_corr = ovl_sub(ml_input_HOC, ml_HOC_res);

ml_HOC_res_dyn = ovl_average_columns(ml_HOC_res); 
% dx, dy -> Zernikes
xs = spline( ml_HOC_res_dyn.wd.xf', ml_HOC_res_dyn.layer.wr.dx', lensdata.X);
ys = spline( ml_HOC_res_dyn.wd.xf', ml_HOC_res_dyn.layer.wr.dy', lensdata.X);

z2_HOCrespart = xs * lensdata.Generic.Lens.Factors.dZ2_dX * 1e+09; %[nm]
z3_HOCrespart = ys * lensdata.Generic.Lens.Factors.dZ3_dY * 1e+09; %[nm]

HOCrespart_z2z3.z2 = z2_HOCrespart;
HOCrespart_z2z3.z3 = z3_HOCrespart;

