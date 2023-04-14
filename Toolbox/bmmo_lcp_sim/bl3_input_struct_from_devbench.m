function input_struct = bl3_input_struct_from_devbench(KT_wo, adelsbcrep, adeller, timefilter, adelexp, adelwfrgridNCE)
% function [sbc_new, ml_in] = bmmo_simulate_LCP(KT_wo, adelsbcrep, adeller)
%
% Given KT wafers out, SBC report and ADELler, generate a bmmo input_struct
%
% Input:
%   KT_wo: KT_wafers_out from KT Devbench Monitor Lot
%   adelsbcrep: full path of ADELsbcOverlayDriftControlNxerep from same lot
%   adeller: full path of ADELler from same lot
%   adelexp: full path of ADELexposureTrajectoriesReportProtected
%   adelwfrgridNCE: full path of ADELwaferGridResidualReportProtected
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
% 20201217 ANBZ Updated fo ADElwfrgridNCE

input_struct = bmmo_input_struct_from_devbench(KT_wo, adelsbcrep, adeller, timefilter);
input_struct.info.configuration_data.bl3_model = 1;
input_struct.info.configuration_data.KA_correction_enabled = 1;
input_struct.info.configuration_data.susd_correction_enabled = 1;

if ischar(adelexp)
    input_struct.info.report_data.cet_residual = bmmo_read_adelexposetrajectories(adelexp);
else    
    input_struct.info.report_data.cet_residual = bmmo_parse_adelexposetrajectories(adelexp);
end

if ischar(adelwfrgridNCE)
    [input_struct.info.report_data.KA_cet_corr, input_struct.info.report_data.KA_cet_nce] = bmmo_read_adelwafergridresidual(adelwfrgridNCE);
else    
    [input_struct.info.report_data.KA_cet_corr, input_struct.info.report_data.KA_cet_nce] = bmmo_parse_adelwafergridresidual(adelwfrgridNCE);
end