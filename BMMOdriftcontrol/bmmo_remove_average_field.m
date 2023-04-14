function mlo = bmmo_remove_average_field(mli, options)
% function mlo = bmmo_remove_average_field(mli, options)
%
% This function removes the averaged fingerprint per field on a wafer,
% excluding any points that are nan. the algorithm iterates per [xf, yf]
% and finds related marks that are not nan and average them. the averaged
% fingerprint is removed from the input
%
% Input:
% mli: input ml structure, field reconstruction has been completed
% options: BMMO/BL3 default options structure
%
% Output:
% mlo: output ml structure where field fingerprint have been removed

mlo = mli;

for ilayer = 1:mli.nlayer;
    for iwafer = 1:mli.nwafer;
        ml = ovl_get_layers(ovl_get_wafers(mli, iwafer), ilayer); 
        ml_avg = ovl_average_fields(bmmo_repair_intrafield_nans(ovl_get_fields(ml, options.fid_intrafield),options));
        ml_no_field = ovl_sub_field(ml, ml_avg);
        mlo.layer(ilayer).wr(iwafer).dx =  ml_no_field.layer.wr.dx;
        mlo.layer(ilayer).wr(iwafer).dy =  ml_no_field.layer.wr.dy;
    end
end

