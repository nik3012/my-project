function [fp_struct, ff_6p, fp_struct_smf] = bmmo_apply_SBC_inline_SDM(ml_template, corr, factor, skip_sdm)
% function [fp_struct, ff_6p, fp_struct_smf] = bmmo_apply_SBC_inline_SDM(ml_template, corr, factor, skip_sdm)
%
% Generate a list of SBC correction ml structures from a valid bmmo 
% input_struct and an SBC correction. Intrafield is modeled by simulating 
% inline SDM. Access to the projection toolbox is needed to perform this
% simulation.
%
% Input: 
%   ml_template: a valid input structure for the BMMO-NXE drift control
%       model
%   corr: a valid correction set from the BMMO-NXE drift control model,
%       e.g. the output of bmmo_nxe_drift_control_model (out.corr) or
%       bmmo_kt_process_SBC2
%   factor: A constant factor to apply to the fingerprints (default = 1)
%   skip_sdm: Skips modeling using InlineSDM model if set to 1.(default = 0).
%             In case skip_sdm = 1, corr.ffp is directly resampled and 
%             distributed to ml_template to calculate the intrafield
%             fingerprint.
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
%   ffp_struct_smf: fp_struct with the smf format from ml_template
%
% 20191014 SELR creation from bmmo_apply_SBC
% 20200616 ANBZ Updated for KA@M ff 6par Fingerprint
% 20200710 JIMI Update intrafield actuation(skip_sdm=0) with cet model type

if nargin < 3
    factor = 1;
end

if nargin < 4
    skip_sdm = 0;
end

[mlp, options] = bmmo_process_input(ml_template); % options will contain the WH input fingerprint
if ~skip_sdm
    options.intraf_actuation.fnhandle = @bmmo_INTRAF_inline_SDM_fingerprint; 
else
    options.intraf_actuation.fnhandle = @bmmo_INTRAF_resampled_fingerprint;
end
[fp_struct, ff_6p] = bmmo_apply_SBC_core(mlp, corr, factor, options);

fn = fieldnames(fp_struct);
for ifield = 1:length(fn)
    fp_struct_smf.(fn{ifield}) = bmmo_map_to_smf(fp_struct.(fn{ifield}), ml_template);
end
