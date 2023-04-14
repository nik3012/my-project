function [pi_struct, kfactors] = bmmo_get_delta_hoc_pi_per_chuck(inter_corr, model_results, options)
% function [pi_struct, kfactors] = bmmo_get_delta_hoc_pi_per_chuck(inter_corr, model_results, options)
%
% Get k-factor delta KPI: difference between intrafield k-factors
% calculated on 7x7 full fields, vs 13x19 dense fields
%
% Input:
%   inter_corr: unfiltered interfield SBC2 delta correction (WH + MI + KA + BAO)
%   model_results: intermediate model results containing ml_outlier_removed
%   options: BMMO/BL3 options structure
%
% Output:
%   pi_struct: KPI structure with 20(35) par values per chuck
%   kfactors: delta 20(35) par values per chuck
%   20par or 35par depending on options.intraf_actuation_order

% get the 20(35)par fit for the 7x7 downsampled interfield residual (L1 only)
interfield_res = ovl_add(model_results.ml_outlier_removed, inter_corr);
interfield_res = bmmo_get_layout(ovl_get_fields(interfield_res, options.layer_fields{1}), options.reduced_reticle_layout, options);

intraf = bmmo_average_chuck(ovl_average_fields(bmmo_get_innerfields(interfield_res, options)), options);
intraf = ovl_combine_wafers(intraf(1), intraf(2));

intraf = bmmo_correct_intrafield_shift(intraf, options);
tmp_options = options;
tmp_options.chuck_usage.chuck_id = [1 2];
tmp_options.chuck_usage.chuck_id_used = [1 2];
    
kfactors = bmmo_get_kfactors_per_chuck(intraf, tmp_options);

% subtract 20(35)par kfactors from 12 dense fields
% these have already been calculated in the model
kfn = fieldnames(kfactors);
for ic = 1:2
    for ik = 1:length(kfn)  
        kfactors(ic).(kfn{ik}) = kfactors(ic).(kfn{ik}) - model_results.INTRAF.Calib_Kfactors(ic).(kfn{ik});
    end
end

% generate PI struct
pi_struct = bmmo_get_hoc_pi_struct(kfactors, '_compare_delta', options);

