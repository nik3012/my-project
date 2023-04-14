function [mlo, ml_wh] = bmmo_WH_SBC_fingerprint(mli, options)
% function [mlo, ml_wh] = bmmo_WH_SBC_fingerprint(mli, options)
%
% This function returns an ml structure corresponding to the input SBC
% WH fingerprint and its behaviour is based on options.WH.use_input_fp_per_wafer
% 
% Input:
%  mli: input ml structure
%  fingerprint: WH fingerprint (1x2 struct array)
%  options:
%   wh_fp: input wafer heating fingerprint, per wafer(for de-correction)/averaged per chuck
% 
% Output:
%  mlo: output ml structure containing the WH fingerprint in the same layout as mli
%  ml_wh: mlo averaged per chuck
%
% For details of the model and definitions of in/out interfaces, refer to
% D000810611 EDS BMMO NXE drift control model

if options.WH.use_input_fp_per_wafer 
    wh_fp = options.WH.fp;
    
else                                 
    wh_fp     = ovl_get_wafers(options.WH.fp, []);
    for ichk  = 1 : length(options.chuck_usage.chuck_id)
        wh_fp = ovl_combine_wafers(wh_fp, options.WH.input_fp_per_chuck(options.chuck_usage.chuck_id(ichk)));
    end
end

lambda_old = (options.previous_correction.IR2EUV /options.IR2EUVsensitivity);
mlo        = ovl_combine_linear(mli, 0, wh_fp, lambda_old);

ml_wh      = bmmo_average_chuck(mlo, options);


end