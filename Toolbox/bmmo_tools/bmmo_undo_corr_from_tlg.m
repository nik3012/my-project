function mlo = bmmo_undo_corr_from_tlg(atppath, sbcreppath)
% function mlo bmmo_undo_corr_from_tlg(atppath, sbcreppath)
%
% Given a testlog filename and an SBC report, undo the SBC correction in the report
%
% Input: atppath    : full path of testlog
%        sbcreppath : full path of ADEL SBC report (default: SBC will be
%                     taken from testlog
%
% Output: mlo: ATP-MMO with SBC correction undone

% read the testlog
ml = ovl_read_testlog(atppath, 'info');

% read the SBC report
inlineSDMflag = true;
[sbc, inline_sdm] = bmmo_kt_process_SBC2rep(sbcreppath);

 for ii = 1:length(sbc.ffp)
     sbc.ffp(ii).dx = sbc.ffp(ii).dx - inline_sdm.sdm_res(ii).dx;
     sbc.ffp(ii).dy = sbc.ffp(ii).dy - inline_sdm.sdm_res(ii).dy;
 end

mlo = bmmo_undo_corr_from_ATPMMO(ml, sbc, inlineSDMflag);
    

