function [fp_struct, ff_6p] = bmmo_apply_SBC_to_ml(ml_template, corr, factor, options)
% function fp_struct = bmmo_apply_SBC_to_ml(ml_template, corr, factor, options)
%
% Generate a list of SBC correction ml structures from a given template ml
% and an SBC correction. Intrafield is evaluated using 18-par
% estimation. To simulate inline SDM use bmmo_apply_SBC_to_ml_inline_SDM.
% 
% This function expects some extra info in the input ml_template, for 
% details see bmmo_parse_apply_SBC_to_ml_options.  
%
% Input: 
%   ml_template: a valid ml structure in any layout, in case of an ml struct  
%       in bmmo layout (output of bmmo_process_input), the accompanying
%       options structure should be provided as the last input argument
%   corr: a valid correction set from the BMMO-NXE drift control model,
%       e.g. the output of bmmo_nxe_drift_control_model (out.corr) or
%       bmmo_kt_process_SBC2
%   factor: A constant factor to apply to the fingerprints (default = 1)
%   options: bmmo_options structure belonging to ml_template
%
% Output:
%   fp_struct: structure containing the following (all ml structures, same layout as ml_template)
%       WH: Wafer Heating fingerprint
%       MI:  Mirror fingerprint 
%       KA: KA fingerprint 
%       BAO:  BAO fingerprint 
%       INTRAF: INTRAF fingerprint
%       TotalSBCcorrection: sum of the other fingerprints
%   ff_6p: 6par feedforward BAO fingerprint from MI@M & KA@M corrections
%
% 20191022 SELR Creation from bmmo_apply_SBC
% 20191120 SELR Added WH fingerprint generation
% 20200616 ANBZ Updated for KA@M ff 6par Fingerprint

BMMO_KA_GRID_POINTS = 3721;

if nargin < 3
    factor = 1;
end
if nargin < 4
    if length(corr.KA.grid_2de(1).x) > BMMO_KA_GRID_POINTS
        options = bl3_default_options_structure;
    else
        options = bmmo_default_options_structure;
    end
end

options = bmmo_parse_apply_SBC_to_ml_options(ml_template, options);
[fp_struct, ff_6p] = bmmo_apply_SBC_core(ml_template, corr, factor, options);
