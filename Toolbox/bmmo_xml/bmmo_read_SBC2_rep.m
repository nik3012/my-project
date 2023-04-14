    
function sbc = bmmo_read_SBC2_rep(sbcreppath)
% function sbc = bmmo_read_SBC2_rep(sbcreppath)
%
% Read SBC2 report into sbc structure, subtracting the inline SDM residual to get the
% actuation inline SDM correction
%
% NOTE: this function is a duplicate of bmmo_reda_sbc_from_ADELrep and will
%   be removed in future releases
%
% Input:
%   sbcreppath: full path of ADELsbcOverlayDriftControlNxerep xml file    
%
% Output:
%   sbc: SBC2 report in BMMO-NXE format
%
% 20170529 SBPR Creation

warning('bmmo_read_SBC2_rep is a duplicate of bmmo_read_sbc_from_ADELrep and will be removed in future releases');

sbc = bmmo_read_sbc_from_ADELrep(sbcreppath);