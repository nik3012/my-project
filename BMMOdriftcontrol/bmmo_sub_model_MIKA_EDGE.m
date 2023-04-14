function results_out = bmmo_sub_model_MIKA_EDGE(results_in, options)
% function results_out = bmmo_sub_model_MIKA_EDGE(results_in, options)
%
% The MIKA_EDGE sub-model (MI+KA_EDGE combo model). here KA is including
% polynomial and edge.
%
% Input:
%   results_in: structure containing at least the following fields:
%               interfield_residual: 1 * max_chuck structure array of chuck-averaged 
%               overlay structures. This is the input to the MI sub-model.
%   options:    options structure
%
% Output:
%   results_out: structure containing intermediate models
%   This function modifies the following fields:
%           MI.res: 1*max_chuck array of ml structures; residual per
%               chuck id after fitting mirror model.
%           MI.Calib_MI: 1 * max chuck array of MI calibrations
%           interfield_residual: equal to MI.res
%           KA.res: 1*max_chuck array of ml structures; residual per
%               chuck id after fitting mirror model.
%           KA.Calib_KA: 1 * max chuck array of KA-grid (with edge model) calibrations.
%           BAO.before_MIKA_EDGE: BAO content removed before MIKA-modelling, for
%               ebug purpose only.
%           BAO.BAO_in_MIKA_EDGE: BAO content of MIKA_EDGE-combo model for crosstalk
%               estimation, for debug purpose only.
%
%   *** N.B. *** 
%   MI(2) is the structure for chuck id 2, even if chuck id 2 is the
%   only chuck id used

results_out = results_in;
model = 'MIKA_EDGE';

%mi_input = results_out.interfield_residual;
% Reduce SDM fields to 7x7, edges are dense. Shall the edges be the same: 7x7?
for chuck_id = options.chuck_usage.chuck_id_used
    [mi_input(chuck_id), results_out.BAO.before_MIKA(chuck_id)] = bmmo_model_BAO(results_out.interfield_residual(chuck_id), options);
    out_ml_new(chuck_id) = bmmo_convert_layout2_7(mi_input(chuck_id),'x', options.fid_intrafield);
    out_ml_new(chuck_id) = bmmo_convert_layout2_7(out_ml_new(chuck_id),'y', options.fid_intrafield);
end

mi_input = out_ml_new;


% Construct FPS for MI+KA, KA-fps contains only terms from 2nd order
 [fps, C] = bmmo_construct_FPS(mi_input, options, model);

mli = mi_input;

% Run the MI+KA combined model
[fit_coeffs, fitted_fps, res] = bmmo_combined_model(mli, fps, options, C);
for ichk=1:2
    fitted_fps.KA(ichk) = ovl_add(fitted_fps.KA_POLY(ichk), fitted_fps.KA_EDGE(ichk));
    fit_coeffs.KA{ichk} = [fit_coeffs.KA_POLY{ichk}; fit_coeffs.KA_EDGE{ichk}];
end

% calculate MI part as sum of MIX and MIY
for chuck_id = options.chuck_usage.chuck_id_used
    fitted_fps.MI(chuck_id) = ovl_add(fitted_fps.MIX(chuck_id), fitted_fps.MIY(chuck_id));
end

% MI+KA map consistency, convert and update
for chuck_id = options.chuck_usage.chuck_id_used

    % Initial fit mirrors
    [res_MI(chuck_id), results_out.MI.Calib_MI(chuck_id)]= bmmo_generate_mirrors(mli(chuck_id), fit_coeffs.MIX{chuck_id},fit_coeffs.MIY{chuck_id}, options);
    
	% find the linear terms in the resulting maps when interpolated to 7x7
    % layout and remove it from MI
    fp_tmp = bmmo_mirror_fingerprint(bmmo_get_layout(fitted_fps.MI(chuck_id), options.reduced_reticle_layout, options), results_out.MI.Calib_MI(chuck_id), options);
    fp_tmp = ovl_combine_linear(fp_tmp, 1, mi_input(chuck_id), 0);
    [~, pars] = bmmo_fit_model(fp_tmp, options, 'tx', 'rxwfr', 'ty', 'rwy');
    
    % Remove linear terms from mirror maps, and create "final" correction
    [results_out.MI.Calib_MI(chuck_id).x_mirr, results_out.MI.Calib_MI(chuck_id).y_mirr] = bmmo_model_map_parms(results_out.MI.Calib_MI(chuck_id).x_mirr, results_out.MI.Calib_MI(chuck_id).y_mirr, options, pars);

    % Apply exposure side mirror maps to measure side  
    if options.invert_MI_wsm_sign
        results_out.MI.Calib_MI_wsm(chuck_id).x_mirr.dx = -1 * results_out.MI.Calib_MI(chuck_id).x_mirr.dx;
        results_out.MI.Calib_MI_wsm(chuck_id).y_mirr.dy = -1 * results_out.MI.Calib_MI(chuck_id).y_mirr.dy;
    else
        results_out.MI.Calib_MI_wsm(chuck_id) = results_out.MI.Calib_MI(chuck_id);
    end  

    % Calculate mirror fingerprint (for debugging purposes)
    results_out.MI.fp(chuck_id) = bmmo_mirror_fingerprint(fitted_fps.MI(chuck_id), results_out.MI.Calib_MI(chuck_id), options);
    
    % Calculate mirror residual (for KPI, without average field)
    results_out.MI.res(chuck_id) = ovl_sub(mi_input(chuck_id), results_out.MI.fp(chuck_id));
    
    [~, results_out.KA.Calib_KA(chuck_id), results_out.KA.fp(chuck_id)] = bmmo_generate_grid(results_in.interfield_residual(chuck_id), fit_coeffs.KA{chuck_id}, options);
    
    % Apply exposure side KA grid to measure side
    if options.KA_measure_enabled
        results_out.KA.Calib_KA_meas(chuck_id) = bmmo_KA_grid_expose_to_meas(results_out.KA.Calib_KA(chuck_id), options);
    end
    % FF BAO Correction for MI and KA (for M-side)
    [results_out.BAO.ff_6par_MI(chuck_id), results_out.BAO.ff_6par_KA(chuck_id)] = bmmo_ff_bao_correction(results_out.MI.Calib_MI_wsm(chuck_id), results_out.KA.Calib_KA_meas(chuck_id), options);
    results_out.BAO.ff_6par(chuck_id) = bmmo_add_BAOs(results_out.BAO.ff_6par_MI(chuck_id), results_out.BAO.ff_6par_KA(chuck_id));
    
    % Re-calculate KA-residue from initial input, debug only info
    results_out.KA.res(chuck_id) = ovl_sub(mi_input(chuck_id), results_out.KA.fp(chuck_id));

    % Model MI+KA
    % MI+KA fingerprint (for debugging purposes, without average field) 
    results_out.MIKA.fp(chuck_id) = ovl_add(results_out.MI.fp(chuck_id), results_out.KA.fp(chuck_id));
    % Calculate MIKA-residue from initial input (without average field)
    results_out.MIKA.res(chuck_id) = ovl_sub(mi_input(chuck_id), results_out.MIKA.fp(chuck_id));
    
    % Find BAO in MIKA FP, to estimate KA-BAO crosstalk,
    [mlo, results_out.BAO.BAO_in_MIKA_EDGE(chuck_id)] = bmmo_model_BAO(ovl_combine_linear(results_out.MIKA.fp(chuck_id), -1), options);
    
    results_out.interfield_residual(chuck_id) = ovl_sub(results_out.interfield_residual(chuck_id), results_out.MIKA.fp(chuck_id));
end

