function ml_ff_6par = bmmo_ff_6par_fingerprint(mli, fingerprint_MI, fingerprint_KA, options)
% function ml_ff_6par = bmmo_ff_6par_fingerprint(mli, fingerprint_MI, fingerprint_KA, options)
%
% This function returns an ml structure corresponding to the ff 6par
% fingerprint of the input mirror map and KA grid map
%
% Input:
% mli: input ml structure
% fingerprint_MI: Mirror correction (1x2 struct array)
% fingerprint_KA: KA correction (1x2 struct array)
% options: BMMO/BL3 option structure
%
% Output:
% ml_ff_6par: output ml structure containing the BAO fingerprint in the same layout as mli
%
% For details of the model and definitions of in/out interfaces, refer to
% D000810611 EDS BMMO NXE drift control model

ml_ff_6par = mli;

% Get the 6par ff correction from the MI fingerprint
for ic = options.chuck_usage.chuck_id_used
    % FF BAO Correction for MI and KA
    [ff_6par_MI(ic), ff_6par_KA(ic)] = bmmo_ff_bao_correction(fingerprint_MI(ic), fingerprint_KA(ic), options);
    % ADD MI and KA FF BAO Correction
    ff_6par(ic) = bmmo_add_BAOs(ff_6par_MI(ic), ff_6par_KA(ic));
end

for iwafer = 1:mli.nwafer
    this_chuck_id = options.chuck_usage.chuck_id(iwafer);
    for ilayer = 1:length(mli.layer)
        this_wafer = ovl_get_subset(mli, ilayer, iwafer);
        ml_par_this_wafer = bmmo_apply_model(ovl_combine_linear(this_wafer, 0), ff_6par(this_chuck_id), 1, options);
        ml_ff_6par.layer(ilayer).wr(iwafer).dx = ml_par_this_wafer.layer.wr.dx;
        ml_ff_6par.layer(ilayer).wr(iwafer).dy = ml_par_this_wafer.layer.wr.dy;
    end
end