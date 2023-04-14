function mlo = bmmo_undo_corr_from_ATPMMO(ml, sbc, inlineSDMflag)
% function mlo = bmmo_undo_corr_from_ATPMMO(ml, sbc, inlineSDMflag)
% 
% Given an ml structure and an SBC correction, undo the SBC correction
%
% Input:
%   ml: ATP-MMOoverlay structure
%   sbc: sbc correction structure
%
% Optional Input:
%   inlineSDMflag: true if inline SDM should be use (default: false)
%
% Output: mlo: ml with SBC correction removed

if nargin < 3
    inlineSDMflag = false;
end

if inlineSDMflag
    fps = bmmo_apply_SBC_to_ml_inline_SDM(ovl_sub_layers(ml), sbc);
else
    fps = bmmo_apply_SBC_to_ml(ovl_sub_layers(ml), sbc);
end

sbcl1 = ovl_create_dummy(fps.TotalSBCcorrection);

totalsbc = fps.TotalSBCcorrection;

% make sure the sbc correction is on the highest-numbered layer
for il = 2:ml.nlayer
    totalsbc = ovl_combine_layers(sbcl1, 1, totalsbc,1);
end

mlo = ovl_sub(ml, totalsbc);



