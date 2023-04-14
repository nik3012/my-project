function results_out = bmmo_sub_model_INTRAF(results_in, options)
% function results_out = bmmo_sub_model_INTRAF(results_in, options)
%
% The Intrafield sub-model
%
% Input:
%   results_in: structure containing various results from other models
%   models_in: structure containing intermediate models
%   options: options structure
%
% Output:
%   results_out: structure containing intermediate models
%       This function adds the following fields:
%           intrafield: 1*max chuck array, intrafield residual
%           *** N.B. *** 
%           intrafield(2) is the structure for chuck id 2, even if chuck id 2 is the
%           only chuck id used

results_out = results_in;

for chuck_id = options.chuck_usage.chuck_id_used
    
    % Extract the defined intrafield fields
    results_out.INTRAF.residual(chuck_id) = ovl_get_fields(results_out.intrafield_input(chuck_id), options.fid_intrafield);
      
    % remove nans from intrafield
    results_out.INTRAF.residual(chuck_id) = bmmo_repair_intrafield_nans(results_out.INTRAF.residual(chuck_id),options);
    
    % remove the WH fingerprint from intrafield
    wh_fp = ovl_get_fields(ovl_combine_linear(options.WH.input_fp_per_chuck(chuck_id), results_out.WH.lambda), options.fid_intrafield);
    results_out.INTRAF.residual(chuck_id) = ovl_sub(results_out.INTRAF.residual(chuck_id), wh_fp);   
    
    % remove the SUSD fingerprint from intrafield
    SUSD_fp = ovl_get_fields(results_in.SUSD.model_fp(chuck_id), options.fid_intrafield);
    results_out.INTRAF.residual(chuck_id) = ovl_sub(results_out.INTRAF.residual(chuck_id), SUSD_fp);
    
    % remove the MI fingerprint from intrafield
    MI_fp = bmmo_mirror_fingerprint(results_out.INTRAF.residual(chuck_id), results_in.MI.Calib_MI(chuck_id), options);
    results_out.INTRAF.residual(chuck_id) = ovl_sub(results_out.INTRAF.residual(chuck_id), MI_fp);
    
    % Remove the KA fingerprint from intrafield
    ml_KA = feval(options.KA_actuation.fnhandle, results_in.KA.Calib_KA(chuck_id), results_out.INTRAF.residual(chuck_id), options);
    results_out.INTRAF.residual(chuck_id) = ovl_sub(results_out.INTRAF.residual(chuck_id), ml_KA);
    
    % Remove BAO from intrafield
    results_out.INTRAF.residual(chuck_id) = bmmo_apply_model(results_out.INTRAF.residual(chuck_id), results_in.BAO.correction(chuck_id), -1, options);
    %results_out.INTRAF.residual(chuck_id) = ovl_model(results_out.INTRAF.residual(chuck_id),'apply',results_in.BAO.correction(chuck_id),-1);
    
    % average fields to get intrafield
    results_out.INTRAF.Calib_intra(chuck_id) = ovl_average_fields( results_out.INTRAF.residual(chuck_id));
    
    % correct for RINT microshift and remove 6 intrafield pars
    results_out.INTRAF.Calib_intra(chuck_id) = bmmo_correct_intrafield_shift(results_out.INTRAF.Calib_intra(chuck_id), options);
 
    % options.intraf_fitmodel(_all) defines 18(20)par or 33(35)par.
    % results_out.INTRAF.par18 renamed to results_out.INTRAF.par
    %[unused, results_out.INTRAF.Calib_Kfactors(chuck_id)] = ovl_model(results_out.INTRAF.Calib_intra(chuck_id), '18par, d3, flw3y');
    [~, results_out.INTRAF.Calib_Kfactors(chuck_id)] = bmmo_fit_model(results_out.INTRAF.Calib_intra(chuck_id), options, options.intraf_fitmodel_all);
    %[results_out.INTRAF.residual(chuck_id), results_out.INTRAF.par18(chuck_id)] = ovl_model(results_out.INTRAF.Calib_intra(chuck_id), '18par');
    [results_out.INTRAF.residual(chuck_id), results_out.INTRAF.par(chuck_id)] = bmmo_fit_model(results_out.INTRAF.Calib_intra(chuck_id), options, options.intraf_fitmodel);

end

