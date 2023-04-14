function mlo = bmmo_construct_layout_from_ml(mli, options)
% function mlo = bmmo_construct_layout_from_ml(mli, options)
% 
% Construct the layout as defined in options.intrafield_reticle_layout from 
% the exposure info in the input structure
% 
% Input: 
%  mli: ml structure containing an expinfo substructure, as defined
%       in D000810611  EDS BMMO NXE drift control model
%  options: BMMO/BL3 default options structure
%
% Output: 
%  mlo: 1 * nlayer options.intrafield_reticle_layout layout with 
%       field centre coordinates from expinfo structure

% determine the number of layers by comparing the number of fields in
% expinfo with the defined field length of l1
totalfields = length(mli.expinfo.xc);
l1_end = options.layer_fields{1}(end);
if l1_end < totalfields
    nlayer = 2;
    options.layer_fields{2} = options.layer_fields{2}:length(mli.expinfo.xc);
else
    nlayer = 1;
end
mark_layout = bmmo_get_mark_layout(options.intrafield_reticle_layout, options);

for ilayer = 1:nlayer
   expinfo.xc = mli.expinfo.xc(options.layer_fields{ilayer});
   expinfo.yc = mli.expinfo.yc(options.layer_fields{ilayer});
   mlo(ilayer) = bmmo_construct_layout(expinfo.xc, expinfo.yc, mark_layout, 1, mli.nwafer);
   mlo(ilayer) = bmmo_shift_fields(mlo(ilayer), options.model_shift.x, options.model_shift.y, ilayer);
end
