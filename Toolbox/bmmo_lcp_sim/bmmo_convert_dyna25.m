function mlo = bmmo_convert_dyna25(ml, FieldNum)
% function mlo = bmmo_convert_dyna25(ml, FieldNum)
%
% Convert specified fields of input structure to DYNA-25 Layout
%
% Input:
%   ml: overlay structure
%   Fieldnum: vector of field numbers to convert to DYNA-25 layout
%
% Output:
%   mlo: input structure with fields converted to DYNA-25
%
% 2016???? SBPR Creation

% construct a template dyna25 logical map
map = zeros(13,19);
map(1:4:end, 1:6:end) = 1;
map(3:4:end, 4:6:end) = 1;
map = logical(map(:));


  
ml_new = ovl_get_fields(ml, setdiff(1:ml.nfield,FieldNum) );
ml_field = ovl_get_fields(ml, FieldNum);
    
map = repmat(map, length(FieldNum), 1);

for iwafer=1:ml.nwafer
    for ilayer=1:ml.nlayer
        ml_field.layer(ilayer).wr(iwafer).dx(~map) = NaN;
        ml_field.layer(ilayer).wr(iwafer).dy(~map) = NaN;
    end
end
mlo = ovl_combine_fields(ml_new, ml_field, ml);
    

