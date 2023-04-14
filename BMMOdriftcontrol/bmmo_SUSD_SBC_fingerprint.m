function mlo = bmmo_SUSD_SBC_fingerprint(mli, fingerprint, options)
% function mlo = bmmo_SUSD_SBC_fingerprint(mli, fingerprint, options)
%
% This function returns an ml structure corresponding to the input SBC
% SUSD fingerprint
% 
% Input:
%  mli: input ml structure
%  fingerprint: SUSD fingerprint (1x1 struct array)
%  options: option structure containing:
%         Scan_direction during exposure
%         chuck_usage.chuck_id_used
%         chuck_usage.chuck_id
% 
% Output:
%  mlo: output ml structure containing the SUSD fingerprint in the same layout as mli
%
% For details of the model and definitions of in/out interfaces, refer to
% D000810611 EDS BMMO NXE drift control model

mlo = ovl_combine_linear(mli, 0);
SU_INDEX = 2;

for ichuck = options.chuck_usage.chuck_id_used
    % for each wafer on this chuck, add the SUSD fingerprint
    wafers_this_chuck = find(options.chuck_usage.chuck_id == ichuck);
    wafers_this_chuck = reshape(wafers_this_chuck, 1, []); % make horizontal for R13 compatibility
    for iwafer = wafers_this_chuck
        for ilayer = 1:length(mli.layer)
            ml_susd = bmmo_SUSD_fingerprint(ovl_get_subset(mlo, ilayer, iwafer), options.Scan_direction(:, ilayer), fingerprint(ichuck*SU_INDEX).TranslationY);
            mlo.layer(ilayer).wr(iwafer).dx = ml_susd.layer.wr.dx;
            mlo.layer(ilayer).wr(iwafer).dy = ml_susd.layer.wr.dy;
        end
    end
end
