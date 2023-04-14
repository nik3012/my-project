function kpi = bmmo_generate_KPI(mli, model_results, kpi_corr, options)
% function kpi = bmmo_generate_KPI(mli, model_results, kpi_corr, options)
%
% Process the results of BMMO-NXE and BL3 modelling, creating the KPI structure
% as defined in D000810611 EDS BMMO NXE drift control model functional
%
% Input:
%   mli: original input structure
%   model_results: structure containing results of modelling
%   kpi_corr: structure containing the following SBC correction structures
%     delta_filtered
%     delta_unfiltered
%     total_filtered (equal to the SBC correction sent to TS)
%     total_unfiltered 
%   options: BMMO/BL3 options structure
%
% Output:
%   kpi: KPI structure as defined in FN EDS D000810611
 
if nargin < 4
    options = bmmo_default_options_structure;
end

%% Uncontrolled KPI
kpi.uncontrolled.overlay = bmmo_get_ov_pi_per_chuck_stacked(model_results.uncontrolled, options);
% without HO model parameters of last applied SBC2 correction
% apply every correction except INTRAF
corr_no_intraf = ovl_sub(model_results.sbc_prev.TotalSBCcorrection, model_results.sbc_prev.INTRAF);
kpi.uncontrolled.intrafield = bmmo_get_hoc_pi_per_chuck_stacked(ovl_add(model_results.uncontrolled, corr_no_intraf), options, '');
%kpi.uncontrolled.intrafield = bmmo_get_hoc_pi_per_chuck(model_results.sbc_prev.INTRAF, options, '_mean_uncontrolled');
kpi.uncontrolled.intrafield = bmmo_get_ripple_kpi(ovl_add(model_results.uncontrolled, corr_no_intraf), options, kpi.uncontrolled.intrafield);

%% Applied correction KPI
fps_applied_WH = bmmo_WH_SBC_fingerprint(model_results.delta_filtered.BAO, options);
overlay_ml_wh_corr = ovl_calc_overlay(fps_applied_WH);
if strcmp(options.platform, 'LIS')
    kpi.applied.waferheating.ovl_max_dx_whc_applied = overlay_ml_wh_corr.ox100;
    kpi.applied.waferheating.ovl_max_dy_whc_applied = overlay_ml_wh_corr.oy100;
else
    kpi.uncontrolled.waferheating.ovl_exp_grid_dx_whc_uncontrolled = overlay_ml_wh_corr.ox100;
    kpi.uncontrolled.waferheating.ovl_exp_grid_dy_whc_uncontrolled = overlay_ml_wh_corr.oy100;
end

%% Input KPI
kpi.input.overlay = bmmo_get_ov_pi_per_chuck_stacked(model_results.ml_outlier_removed, options);
kpi.input.outlier_coverage = bmmo_get_outlier_density(mli, model_results, options);
[kpi.input.valid, kpi.input.w2w] = sub_get_input_kpi_per_chuck(mli, model_results, options);

%% Correction KPI
field_entries = fieldnames(kpi_corr);
tmp_options = options;
tmp_options.chuck_usage.chuck_id =  [1 2];

