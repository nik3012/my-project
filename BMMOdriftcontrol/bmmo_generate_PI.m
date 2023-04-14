function perf_indicators = bmmo_generate_PI(mli, model_results, options)
% function perf_indicators = bmmo_generate_PI(mli, model_results, options)
%
% Process the results of BMMO-NXE and BL3 modelling, creating the PI structure
% as defined in EDS D000810611
%
% Input:
%   mli: original input structure
%   model_results: structure containing results of modelling
%   options: BMMO/BL3 options structure
%
% Output:
%   perf_indicators: perf_indicators structure as defined in D000810611

ml_mmo = bmmo_model_mmo(model_results.ml_outlier_removed, options);
perf_indicators.uncontrolled.mmo = bmmo_get_ov_pi_per_chuck_stacked(ml_mmo, options);

%perf_indicators.control_repro.no10par = bmmo_get_ov_pi_per_chuck(ovl_model(model_results.total_correction), options);



for chuck_id = 1:2   
    wafer_on_this_chuck = find(options.chuck_usage.chuck_id == chuck_id);
    chuck_string = num2str(chuck_id);
       
    %% Calculate correctables : Control repro
    
%     ml_corr_inter = ovl_sub(ovl_average(ovl_get_wafers(model_results.sub_model_input, wafer_on_this_chuck)), model_results.interfield_residual(chuck_id));
%     ml_corr = ovl_model(ml_corr_inter, 'apply', model_results.INTRAF.par18(chuck_id), -1);
%     
    % Fill in PI Control Repro
    Corr_delta = ovl_get_wafers(model_results.total_correction, wafer_on_this_chuck);
    Corr_delta_no10par = ovl_model(Corr_delta, '10par');
    overlay_corr_delta = ovl_calc_overlay(Corr_delta);
    overlay_corr_delta_no10par = ovl_calc_overlay(Corr_delta_no10par);

    perf_indicators.control_repro.(['ovl_chk' chuck_string '_repro_x_997']) = overlay_corr_delta.ox997;
    perf_indicators.control_repro.(['ovl_chk' chuck_string '_repro_y_997']) = overlay_corr_delta.oy997;
    perf_indicators.control_repro.(['ovl_chk' chuck_string '_repro_wo10par_x_997']) = overlay_corr_delta_no10par.ox997;
    perf_indicators.control_repro.(['ovl_chk' chuck_string '_repro_wo10par_y_997']) = overlay_corr_delta_no10par.oy997;
          
end
    
