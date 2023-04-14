function mlo = bmmo_MI_SBC_fingerprint(mli, fingerprint, options, EdgeRemoval)
% function mlo = bmmo_MI_SBC_fingerprint(mli, fingerprint, options, EdgeRemoval)
%
% This function generates an ml structure corresponding to the input 
% SBC MI fingerprint
%
% Input:
%  mli: input ml structure
%  fingerprint: MI fingerprint (1x2 struct array)
%  options: BMMO/BL3 option structure
%
% Optional Input
%  EdgeRemoval: Removes edge if EdgeRemoval = 1
%
% Output:
%  mlo: output ml structure containing the MI fingerprint, same layout as mli
%
% For details of the model and definitions of in/out interfaces, refer to
% D000810611 EDS BMMO NXE drift control model

if nargin<4
    EdgeRemoval = 0;
end
mlo = mli;

for ichuck = options.chuck_usage.chuck_id_used
    
    MI_map = fingerprint(ichuck);
    
    % for each wafer on this chuck, add the MI fingerprint
    wafers_this_chuck = find(options.chuck_usage.chuck_id == ichuck);
    wafers_this_chuck = reshape(wafers_this_chuck, 1, []); % make horizontal for R13 compatibility
    for iwafer = wafers_this_chuck
        for ilayer = 1:length(mli.layer)
            ml_MI = bmmo_mirror_fingerprint(ovl_get_subset(mli, ilayer, iwafer), MI_map, options, EdgeRemoval);
            
            mlo.layer(ilayer).wr(iwafer).dx = ml_MI.layer.wr.dx;
            mlo.layer(ilayer).wr(iwafer).dy = ml_MI.layer.wr.dy;
        end
    end
end

mlo = ovl_combine_linear(mli, 0, mlo, 1);