for ifield = 1:length(field_entries)
    kpi.correction.(field_entries{ifield}).waferheating.ovl_exp_grid_whc = kpi_corr.(field_entries{ifield}).IR2EUV;
    if options.susd_control
        kpi.correction.(field_entries{ifield}).susd = sub_get_susd_correction_kpi_per_chuck(kpi_corr.(field_entries{ifield}).SUSD);
    end
    kpi.correction.(field_entries{ifield}).mirror = sub_get_mirror_kpi_per_chuck(kpi_corr.(field_entries{ifield}), options);
    kpi.correction.(field_entries{ifield}).grid.exp = sub_get_grid_exp_kpi_per_chuck(kpi_corr.(field_entries{ifield}), options);
    kpi.correction.(field_entries{ifield}).grid.meas = sub_get_grid_meas_kpi_per_chuck(kpi_corr.(field_entries{ifield}), tmp_options);
    kpi.correction.(field_entries{ifield}).bao = sub_get_bao_kpi_per_chuck(kpi_corr.(field_entries{ifield}).ml_bao, kpi_corr.(field_entries{ifield}), options);
    kpi.correction.(field_entries{ifield}).k_factors = bmmo_get_hoc_pi_per_chuck_average(kpi_corr.(field_entries{ifield}).ml_intraf, options, '');
    kpi.correction.(field_entries{ifield}).intra_raw = bmmo_get_ov_pi_per_chuck_average(kpi_corr.(field_entries{ifield}).ml_intraf, tmp_options);
    kpi.correction.(field_entries{ifield}).total = bmmo_get_ov_pi_per_chuck_average(kpi_corr.(field_entries{ifield}).total_correction, options);
    kpi.correction.(field_entries{ifield}).(options.intraf_corr_par.name) = bmmo_get_ov_pi_per_chuck_average(kpi_corr.(field_entries{ifield}).intraf_par, options);
end

Intra_NCE_field_entries = {'total_filtered','total_unfiltered'};
for ifield = 1:length(Intra_NCE_field_entries)
    if strcmp(options.platform, 'LIS')
        % LIS 
        kpi.(options.intraf_nce_kpi.name).(Intra_NCE_field_entries{ifield})=  bmmo_get_ov_pi_per_chuck_average(model_results.(Intra_NCE_field_entries{ifield}).(options.intraf_nce_modelresult.name), tmp_options);
    else
        % OTAS 
        Intra_NCE = bmmo_fit_model_perwafer(kpi_corr.(Intra_NCE_field_entries{ifield}).ml_intraf,options,'18par');
        kpi.correction.(Intra_NCE_field_entries{ifield}).Intrafield_18par_NCE =  bmmo_get_ov_pi_per_chuck_average(Intra_NCE, tmp_options);
    end
end


% remove fields to match the (VCP) job report structure
if strcmp(options.platform, 'LIS')
    fd = fieldnames(kpi.(options.intraf_nce_kpi.name).total_filtered);
    idx = contains(fd, '3std');
    new_fd1 = fd(idx);
    for i = 1:length(new_fd1)
        kpi.(options.intraf_nce_kpi.name).total_filtered = rmfield(kpi.(options.intraf_nce_kpi.name).total_filtered, new_fd1{i});
        kpi.(options.intraf_nce_kpi.name).total_unfiltered = rmfield(kpi.(options.intraf_nce_kpi.name).total_unfiltered, new_fd1{i});
    end
end

kpi.correction.monitor.susd = sub_get_susd_monitor_kpi_per_chuck(model_results);
kpi.correction.monitor.intra_delta = bmmo_get_delta_hoc_pi_per_chuck(kpi_corr.delta_unfiltered.inter_corr, model_results, options);


%% Correction Quality KPI
kpi.residue.overlay = bmmo_get_ov_pi_per_chuck_stacked(model_results.res, options);
kpi.residue.interfield = bmmo_get_res_breakdown(model_results.res, options);
kpi.residue.intrafield = sub_get_res_intrafield(model_results, options);

%% ERO Controlled input clamp KPI, remember that ml_outlier_removed is NCE-corrected
% Input Clamp: controlled_clamp_estimate = controlled_overlay+delta_unfiltered_correction_overlay - delta_unfiltered_KA_exposure_grid
controlled_meas = bmmo_average_chuck(model_results.ml_outlier_removed, options);
TotalSBCcorrection = bmmo_average_chuck(model_results.delta_unfiltered.TotalSBCcorrection, options);
KA = bmmo_average_chuck(model_results.delta_unfiltered.KA, options);
for iC = 1:2
    wdm_clamp(iC) = ovl_add(controlled_meas(iC), TotalSBCcorrection(iC));
    wdm_clamp(iC) = ovl_sub(wdm_clamp(iC), KA(iC));
    wdm_clamp(iC) = ovl_model(wdm_clamp(iC), '6parwafer');
