function ffp_out = bmmo_model_10par_ffp(ffp_in, options)
% function ffp_out = bmmo_model_10par_ffp(ffp_in, options)
%
% Remove 10par per wafer from the input ffp
%
% Input:
%  ffp_in: SBC2 field fingerprint structure
%  options: BMMO/BL3 default options structure
%
% Output: 
%  ffp_out: SBC2 field fingerprint structure, ffp_in with 10par per
%        wafer removed

ml_tmp = bmmo_ffp_to_ml_simple(ffp_in);

ml_tmp = bmmo_fit_model_perwafer(ml_tmp, options, '10par');

ffp_out = ffp_in;
for iw = 1:2
   ffp_out(iw).dx = ml_tmp.layer.wr(iw).dx;
   ffp_out(iw).dy = ml_tmp.layer.wr(iw).dy;
end
