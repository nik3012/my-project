function [fp_struct, ff_6p] = bmmo_apply_SBC_core(mlp, corr, factor, options)
% function fp_struct = bmmo_apply_SBC(ml_template, corr, factor)
%
% Core function to simulate SBC actuation. Do not use this function
% directly, but call it's wrapper functions (e.g. bmmo_apply_SBC)
%
% Input: 
%   mlp: template ml structure
%   corr: a valid correction set from the BMMO-NXE drift control model,
%       e.g. the output of bmmo_nxe_drift_control_model (out.corr) or
%       bmmo_kt_process_SBC2
%   factor: A constant factor to apply to the fingerprints (default = 1)
%   options: bmmo/bl3 options structure
%
% Output:
%   fp_struct: structure containing the following (all ml structures, same layout as ml_template)
%       WH: wafer heating fingerprint
%       MI:  Mirror fingerprint 
%       KA: KA fingerprint 
%       BAO:  BAO fingerprint 
%       INTRAF: INTRAF fingerprint
%       TotalSBCcorrection: sum of the other fingerprints
%   ff_6p: 6par feedforward BAO fingerprint from MI@M & KA@M corrections
%

wafer_radius_in_m = options.wafer_radius_in_mm*1e-3;
mlo = ovl_create_dummy(mlp);

% Backward compatibility check, to be removed in later update
if isfield(corr, 'SUSD')
    fp_struct.SUSD = bmmo_SUSD_SBC_fingerprint(mlp, corr.SUSD, options);
    mlo = ovl_add(mlo, fp_struct.SUSD);
end

fp_struct.KA = ovl_remove_edge(bmmo_KA_SBC_fingerprint(mlp, corr.KA.grid_2de, options), wafer_radius_in_m);
mlo = ovl_add(mlo, fp_struct.KA);

fp_struct.MI = ovl_remove_edge(bmmo_MI_SBC_fingerprint(mlp, corr.MI.wse, options), wafer_radius_in_m);
mlo = ovl_add(mlo, fp_struct.MI);

fp_struct.BAO = ovl_remove_edge(bmmo_BAO_SBC_fingerprint(mlp, corr.BAO, options), wafer_radius_in_m);
mlo = ovl_add(mlo, fp_struct.BAO);

fp_struct.INTRAF = ovl_remove_edge(bmmo_INTRAF_SBC_fingerprint(mlp, corr.ffp, options), wafer_radius_in_m);
mlo = ovl_add(mlo, fp_struct.INTRAF);

options.previous_correction.IR2EUV = corr.IR2EUV;
fp_struct.WH = ovl_remove_edge(bmmo_WH_SBC_fingerprint(mlp, options), wafer_radius_in_m);
mlo = ovl_add(mlo, fp_struct.WH);

% subtract the ff 6par correction
ff_6p = bmmo_ff_6par_fingerprint(mlp, corr.MI.wsm, corr.KA.grid_2dc, options);
mlo = ovl_sub(mlo, ff_6p);
fp_struct.BAO = ovl_sub(fp_struct.BAO, ff_6p);

fp_struct.TotalSBCcorrection = mlo;

% apply a constant factor (e.g. -1) to the fingerprints if specified
fn = fieldnames(fp_struct);
for ifield = 1:length(fn)
    fp_struct.(fn{ifield}) = ovl_combine_linear(fp_struct.(fn{ifield}), factor);
end
