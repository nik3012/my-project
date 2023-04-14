function [ml_new] = bmmo_convert_layout2_7(ml, what, FieldNum)
% function [ml_new] = bmmo_convert_layout2_7(ml, what, FieldNum)
%
% This function takes fields in a 13x19 layout
% and makes either a 13x7 or 7x19 layout by inserting NaNs, depending on
% the value of 'what'.
% This function is used for the edge fields in the mirror model.
%
% Input :
% ml : input struct with 13x19 layout
%      NB the input must be in 13x19 layout or this function will not
%      work!
% what : either 'x' or 'y'. 'x' will prodice a 7x19 layout. 'y' will
%        produce a 13x7 layout.
% FieldNum : vector of field numbers on which to change the layout
%
% Output:
% ml_new : ml with fields in fieldnum set to a simulated 13x7 or 7x19 layout
%          NB the layout will still have 13x19 marks per field
%          marks not in the 13x7 or 7x19 layout will be set to NaN

ml_new = ovl_get_fields(ml, setdiff(1:ml.nfield,FieldNum) );
ml_field = ovl_get_fields(ml, FieldNum);

valid_x = [1:2:13]; % 7 from 13 values
valid_y = [1:3:19]; % 7 from 19 values

switch(lower(what))
    case 'x'
        [unused1, unused2, c1]=unique(ml_field.wd.xf);
        NaN_ind = ~ismember(c1, valid_x);
    case 'y'
        [unused1, unused2, c1]=unique(ml_field.wd.yf);
        NaN_ind = ~ismember(c1, valid_y);
    otherwise
        error_r12('No such case exists: bmmo_convert_layout2_7');
end


for iwafer=1:ml.nwafer
    for ilayer=1:ml.nlayer
        ml_field.layer(ilayer).wr(iwafer).dx(NaN_ind) = NaN;
        ml_field.layer(ilayer).wr(iwafer).dy(NaN_ind) = NaN;
    end
end
ml_new = ovl_combine_fields(ml_new, ml_field, ml);


