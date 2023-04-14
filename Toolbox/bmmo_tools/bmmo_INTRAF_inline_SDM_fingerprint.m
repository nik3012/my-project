function [mlo, ml_intra] = bmmo_INTRAF_inline_SDM_fingerprint(ml_tmp, ffp, options)
% function [mlo, ml_intra] = bmmo_INTRAF_inline_SDM_fingerprint(ml_tmp, ffp, options)
%
% This function returns an ml structure corresponding to the input SBC
% INTRAF fingerprint. It will model on the FFP using the Inline SDM model 
% and return  the InlineSDM correction actuated on the given ml_tmp, and
% the InlineSDM correction reported in ADELsbcOverlayDriftControlNxerep
%
% Input:
% ml_tmp: template ml structure
% ffp: INTRAF fingerprint (1x2 struct array)
% options: bmmo/bl3 options structure containing following fields:
%  inline_sdm_config.fnhandle
%  fieldsize
%  chuck_usage
%  image_shift (optional)
% 
% Output:
% mlo: output ml structure containing the INTRAF fingerprint in the same
% layout as ml_tmp
% ml_intra: INTRAF fingerprint in same field layout as ffp, averaged per chuck
    

ml_intra_in = bmmo_ffp_to_ml_simple(ffp);

disp(['Using Inline SDM configuration:',char(options.inline_sdm_config.fnhandle)])
config = feval(options.inline_sdm_config.fnhandle);
inlineSDM = config.getConfigurationObject('InlineSdmModel');
inlineSDM.mlDistoIn = ml_intra_in;
inlineSDM.hocModel.cetFieldSize(2) = options.fieldsize(2);
if isfield(options, 'image_shift')
    inlineSDM.hocModel.imageShift(2) = options.image_shift(2);
end
inlineSDM.mlWaferIn = ml_tmp;
inlineSDM.hocModel.chuckId = options.chuck_usage.chuck_id;
inlineSDM.run;

mlo = inlineSDM.mlChuckCorr;
ml_intra = inlineSDM.report.cor;  


   