end
kpi.input.input_clamp = bmmo_get_KPI_ERO(wdm_clamp, 'controlled', options.ERO.inner_radius, options.ERO.edge_radius, options.ERO.outer_radius_input);

%% ERO Uncontrolled input clamp KPI
% Input Clamp: uncontrolled_clamp_estimate = uncontrolled_overlay+total_unfiltered_correction_overlay - total_unfiltered_KA_exposure_grid
uncontrolled_meas = bmmo_average_chuck(model_results.uncontrolled, options);
TotalSBCcorrection = bmmo_average_chuck(model_results.total_unfiltered.TotalSBCcorrection, options);
KA = bmmo_average_chuck(model_results.total_unfiltered.KA, options);
for iC = 1:2
    wdm_clamp(iC) = ovl_add(uncontrolled_meas(iC), TotalSBCcorrection(iC));
    wdm_clamp(iC) = ovl_sub(wdm_clamp(iC), KA(iC));
    wdm_clamp(iC) = ovl_model(wdm_clamp(iC), '6parwafer');
end
kpi.uncontrolled.input_clamp = bmmo_get_KPI_ERO(wdm_clamp, 'uncontrolled', options.ERO.inner_radius, options.ERO.edge_radius, options.ERO.outer_radius_input);

%% ERO Modelled clamp (KA) KPI, R = 0.1470001 due to calculation precision
for iC = 1:2
    modelled_clamp(iC) = bmmo_KA_grid_to_ml(kpi_corr.total_filtered.KA.grid_2de(iC));
end
kpi.correction.total_filtered.clamp = bmmo_get_KPI_ERO(modelled_clamp, 'modelled', options.ERO.inner_radius, options.ERO.edge_radius, options.ERO.outer_radius_KA);


%% End of main function, sub-functions below

%% Fill in PI input - valids
function [inputvalid, w2w] = sub_get_input_kpi_per_chuck(mli, model_results, options)
for ic = 1:2
    chuck_string = num2str(ic);
    wafers_this_chuck = find(options.chuck_usage.chuck_id == ic);
    ml_this_chuck = ovl_get_wafers(mli, wafers_this_chuck);
    ml_average_this_chuck = bmmo_average(ml_this_chuck);
    stat_this_chuck = sub_calc_meas_stat(ml_average_this_chuck);
    outlier_this_chuck = sub_calc_outlier_stat(model_results.outlier_stats, wafers_this_chuck);
    
    inputvalid.(['ovl_exp_grid_chk' chuck_string '_nr_valids'])       = stat_this_chuck.nr_valid;
    inputvalid.(['ovl_exp_grid_chk' chuck_string '_nr_readout_nans']) = stat_this_chuck.nr_nans;
    inputvalid.(['ovl_exp_grid_chk' chuck_string '_nr_outliers'])     = outlier_this_chuck;
    inputvalid.(['ovl_exp_grid_chk' chuck_string '_nr_invalids'])     = outlier_this_chuck + stat_this_chuck.nr_nans;
    
    ml_repro_this_chuck = ovl_sub(ml_this_chuck, ml_average_this_chuck);
    overlay_this_chuck = ovl_calc_overlay(ml_repro_this_chuck);
    
    w2w.(['ovl_exp_grid_chk' chuck_string '_max_w2w_var']) = max(overlay_this_chuck.ox3sd, overlay_this_chuck.oy3sd);
end


function mirrkpi = sub_get_mirror_kpi_per_chuck(model_results, options)
% Constant definitions
MI_MAP_WAFER = find(abs(model_results.MI.wse(options.chuck_usage.chuck_id_used(1)).x_mirr.y) < ((options.wafersize / 2) + options.map_param.pitch)); % Parts of MI map on wafer

