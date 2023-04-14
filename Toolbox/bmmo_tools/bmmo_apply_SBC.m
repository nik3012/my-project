function [fp_struct, ff_6p, fp_struct_smf] = bmmo_apply_SBC(ml_template, corr, factor)
% function fp_struct = bmmo_apply_SBC(ml_template, corr, factor)
%
% Generate a list of SBC correction ml structures from a valid bmmo 
% input_struct and an SBC correction. Intrafield is evaluated using 18-par
% estimation. To simulate inline SDM use bmmo_apply_SBC_inline_SDM.
%
% Input: 
%   ml_template: a valid input structure for the BMMO-NXE drift control
%       model
%   corr: a valid correction set from the BMMO-NXE drift control model,
%       e.g. the output of bmmo_nxe_drift_control_model (out.corr) or
%       bmmo_kt_process_SBC2
%   factor: A constant factor to apply to the fingerprints (default = 1)
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
% 20160921 SBPR Migration to trunk/testSuite/testUtilities; removed 'kt'
%           prefix from function name
% 20160412 SBPR Creation
% 20190510 KZAK Update for SUSD control check
% 20191014 SELR Refactoring
% 20200616 ANBZ Updated for KA@M ff 6par Fingerprint

if nargin < 3
    factor = 1;
end

[mlp, options] = bmmo_process_input(ml_template); % options will contain the WH input fingerprint
[fp_struct, ff_6p] = bmmo_apply_SBC_core(mlp, corr, factor, options);


fn = fieldnames(fp_struct);
for ifield = 1:length(fn)
    fp_struct_smf.(fn{ifield}) = bmmo_map_to_smf(fp_struct.(fn{ifield}), ml_template);
end
