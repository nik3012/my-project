function [mlo, ml_intra] = bmmo_INTRAF_resampled_fingerprint(ml_tmp, ffp, options)
% function [mlo, ml_intra] = bmmo_INTRAF_resampled_fingerprint(mli, fingerprint, options)
%
% This function returns an ml structure corresponding to the input SBC
% INTRAF fingerprint. It will resample the ffp input onto ml_tmp.
%
% Input:
% ml_tmp: template ml structure
% ffp: INTRAF fingerprint (1x2 struct array)
% options: bmmo/bl3 options structure
% 
% Output:
% mlo: output ml structure containing the INTRAF fingerprint in the same layout as mli
% ml_intra: INTRAF fingerprint in same layout as mli, averaged per chuck
    
if nargin < 3
   options.chuck_usage.chuck_id = ones(1, ml_tmp.nwafer);
   options.chuck_usage.chuck_id(2:2:end) = 2;
   options.chuck_usage.chuck_id_used = 1:2;
end

mlo = ml_tmp;
if isfield(mlo.wd, 'xf')
    ml_intra = bmmo_ffp_to_ml_simple(ffp);
    ml_intra_tmp = ovl_average_fields(ml_tmp);
    ml_intra_resampled = bmmo_correct_intrafield_shift(ml_intra, options, ml_intra_tmp);
    mlt = ovl_get_wafers(mlo, []);
    for iw = 1:mlo.nwafer
        ml_temp = ovl_distribute_field(ovl_get_wafers(ml_intra_resampled, options.chuck_usage.chuck_id(iw)), ovl_get_wafers(mlo, iw));
        mlt = ovl_combine_wafers(mlt, ml_temp);
    end
end

nl = mlo.nlayer;

for iw = 1:mlo.nwafer
    mlo.layer(nl).wr(iw).dx = mlt.layer.wr(options.chuck_usage.chuck_id(iw)).dx;
    mlo.layer(nl).wr(iw).dy = mlt.layer.wr(options.chuck_usage.chuck_id(iw)).dy;
end

ml_intra = bmmo_average_chuck(ovl_average_fields(mlo), options);
