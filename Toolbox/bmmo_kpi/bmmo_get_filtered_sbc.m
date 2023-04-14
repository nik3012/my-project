function [fps, new_sbc, new_kpi] = bmmo_get_filtered_sbc(input_struct, curr_sbc, filter)
% function [fps, new_sbc, new_kpi] = bmmo_get_filtered_sbc(input_struct, curr_sbc, filter)
%
% Rerun a BMMO-NXE modelling job  offline with a given previous correction and filter setting applied 
%
% Input:
%   input_struct:  BMMO-NXE input structure
%   curr_sbc: previous sbc to use 
%   filter: 1 or 0, if time filtering is enabled or disabled
%
% Output:
%   fps_filtered: SBC2 fingerprint structures for the output sbc
%   new_sbc: output SBC2 correction
%   new_kpi:  output KPI structure
%
% 20171006 SBPR Creation

 tmp_input = input_struct;
 tmp_input.info.report_data.time_filtering_enabled = filter;

 [mlp, options] = bmmo_process_input(tmp_input);
    
 fps = bmmo_apply_SBC(input_struct, curr_sbc);
 
 % undo applied correction and apply previous modelled one
 mlp_undo = bmmo_undo_sbc_correction(mlp, options);
    
 mlp_undo = ovl_add(mlp_undo, fps.TotalSBCcorrection);
    
 %switch previous corrections into options
 options.previous_correction = curr_sbc;

 model_results = bmmo_run_submodels(mlp_undo, options);
 
 out = bmmo_process_output(input_struct, model_results, options);
    
 new_sbc = rmfield(out.corr, 'Configurations');
 new_kpi = out.report.KPI;
 

 
 