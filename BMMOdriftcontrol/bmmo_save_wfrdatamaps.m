function bmmo_save_wfrdatamaps(mli, model_results, kpi_out, options)
% function bmmo_save_wfrdatamaps(mli, model_results, kpi_out, options)
%
% Saves OTAS waferdatamaps for: 
% P379374 : SBC2 correction filtered and unfiltered
% P385771 : Intrafield 18par NCEs
%
% Input:
%   mli:            original input structure
%   model_results:  structure containing results of modelling
%   kpi_out:        structure containing the following SBC2 correction structures
%                   delta_filtered
%                   delta_unfiltered
%                   total_filtered
%                   total_unfiltered
%   options:        BMMO options structure
%
% Output:
%   Out: waferdatamaps .mat files are written directly to
%   mli.diagnostics_path

smf_format = ovl_average(mli);
pc = options.previous_correction;
intraf = bmmo_ffp_to_ml_simple(pc.ffp, model_results.ml_outlier_removed, options);

prev_sbc = bmmo_get_sbc_fingerprints(intraf, options, pc);
prev_sbc_smf = bmmo_map_to_smf(prev_sbc.TotalSBCcorrection, mli);
smf_undo = ovl_sub(mli, prev_sbc_smf);
mlp_undo_chk = bmmo_average_chuck(smf_undo, options);
sub_save_map_per_chuck(mlp_undo_chk, 'uncontrolled_meas', smf_format, mli);

correctiondata = {'total_filtered', 'total_unfiltered'};
for corrdat_i=1:length(correctiondata)
    smf_format_noNan = sub_make_no_nan(smf_format);
    intraf = bmmo_ffp_to_ml_simple(kpi_out.(correctiondata{corrdat_i}).ffp, model_results.ml_outlier_removed, options);
    fps = bmmo_get_sbc_fingerprints(intraf,options, kpi_out.(correctiondata{corrdat_i}));
    ml_ffp = ovl_average_fields(fps.INTRAF);
    fps.(options.intraf_nce_modelresult.name) = ovl_model(ml_ffp, 'perwafer', options.intraf_CETpar.name);
        
    % Replace ffp with 18par (33par) intra
    fps.TotalSBCcorrection = ovl_sub(fps.TotalSBCcorrection, fps.INTRAF);
    ml_intraf = ovl_sub(ml_ffp, fps.(options.intraf_nce_modelresult.name));
    fps.INTRAF = ovl_distribute_field(ml_intraf, intraf);

    fps.TotalSBCcorrection = ovl_add(fps.TotalSBCcorrection, fps.INTRAF);
    
    fps.WH = ovl_average(fps.WH);
    corrset = {'KA', 'MI', 'BAO', 'INTRAF', 'WH', 'TotalSBCcorrection', options.intraf_nce_modelresult.name};

    for corrset_i = 1:length(corrset)
        data = fps.(corrset{corrset_i});
%         data = bmmo_shift_fields(data, options.x_shift, options.y_shift);
        if strcmp(char(corrset{corrset_i}), 'INTRAF')
            data = ovl_average_fields(data);
        end
        if ~strcmp(char(corrset{corrset_i}), 'WH')
            data_chk = bmmo_average_chuck(data, options);
            sub_save_map_per_chuck(data_chk, char([correctiondata{corrdat_i},'_',corrset{corrset_i}]), smf_format_noNan, mli);
        else
            data_chk = ovl_average(data);
            sub_save_map(data_chk, char([correctiondata{corrdat_i},'_',corrset{corrset_i}]), smf_format_noNan, mli);
        end
        
    end
    
end

function smf_format_noNan = sub_make_no_nan(smf_format)
smf_format_noNan = smf_format;
ind = union(find(isnan(smf_format.layer.wr.dx)), find(isnan(smf_format.layer.wr.dy)));
smf_format_noNan.layer.wr.dx(ind)=0;
smf_format_noNan.layer.wr.dy(ind)=0;


function sub_save_map(data, name, smf_format, mli)
dat_tmp = bmmo_map_to_smf(data, smf_format);
ml_layer = dat_tmp.layer;
save([mli.diagnostics_path filesep char(name) ], '-struct', 'ml_layer', '-v6');


function sub_save_map_per_chuck(data, name, smf_format, mli)
for chk = 1:length(data)
    dat_tmp = data(chk);
    if dat_tmp.nfield > 1
        dat_tmp = bmmo_map_to_smf(dat_tmp, smf_format);
    end
    ml_layer = dat_tmp.layer;
    save([mli.diagnostics_path filesep char([name,'_chk',num2str(chk)])], '-struct', 'ml_layer', '-v6');
end
