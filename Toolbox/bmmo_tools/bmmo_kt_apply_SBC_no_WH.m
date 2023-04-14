function fp_struct = bmmo_kt_apply_SBC_no_WH(ml_template, corr, factor)
% function fp_struct = bmmo_kt_apply_SBC_no_WH(ml_template, corr)
%
% Generate a list of SBC correction ml structures from a given template ml
% and an SBC correction
%
% Input: 
%   ml: a valid input structure for the BMMO-NXE drift control model, e.g.
%       the output of bmmo_kt_preprocess_input
%   corr: a valid correction set from the BMMO-NXE drift control model,
%       e.g. the output of bmmo_nxe_drift_control_model (out.corr) or
%       bmmo_kt_process_SBC2
%
% Output:
%   fp_struct: structure containing the following (all ml structures, same layout as ml_template)
%       MI:  Mirror fingerprint 
%       KA: KA fingerprint 
%       BAO:  BAO fingerprint 
%       INTRAF: INTRAF fingerprint
%       TotalSBCcorrection: sum of the other fingerprints
%
% 20160412 SBPR Creation


options = bmmo_default_options_structure;

options.chuck_usage.nr_chuck_used = 2;
options.chuck_usage.chuck_id_used = [1 2];
options.chuck_usage.chuck_id = [1 2 1 2 1 2];
options.chuck_usage.chuck_id = options.chuck_usage.chuck_id(1:ml_template.nwafer);

mlo = ovl_create_dummy(ml_template);

fp_struct.KA = bmmo_KA_SBC_fingerprint(ml_template, corr.KA.grid_2de, options);
mlo = ovl_add(mlo, fp_struct.KA);

fp_struct.MI = bmmo_MI_SBC_fingerprint(ml_template, corr.MI.wse, options);
mlo = ovl_add(mlo, fp_struct.MI);

fp_struct.BAO = bmmo_BAO_SBC_fingerprint(ml_template, corr.BAO, options);
mlo = ovl_add(mlo, fp_struct.BAO);

fp_struct.INTRAF = bmmo_INTRAF_SBC_fingerprint(ml_template, corr.ffp, options);
mlo = ovl_add(mlo, fp_struct.INTRAF);

fp_struct.TotalSBCcorrection = mlo;

% apply a constant factor (e.g. -1) to the fingerprints if specified
fn = fieldnames(fp_struct);
for ifield = 1:length(fn)
    fp_struct.(fn{ifield}) = ovl_combine_linear(fp_struct.(fn{ifield}), factor);
    fp_struct.(fn{ifield}) = bmmo_average_chuck(fp_struct.(fn{ifield}), options);
end