for chuck_id = 1:2
    chuck_string = num2str(chuck_id);
    kpifields = {'meas', 'exp'};
    sbcfields = {'wsm', 'wse'};
    
    for i = 1:length(sbcfields)
        dxmap = model_results.MI.(sbcfields{i})(chuck_id).x_mirr.dx;
        dymap = model_results.MI.(sbcfields{i})(chuck_id).y_mirr.dy;
        
        mirrkpi.(kpifields{i}).(['ovl_exp_ytx_max_full_chk' chuck_string])  = max(abs(dxmap));
        mirrkpi.(kpifields{i}).(['ovl_exp_xty_max_full_chk' chuck_string])  = max(abs(dymap));
        mirrkpi.(kpifields{i}).(['ovl_exp_ytx_max_wafer_chk' chuck_string]) = max(abs(dxmap(MI_MAP_WAFER)));
        mirrkpi.(kpifields{i}).(['ovl_exp_xty_max_wafer_chk' chuck_string]) = max(abs(dymap(MI_MAP_WAFER)));
        mirrkpi.(kpifields{i}).(['ovl_exp_ytx_997_full_chk' chuck_string])  = sub_calc_997(dxmap);
        mirrkpi.(kpifields{i}).(['ovl_exp_xty_997_full_chk' chuck_string])  = sub_calc_997(dymap);
        mirrkpi.(kpifields{i}).(['ovl_exp_ytx_997_wafer_chk' chuck_string]) = sub_calc_997(dxmap(MI_MAP_WAFER));
        mirrkpi.(kpifields{i}).(['ovl_exp_xty_997_wafer_chk' chuck_string]) = sub_calc_997(dymap(MI_MAP_WAFER));
        mirrkpi.(kpifields{i}).(['ovl_exp_ytx_m3s_full_chk' chuck_string])  = sub_calc_m3s(dxmap);
        mirrkpi.(kpifields{i}).(['ovl_exp_xty_m3s_full_chk' chuck_string])  = sub_calc_m3s(dymap);
        mirrkpi.(kpifields{i}).(['ovl_exp_ytx_m3s_wafer_chk' chuck_string]) = sub_calc_m3s(dxmap(MI_MAP_WAFER));
        mirrkpi.(kpifields{i}).(['ovl_exp_xty_m3s_wafer_chk' chuck_string]) = sub_calc_m3s(dymap(MI_MAP_WAFER));
    end
end


function baokpi = sub_get_bao_kpi_per_chuck(mli, model_results, options)
for chuck_id = 1:2
    chuck_string = num2str(chuck_id);
    bao = model_results.BAO(chuck_id);
    baokpi.(['ovl_translation_x_chk' chuck_string '_delta'])    = bao.TranslationX;
    baokpi.(['ovl_translation_y_chk' chuck_string '_delta'])    = bao.TranslationY;
    baokpi.(['ovl_sym_intra_mag_chk' chuck_string '_delta'])    = bao.Magnification;
    baokpi.(['ovl_asym_intra_mag_chk' chuck_string '_delta'])   = bao.AsymMagnification;
    baokpi.(['ovl_sym_intra_rot_chk' chuck_string '_delta'])    = bao.Rotation;
    baokpi.(['ovl_asym_intra_rot_chk' chuck_string '_delta'])   = bao.AsymRotation;
    baokpi.(['ovl_wafer_exp_x_chk' chuck_string '_delta'])      = bao.ExpansionX;
    baokpi.(['ovl_wafer_exp_y_chk' chuck_string '_delta'])      = bao.ExpansionY;
    baokpi.(['ovl_wafer_rot_chk' chuck_string '_delta'])        = bao.InterfieldRotation;
    baokpi.(['ovl_wafer_non_ortho_chk' chuck_string '_delta'])  = bao.NonOrtho;
end
baokpi = bmmo_get_ov_pi_per_chuck_average(mli, options, baokpi);


function gridexpkpi = sub_get_grid_exp_kpi_per_chuck(model_results, options)
ml_ka_exp = bmmo_KA_SBC_fingerprint(model_results.total_correction, model_results.KA.grid_2de, options);
gridexpkpi = bmmo_get_ov_pi_per_chuck_average(ml_ka_exp, options);


