function ovl_KPI3_4 = bmmo_calc_KPI3_4(input_structs, sbcs)
% function ovl_KPI3_4 = bmmo_calc_KPI3_4(in, sbc)
%
% Calculate Overaly monitor Interfield and Intrafield KPIs (DeltaToReference
% and DeltaToPrevious) based on reference, previous and current BMMO
% job outputs
%
%Input:
%
% input_structs:  BMMO inputs (1x3 struct) of the three jobs read in by bmmo_read_lcp_zip
%      in the follwing sequence: reference, previous and current.
% sbcs: The output sbc recipes (1x3 struct) of the three jobs parsed in the
%      correct sequence(reference, previous and current.
%
% Output:
% ovl_KPI3_4: Overaly monitor KPIs, ovl.inter and ovl.intra
%
% See also: bmmo_calc_KPI3_4_from_zips

for i = 1:length(input_structs)
    [mli(i), options(i)] = bmmo_process_input(input_structs(i));
    sbcrep(i) = input_structs(i).info.previous_correction;
    tf(i) = options(i).filter.coefficients;
    
    %Interfield NCE
    factor = 1;
    options(i).WH.use_input_fp_per_wafer = 1;
    fps_sbc(i)    = bmmo_apply_SBC_core(mli(i), sbcs(i), factor, options(i));
    fps_sbcrep(i) = bmmo_apply_SBC_core(mli(i), sbcrep(i), factor, options(i));
    
    delta_sbc_filtered(i) = sub_get_delta_sbc(fps_sbc(i), fps_sbcrep(i));
    delta_sbc_unfiltered(i) = sub_get_unfiltered(delta_sbc_filtered(i), tf(i));
    
    for ic = 1:2
        wafers_this_chuck = find(options(i).chuck_usage.chuck_id == ic);
        wafers_this_chuck = reshape(wafers_this_chuck, 1, []); % make horizontal for R13 compatibility
        inter_nce(i).ml(ic) = ovl_add(ovl_get_wafers(mli(i), wafers_this_chuck),...
            ovl_get_wafers(delta_sbc_unfiltered(i).TotalSBCcorrection, wafers_this_chuck));
        
        if strcmp(options(i).platform, 'LIS')% shift LIS BMMO outputs from RINT to XPA
            inter_nce(i).ml(ic) = bmmo_shift_fields(inter_nce(i).ml(ic), -options(i).x_shift, -options(i).y_shift);
        end
    end
    
    % Intrafield NCE
    sdm_res(i).ffp = input_structs(i).info.report_data.inline_sdm_residual;
    sbc_ffp = bmmo_ffp_to_ml(sbcs(i).ffp);
    sbcrep_ffp = bmmo_ffp_to_ml(sbcrep(i).ffp);
    res_ffp = bmmo_ffp_to_ml(sdm_res(i).ffp);
    for ic = 1:2
        intra_nce(i).ml(ic) = ovl_combine_linear(ovl_add(ovl_sub(ovl_get_wafers(sbc_ffp, ic),...
            ovl_get_wafers(sbcrep_ffp, ic)), ovl_get_wafers(res_ffp, ic)), 1/tf(i).INTRAF);
        intra_nce(i).ml(ic) = bmmo_fit_model(intra_nce(i).ml(ic), options(i), options(i).intraf_CETpar.name);
    end
end

for ic = 1:2
    delta_to_ref_inter(ic) = ovl_sub(inter_nce(3).ml(ic), ovl_average(inter_nce(1).ml(ic)));
    ovl_KPI3_4.inter.to_ref(ic) = ovl_calc_overlay(delta_to_ref_inter(ic));
    
    delta_to_prev_inter(ic) = ovl_sub(inter_nce(3).ml(ic), ovl_average(inter_nce(2).ml(ic)));
    ovl_KPI3_4.inter.to_prev(ic) = ovl_calc_overlay(delta_to_prev_inter(ic));
    
    delta_to_ref_intra(ic) = ovl_sub(ovl_average(intra_nce(3).ml(ic)), ovl_average(intra_nce(1).ml(ic)));
    ovl_KPI3_4.intra.to_ref(ic) = ovl_calc_overlay(ovl_get_fields(delta_to_ref_intra(ic), 1));
    
    delta_to_prev_intra(ic) = ovl_sub(ovl_average(intra_nce(3).ml(ic)), ovl_average(intra_nce(2).ml(ic)));
    ovl_KPI3_4.intra.to_prev(ic) = ovl_calc_overlay(delta_to_prev_intra(ic));
end
% remove 3sd fields
ovl_KPI3_4.inter.to_ref = sub_remove_3sd(ovl_KPI3_4.inter.to_ref);
ovl_KPI3_4.inter.to_prev = sub_remove_3sd(ovl_KPI3_4.inter.to_prev);
ovl_KPI3_4.intra.to_ref = sub_remove_3sd(ovl_KPI3_4.intra.to_ref);
ovl_KPI3_4.intra.to_prev = sub_remove_3sd(ovl_KPI3_4.intra.to_prev);

end


function delta_fps = sub_get_delta_sbc(fps_sbc, fps_sbcrep)

fn = fieldnames(fps_sbc);
for i = 1:length(fn)
    delta_fps.(fn{i}) = ovl_sub(fps_sbc.(fn{i}), fps_sbcrep.(fn{i}));
end
end


function delta_sbc_unfiltered = sub_get_unfiltered(fps_sbc, filter)

delta_sbc_unfiltered.TotalSBCcorrection = (ovl_combine_linear(fps_sbc.TotalSBCcorrection, 0));
fn = fieldnames(filter);
for i = 1:length(fn)
    delta_sbc_unfiltered.(fn{i}) = ovl_combine_linear((fps_sbc.(fn{i})), 1/filter.(fn{i}));
    delta_sbc_unfiltered.TotalSBCcorrection = ovl_add(delta_sbc_unfiltered.TotalSBCcorrection, delta_sbc_unfiltered.(fn{i}));
end
end


function ovl_field = sub_remove_3sd(ovl_field)

if isfield(ovl_field, 'oy3sd')
    ovl_field = rmfield(ovl_field, 'oy3sd');
end
if isfield(ovl_field, 'ox3sd')
    ovl_field = rmfield(ovl_field, 'ox3sd');
end
end