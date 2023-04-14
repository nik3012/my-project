function [report, model_results] = bmmo_generate_lcp_report(mli, model_results, kpi_corr, options)
% function [report, model_results] = bmmo_generate_lcp_report(mli, model_results, kpi_corr, options)
%
% Process the results of BMMO-NXE and BL3 modelling, required for generating
% Waferdatamaps and Job report (KPIs) results as described in EDS D000810611
%
% Input:
%   mli: original input structure
%   model_results:  structure containing results of modelling
%   kpi_corr: structure containing the following SBC correction structures
%     delta_filtered
%     delta_unfiltered
%     total_filtered (equal to the SBC correction sent to TS)
%     total_unfiltered 
%   options: BMMO/BL3 options structure
%
% Output:
%   report: KPI/PI report structure as defined in EDS D000810611
%   model_results: structure containing results of modelling (processed for
%   WDMs and other outputs)

% Undo previous SBC corrections
[model_results.uncontrolled, model_results.sbc_prev] = bmmo_undo_sbc_correction(model_results.ml_outlier_removed, options);

% get previously applied inline SDM
model_results.previous_actuated_inlineSDM = ovl_average_fields(ovl_get_fields(model_results.sbc_prev.INTRAF, options.fid_intrafield));
model_results.previous_actuated_inlineSDM = bmmo_shift_fields(model_results.previous_actuated_inlineSDM, -options.x_shift, -options.y_shift);

% Get current SBC correction: filtered/unfiltered, total/delta
field_entries = fieldnames(kpi_corr);
tmp_options = options;
INVALID_VAL = 0;
mlo_wo_readout_nans = bmmo_replace_invalids(model_results.ml_outlier_removed, model_results.readout_nans, INVALID_VAL);
mlo = bmmo_replace_invalids(mlo_wo_readout_nans, model_results.outlier_stats.layer.wafer, INVALID_VAL);

%  Estimate ff 6par fingerprint for all field entries
ff6p.applied          =  bmmo_ff_6par_fingerprint(mlo, options.previous_correction.MI.wsm, options.previous_correction.KA.grid_2dc, options);
ff6p.delta_unfiltered =  bmmo_ff_6par_fingerprint(mlo, kpi_corr.delta_unfiltered.MI.wsm, kpi_corr.delta_unfiltered.KA.grid_2dc, options);
ff6p.delta_filtered   =  ovl_combine_linear(ff6p.delta_unfiltered ,options.filter.coefficients.BAO);
ff6p.total_filtered   =  ovl_add(ff6p.applied, ff6p.delta_filtered);
ff6p.total_unfiltered =  ovl_add(ff6p.applied, ff6p.delta_unfiltered);

for ifield = 1:length(field_entries)
    intraf = bmmo_INTRAF_SBC_fingerprint(mlo, kpi_corr.(field_entries{ifield}).ffp, options);
    tmp_options.previous_correction.IR2EUV = kpi_corr.(field_entries{ifield}).IR2EUV;

    % save the sbc fps to model results structure
    model_results.(field_entries{ifield}) = bmmo_get_sbc_fingerprints(intraf, tmp_options, kpi_corr.(field_entries{ifield}), ff6p.(field_entries{ifield}));
    kpi_corr.(field_entries{ifield}).total_correction = model_results.(field_entries{ifield}).TotalSBCcorrection;
    kpi_corr.(field_entries{ifield}).ml_bao = model_results.(field_entries{ifield}).BAO;
    kpi_corr.(field_entries{ifield}).ml_intraf = bmmo_ffp_to_ml_simple(kpi_corr.(field_entries{ifield}).ffp);
    kpi_corr.(field_entries{ifield}).inter_corr = ovl_sub(kpi_corr.(field_entries{ifield}).total_correction, intraf);
    kpi_corr.(field_entries{ifield}).intraf_par = intraf; % was intraf_18par (or intraf_33par)
    
    % add Intrafield raw fp to the struct
    model_results.(field_entries{ifield}).INTRAF_raw = kpi_corr.(field_entries{ifield}).ml_intraf;
    % 18 (33) par NCE wdm, with field name INTRAF_18par_NCE (or 33par)
    model_results.(field_entries{ifield}).(options.intraf_nce_modelresult.name) = ovl_model(kpi_corr.(field_entries{ifield}).ml_intraf, 'perwafer', options.intraf_CETpar.name);
end
model_results.total_correction = kpi_corr.total_filtered.total_correction;

% Calculate the model residual
model_results.res = ovl_add(model_results.ml_outlier_removed, kpi_corr.delta_filtered.total_correction);

report.PI = bmmo_generate_PI(mli, model_results, options);
report.KPI = bmmo_generate_KPI(mli, model_results, kpi_corr, options);

report.filter = bmmo_generate_filter_report(options);
