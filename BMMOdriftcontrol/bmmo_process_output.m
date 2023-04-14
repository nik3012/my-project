function [out, wdms] = bmmo_process_output(mli, model_results, options)
% function out = bmmo_process_output(mli, Model_result, options)
%
% Process the results of BMMO/BL3 modelling, creating the correction set structure
% and KPI structure as defined in the D000810611 EDS BMMO NXE drift control model
%
% Input:
%   mli: original input structure
%   model_results: structure containing results of modelling
%   options: BMMO/BL3 options structure
%
% Output:
%   Out: structure containing the following fields
%        corr: correctibles
%        KPI: KPI data
%        errlist: empty cell structure
%   wdms: waferdatamaps from modelled corrections

[out, kpi_out] = bmmo_organize_model_results(model_results,options);

model_results.readout_nans = bmmo_count_readout_nans(mli);

if options.bl3_model % Add NCE to ml_outlier_removed input
    if isfield(options, 'cet_residual') && ~isempty(options.cet_residual)
        model_results.ml_outlier_removed = ovl_sub(model_results.ml_outlier_removed, options.cet_residual);
    end
end

[out.report, model_results] = bmmo_generate_lcp_report(mli, model_results, kpi_out, options);
if isfield(mli, 'diagnostics_path')
    bmmo_save_wfrdatamaps(mli, model_results, kpi_out, options);
end

if nargout > 1
    wdms = bmmo_generate_WDM(model_results, options);
end

out.corr = bmmo_KA_remove_interpolants(out.corr);
out.invalid = bmmo_create_invalidated_data(mli, model_results);