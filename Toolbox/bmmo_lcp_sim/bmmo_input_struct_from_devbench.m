function input_struct = bmmo_input_struct_from_devbench(KT_wo, adelsbcrep, adeller, timefilter)
% function [sbc_new, ml_in] = bmmo_simulate_LCP(KT_wo, adelsbcrep, adeller)
%
% Given KT wafers out, SBC report and ADELler, generate a bmmo input_struct
%
% Input:
%   KT_wo: KT_wafers_out from KT Devbench Monitor Lot
%   adelsbcrep: full path of ADELsbcOverlayDriftControlNxerep from same lot
%   adeller: full path of ADELler from same lot
%
% Optional Input:
%   timefilter: (0/1) flag to specify if time filter is enabled (default 0)
%       0 means Recover to Baseline
%       1 means Control to Baseline
%
% Output:  
%   input_struct: BMMO-NXE model input read from input data
%
% 20201019 SBPR Refactored from bmmo_simulate_LCP

EDGE_REMOVAL = 0.148; % YS readout has some marks outside 0.147

% read adeller to get expinfo (containing only xc, yc field centres)
disp('reading ADELler');
[expinfo, mark_type, ~, scan_direction] = bmmo_expinfo_from_adeller(adeller);
expinfo.map_fieldtoexp = 1:length(expinfo.xc);

% generate the measurement ml structure(s) from wafers_out, generating a
% template structure from expinfo
disp('reading KT_wafers_out');
phase = 2;
mlo = bmmo_get_meas_data(KT_wo, expinfo, phase, mark_type);

% Remove edge and downsample
disp('downsampling and removing edge');
mlo = ovl_remove_edge(mlo, EDGE_REMOVAL);
mlo = bmmo_generate_2l_dyna25_input(mlo);
mlo.tlgname = '';

input_struct = bmmo_convert_to_smf(mlo);
input_struct.expinfo = expinfo;
input_struct.info = bmmo_get_default_info(input_struct, '13x19');
input_struct.info.report_data.time_filtering_enabled = timefilter;

[prev_sbc, inline_sdm] = bmmo_kt_process_SBC2rep(adelsbcrep);
input_struct.info.report_data.inline_sdm_residual =  inline_sdm.sdm_res;
input_struct.info.report_data.Scan_direction = scan_direction;

if isfield(prev_sbc, 'Configurations')
    prev_sbc = rmfield(prev_sbc, 'Configurations');
end
input_struct.info.previous_correction = prev_sbc;
