function sbc = bmmo_read_sbc_from_ADELrep(adelrep)
% function sbc = bmmo_read_sbc_from_ADELrep(adelrep)
%
% Read SBC2 correction from ADEL SBC report, calculating inline SDM
% correction by subtracting the residual
%
% Input:
%   adelrep: full path of ADELsbcOverlayDriftControlNxerep xml file
%
% Output: 
%   sbc: SBC correction in BMMO-NXE output format (see
%       bmmo_default_output_structure)
%
% 20170412 SBPR Creation

[sbc, inline_sdm] = bmmo_kt_process_SBC2rep(adelrep);

for ii = 1:2
   sbc.ffp(ii).dx = sbc.ffp(ii).dx - inline_sdm.sdm_res(ii).dx;
   sbc.ffp(ii).dy = sbc.ffp(ii).dy - inline_sdm.sdm_res(ii).dy;
end