function gridmeaskpi = sub_get_grid_meas_kpi_per_chuck(model_results, options)

for ichuck = 1:2
    ml_ka_meas(ichuck) = bmmo_KA_grid_to_ml(model_results.KA.grid_2dc(ichuck));
end
ml_ka_meas = ovl_remove_edge(ovl_combine_wafers(ml_ka_meas(1), ml_ka_meas(2)), options.edge_clearance);
gridmeaskpi = bmmo_get_ov_pi_per_chuck_stacked(ml_ka_meas, options);


function susdkpi = sub_get_susd_correction_kpi_per_chuck(susd_corr)
su_index = 2;
for chuck_id = 1:2
    susdkpi.(['ovl_exp_grid_chk' num2str(chuck_id) '_ty_susd']) = susd_corr(chuck_id*su_index).TranslationY;
end


function susdkpi = sub_get_susd_monitor_kpi_per_chuck(model_results)
for chuck_id = 1:2
    susdkpi.(['ovl_exp_grid_chk' num2str(chuck_id) '_ty_susd']) = model_results.SUSD.Monitor_SUSD(chuck_id);
end


function resintra = sub_get_res_intrafield(model_results, options)
for chuck_id = 1:2
    chuck_string = num2str(chuck_id);
    Res_delta          = ovl_sub(model_results.INTRAF.Calib_intra(chuck_id), model_results.INTRAF.residual(chuck_id));
    overlay_res_after  = ovl_calc_overlay(model_results.INTRAF.residual(chuck_id));
    overlay_res_before = ovl_calc_overlay(model_results.INTRAF.Calib_intra(chuck_id));
    overlay_res_delta  = ovl_calc_overlay(Res_delta);
    
    resintra.(['ovl_exp_field_HO_res_x_before_chk' chuck_string])  = overlay_res_before.ox100;
    resintra.(['ovl_exp_field_HO_res_y_before_chk' chuck_string])  = overlay_res_before.oy100;
    resintra.(['ovl_exp_field_HO_res_x_res_chk' chuck_string])     = overlay_res_after.ox100;
    resintra.(['ovl_exp_field_HO_res_y_res_chk' chuck_string])     = overlay_res_after.oy100;
    resintra.(['ovl_exp_field_HO_res_x_delta_chk' chuck_string])   = overlay_res_delta.ox100;
    resintra.(['ovl_exp_field_HO_res_y_delta_chk' chuck_string])   = overlay_res_delta.oy100;
end


%% calculate 99.7% overlay
function out = sub_calc_997(in)

valid_in = abs(in(~isnan(in)));
[unused, sorted_in] = sort(valid_in);
target_index = round(length(valid_in)*0.9973);
out = valid_in(sorted_in(target_index));


function out = sub_calc_m3s(in)

valid_in = in(~isnan(in));
out = abs(mean(valid_in)) + 3*std(valid_in);


%% calculate measurement statistics
function out = sub_calc_meas_stat(mli)

nanmat = logical(zeros(length(mli.wd.xw), 1));

for ilayer = 1:mli.nlayer
    nandata = (isnan(horzcat(mli.layer(ilayer).wr.dx)) | isnan(horzcat(mli.layer(ilayer).wr.dy)));
    if any(nandata)
        nanmat = nanmat | nandata;
    end
end

out.nr_nans = sum(double(nanmat))';
out.nr_valid = sum(double(~nanmat))';


%% calculate outlier statistics
function out = sub_calc_outlier_stat(extra, waferid)

coor = [];
for iwafer = 1:length(waferid)    % hard coded 2nd layer only because we don't have first layer
    coor = [coor; extra.layer.wafer(waferid(iwafer)).x + 1i*extra.layer.wafer(waferid(iwafer)).y];
end

unique_coor = unique(coor);
out = length(unique_coor);
