function results_out = bmmo_sub_model_MI(results_in, options)
% function results_out = bmmo_sub_model_MI(results_in, options)
%
% The MI sub-mdel
%
% Input:
%   results_in: structure containing at least the following fields:
%           interfield_residual: 1 * max_chuck structure array of chuck-averaged
%           overlay structures. This is the input to the MI sub-model.
%   options: options structure
%
% Output:
%   results_out: structure containing intermediate models
%       This function modifies the following fields:
%           MI.res: 1*max_chuck array of ml structures; residual per
%               chuck id after fitting mirror model.
%           MI.Calib_MI: 1 * max chuck array of MI calibrations
%           interfield_residual: equal to MI.res
%           BAO.tenpar_before_MI: 10 par parameters removed before
%               mirror is modelled
%
%   *** N.B. ***
%   MI(2) is the structure for chuck id 2, even if chuck id 2 is the
%   only chuck id used

model = 'MI';
results_out = results_in;

for chuck_id = options.chuck_usage.chuck_id_used
    % initialize input (per-chuck residual of WH model)
    mi_input(chuck_id) = results_out.interfield_residual(chuck_id);
    
    % remove average field
    mi_input(chuck_id) = bmmo_remove_average_field(mi_input(chuck_id), options); 
    
    if ~isempty(options.fid_intrafield)
        out_ml_new(chuck_id) = bmmo_convert_layout2_7(mi_input(chuck_id),'x', options.fid_intrafield);
        out_ml_new(chuck_id) = bmmo_convert_layout2_7(out_ml_new(chuck_id),'y', options.fid_intrafield);
    else
        out_ml_new(chuck_id) = mi_input(chuck_id);
    end
    if ~isempty(options.fid_left_right_edgefield)
        mli_MIX(chuck_id) = bmmo_convert_layout2_7(out_ml_new(chuck_id),'y', options.fid_left_right_edgefield);
    else
        mli_MIX(chuck_id)  = out_ml_new(chuck_id) ;
    end
    if ~isempty(options.fid_top_bottom_edgefield)
        mli_MIY(chuck_id) = bmmo_convert_layout2_7(out_ml_new(chuck_id),'x', options.fid_top_bottom_edgefield);
    else
        mli_MIY(chuck_id) = out_ml_new(chuck_id) ;
    end
    
    mli_MI(chuck_id) = mi_input(chuck_id);
    mli_MI(chuck_id).layer.wr.dx = mli_MIX(chuck_id).layer.wr.dx;
    mli_MI(chuck_id).layer.wr.dy = mli_MIY(chuck_id).layer.wr.dy;
end

[fps, C] = bmmo_construct_FPS(mli_MI, options, model);
fit_coeffs = bmmo_combined_model(mli_MI, fps, options, C);

for chuck_id = options.chuck_usage.chuck_id_used
    % model mirror maps (spline fit)
    [~, results_out.MI.Calib_MI(chuck_id)] = bmmo_generate_mirrors(mi_input(chuck_id), fit_coeffs.MIX{chuck_id}, fit_coeffs.MIY{chuck_id}, options);
    
    % find the linear terms in the resulting maps when interpolated to 7x7
    % layout
    fp_tmp = bmmo_mirror_fingerprint(bmmo_get_layout(mi_input(chuck_id), options.reduced_reticle_layout, options), results_out.MI.Calib_MI(chuck_id), options);
    % get fp on meas layout
    fp_tmp = ovl_combine_linear(fp_tmp, 1, mi_input(chuck_id), 0);
    [~, pars(chuck_id)] = bmmo_fit_model(fp_tmp, options, 'tx', 'rxwfr', 'ty', 'rwy');
    
    % Remove linear terms from mirror maps
    [results_out.MI.Calib_MI(chuck_id).x_mirr, results_out.MI.Calib_MI(chuck_id).y_mirr] = bmmo_model_map_parms(results_out.MI.Calib_MI(chuck_id).x_mirr, results_out.MI.Calib_MI(chuck_id).y_mirr, options, pars(chuck_id));
    
    % Apply exposure side mirror maps to measure side
    if options.invert_MI_wsm_sign
        results_out.MI.Calib_MI_wsm(chuck_id).x_mirr.dx = -1 * results_out.MI.Calib_MI(chuck_id).x_mirr.dx;
        results_out.MI.Calib_MI_wsm(chuck_id).y_mirr.dy = -1 * results_out.MI.Calib_MI(chuck_id).y_mirr.dy;
    else
        results_out.MI.Calib_MI_wsm(chuck_id) = results_out.MI.Calib_MI(chuck_id);
    end
    
    % FF BAO Correction
    results_out.BAO.ff_6par(chuck_id) = bmmo_ff_bao_correction(results_out.MI.Calib_MI_wsm(chuck_id), results_out.KA.Calib_KA_meas(chuck_id), options);
    
    % Calculate mirror fingerprint (for debugging purposes)
    results_out.MI.fp(chuck_id) = bmmo_mirror_fingerprint(mi_input(chuck_id), results_out.MI.Calib_MI(chuck_id), options);
    
    % Calculate mirror residual (for KPI)
    results_out.MI.res(chuck_id) = ovl_sub(mi_input(chuck_id), results_out.MI.fp(chuck_id));    
    results_out.interfield_residual(chuck_id) = ovl_sub(results_out.interfield_residual(chuck_id), results_out.MI.fp(chuck_id));
end

