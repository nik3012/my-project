function model_results = bmmo_run_submodels(ml, options)
% function model_results = bmmo_run_submodels(ml, options)
%
% Run each sub-model in the sequence specified in options.model_sequence,
% storing the results in model_results
%
% Input:
%       ml:                 ml structure after processing
%       options:            bmmo options structure as defined in
%                           bmmo_default_options_structure
%
% Output:
%       model_results:      structure containing submodel residuals and
%                           calibrations, with the following fields
%       ml_outlier_removed: ml structure with outliers removed
%       outlier_stats:      statistics on removed outliers
%       interfield_residual:residual of Interfield submodels (WH, MI, KA, BAO)
%       WH:                 structure containing the following WH data:
%       Calib_WH:           IR2EUV ratio, delta
%       ml_7x7:             Input structure sampled to 7x7 fields
%       FPS:                Raw FPS for WH combined model
%       fp:                 Fitted WH fingerprint, per chuck
%       fp_per_chuck:       Full WH fingerprint per chuck
%       fitted_fps:         Fitted FPS from the WH combined model, per chuck
%       res_7x7:            Residual after removing WH fingerprint, per chuck
%       lambda:             WH lambda value
%       residual:           Residual after removing full WH fingerprint                 
%       SUSD:               structure containing the following SUSD data:
%       Calib_SUSD:         SUSD calibrations
%       fp:                 Raw SUSD fingerprint for combined model
%       fitted_fp:          fitted SUSD fingerprint
%       MI:                 structure containing the following MI data:
%       Calib_MI:           Mirror Map corrections
%       res:                residual after removing mirror model
%       KA:                 structure containing the following KA data:
%       Calib_KA:           KA grid corrections
%       res:                residual after removing KA grid
%       INTRAF:             structure containing the following intrafield data:
%       Calib_Kfactors:     intrafield 20par coefficients
%       Calib_intra:        intrafield calibration
%       residual:           intrafield residual
%       par18:              intrafield 18par coefficients
%       BAO:                structure containing the following interfield data:
%       correction:         BAO corrections

mli = ml;
sbc_prev = struct;

% If specified, undo previous correction before modelling
if options.undo_before_modelling > 0
    [mli, sbc_prev] = bmmo_undo_sbc_correction(mli, options);
end

if options.bl3_model
    if isfield(options, 'cet_residual') && ~isempty(options.cet_residual)
       mli = ovl_add(mli, options.cet_residual);
    else
       % For offline convergence testing
       [~, ml_KA_act_NCE] = bmmo_KA_SBC_fingerprint(mli, options.previous_correction.KA.grid_2de, options);
       mli = ovl_add(mli, ml_KA_act_NCE);
    end
end

% Perform outlier removal
if options.do_outlier_removal
   [mli, outlier_stats] = bmmo_outlier_removal(mli, options);
   % backwards compatibility
   if options.WH.use_raw
        options.WH.raw = bmmo_outlier_removal(options.WH.raw, options);
   end
else
    outlier_stats = bmmo_default_outlier_stats(mli);
end

% Initialise the model results that will be needed
model_results = bmmo_default_model_result(mli, options);
model_results.outlier_stats = outlier_stats;
model_results.sbc_prev = sbc_prev;

% Execute all submodels in options.submodel_sequence, in order
for isub = 1:length(options.submodel_sequence)
    model_results = feval(options.submodels.(options.submodel_sequence{isub}).fnhandle, model_results, options);
end

if isfield(model_results.BAO, 'ff_6par')
    for chuck_id = options.chuck_usage.chuck_id_used
        model_results.BAO.correction(chuck_id) = bmmo_add_BAOs(...
           model_results.BAO.correction(chuck_id), ...
           model_results.BAO.ff_6par(chuck_id)); 
    end
end