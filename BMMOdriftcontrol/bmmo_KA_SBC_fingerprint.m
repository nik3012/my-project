function [mlo, ml_res] = bmmo_KA_SBC_fingerprint(mli, fingerprint, options)
% function [mlo, ml_res] = bmmo_KA_SBC_fingerprint(mli, fingerprint, options)
%
% This function returns an ml structure corresponding to the input SBC
% KA fingerprint
%
%
% Input:
%   mli:         input ml structure
%   fingerprint: KA fingerprint (1x2 struct array)
%   options:     options structure
%
% Output:
%   mlo:        output ml structure containing the KA fingerprint in the same layout as mli
%   ml_res:     output ml structure containing the residual after KA actuation
%
% For details of the model and definitions of in/out interfaces, refer to
% D000810611 EDS BMMO NXE drift control model

mlo = mli;
ml_res = mli;

for ichuck = options.chuck_usage.chuck_id_used
    
    % get a grid structure from the KA fingerprint for this chuck
    ka_grid = bmmo_KA_corr_to_grid(fingerprint(ichuck));
    
    % for each wafer on this chuck, add the KA fingerprint
    wafers_this_chuck = find(options.chuck_usage.chuck_id == ichuck);
    wafers_this_chuck = reshape(wafers_this_chuck, 1, []); % make horizontal for R13 compatibility
    
    ilayer = 1;
    iwafer = 1;
    
    if nargout > 1
        [ml_ka, ml_ka_NCE] = feval(options.KA_actuation.fnhandle, ka_grid, ovl_get_subset(mli, ilayer, iwafer), options);
        for iwafer = wafers_this_chuck
            for ilayer = 1:length(mli.layer)
                ml_res.layer(ilayer).wr(iwafer).dx = ml_ka_NCE.layer.wr.dx;
                ml_res.layer(ilayer).wr(iwafer).dy = ml_ka_NCE.layer.wr.dy;
            end
        end
    else
        ml_ka = feval(options.KA_actuation.fnhandle, ka_grid, ovl_get_subset(mli, ilayer, iwafer), options);
    end
    for iwafer = wafers_this_chuck
        for ilayer = 1:length(mli.layer)
            mlo.layer(ilayer).wr(iwafer).dx = ml_ka.layer.wr.dx;
            mlo.layer(ilayer).wr(iwafer).dy = ml_ka.layer.wr.dy;
        end
    end
end

% remove edge to mli
mlo = ovl_combine_linear(mlo, 1, mli, 0);

