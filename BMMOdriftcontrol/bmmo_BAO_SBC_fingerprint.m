function ml_bao = bmmo_BAO_SBC_fingerprint(mli, fingerprint, options)
% function ml_bao = bmmo_BAO_SBC_fingerprint(mli, fingerprint, options)
%
% This function returns an ml structure corresponding to the input SBC
% BAO correction
%
% Input:
% mli: input ml structure
% fingerprint: BAO correction (1x2 struct array)
% options: BMMO/BL3 option structure
%
% Output:
% ml_bao: output ml structure containing the BAO fingerprint in the same layout as mli
%
% For details of the model and definitions of in/out interfaces, refer to
% D000810611 EDS BMMO NXE drift control model

ml_bao = mli;

% Convert the BAO correction to 10 par
for ichuck = 1:2
    parlist(ichuck) = bmmo_BAO_to_10par(fingerprint(ichuck));
end

for iwafer = 1:mli.nwafer
    for ilayer = 1:length(mli.layer)
        this_chuck_id = options.chuck_usage.chuck_id(iwafer);
        this_wafer = ovl_get_subset(mli, ilayer, iwafer);
        ml_par_this_wafer = ovl_model(ovl_combine_linear(this_wafer, 0),'apply',parlist(this_chuck_id));
        ml_bao.layer(ilayer).wr(iwafer).dx = ml_par_this_wafer.layer.wr.dx;
        ml_bao.layer(ilayer).wr(iwafer).dy = ml_par_this_wafer.layer.wr.dy;
    end
end