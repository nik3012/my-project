function [mlo, ml_intra] = bmmo_INTRAF_par_fingerprint(mli, fingerprint, options)
% function [mlo, ml_intra] = bmmo_INTRAF_par_fingerprint(mli, fingerprint, options)
%
% This function returns an ml structure corresponding to the input SBC
% INTRAF fingerprint. It will calculate 18par or 33par of the input
% fingerprint, depending on options.intraf_CETpar.name, and distribute it
% onto mli.
%
% Input:
% mli: input ml structure
% fingerprint: INTRAF fingerprint (1x2 struct array)
% options: BMMO/BL3 options structure
%
% Output:
% mlo: output ml structure containing the INTRAF fingerprint in the same layout as mli
% ml_intra: INTRAF fingerprint in same layout as mli, averaged per chuck

mlo = mli;

for ichuck = options.chuck_usage.chuck_id_used
    % get the 18/33 par correctible
    ml_field_avg_chk  = sub_ffp_2_ml(fingerprint(ichuck));
    [~, parlist] = ovl_model(ml_field_avg_chk, options.intraf_CETpar.name);
  
    % add 18/33 pars to the input structure
    wafer_on_this_chuck = find(options.chuck_usage.chuck_id == ichuck);
    for iwafer = 1:length(wafer_on_this_chuck)
        for ilayer = 1:length(mli.layer)
            corr_FP = ovl_combine_linear(ovl_get_subset(mli, 1, wafer_on_this_chuck(iwafer)), 0);
            corr_FP = ovl_model(corr_FP, 'apply', parlist);
            mlo.layer(ilayer).wr(wafer_on_this_chuck(iwafer)).dx = corr_FP.layer.wr.dx;
            mlo.layer(ilayer).wr(wafer_on_this_chuck(iwafer)).dy = corr_FP.layer.wr.dy;
        end
    end
    ml_intra(ichuck) = ovl_average_fields(corr_FP);
end


function ml = sub_ffp_2_ml(ffp)

ml.wd.xf = ffp.x;
ml.wd.yf = ffp.y;
ml.wd.xc = zeros(size(ffp.x));
ml.wd.yc = ml.wd.xc;
ml.wd.xw = ml.wd.xf;
ml.wd.yw = ml.wd.yf;

ml.nwafer = 1;
ml.nlayer = 1;
ml.nmark = length(ml.wd.xf);
ml.nfield = 1;
ml.tlgname = '';

ml.layer.wr.dx = ffp.dx;
ml.layer.wr.dy = ffp.dy;
