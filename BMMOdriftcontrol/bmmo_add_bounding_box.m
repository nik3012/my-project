function ml_in_bb = bmmo_add_bounding_box(mli, boundary)
% function ml_in_bb = bmmo_add_bounding_box(mli, boundary)
%
% Extend the input layout with a bounding box. 
%
% Input:    
%   mli:                input layout
%   boundary:           position (in xw/yw coordinate system) at which to add bounding box
%                       NB it is the responsibility of the caller to ensure
%                           the bounding box is not inside or coincident
%                           with the layout
%
% Output:   
%   ml_in_bb:           layout with bounding box added to xw/yw and corresponding NaNs added to dx/dy
%                       NB the output values for marks in different
%                       coordinate systems will be inconsistent: use with
%                       care!

ml_in_bb = mli;
 
% assume it is indeed a bounding box, not coinciding or within target layout
bbx = boundary(:, 1);
bby = boundary(:, 2);
    
ml_in_bb.wd.xw = [ml_in_bb.wd.xw; bbx];
ml_in_bb.wd.yw = [ml_in_bb.wd.yw; bby];
for it_layer = ml_in_bb.nlayer
    for it_wafer = 1:ml_in_bb.nwafer
        ml_in_bb.layer(it_layer).wr(it_wafer).dx = [ml_in_bb.layer(it_layer).wr(it_wafer).dx; ones(size(bbx))*NaN];
        ml_in_bb.layer(it_layer).wr(it_wafer).dy = [ml_in_bb.layer(it_layer).wr(it_wafer).dy; ones(size(bby))*NaN];
    end
end
