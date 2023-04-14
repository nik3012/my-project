function ml_out  =  bmmo_sort_ml(ml_in, ml_target)
% function ml_out  =  bmmo_sort_ml(ml_in, ml_target)
%
% Sort a given ml structure based on a template ml structure 
%
% Input
%  ml_in: ml structure to be sorted
%  ml_target: template to get sorting order
%       
% Output:
%  ml_out: sorted ml structure


ml_out = ml_in;

% find indices
ind1 = knnsearch([ml_in.wd.xf ml_in.wd.yf], [ml_target.wd.xf, ml_target.wd.yf]); 
ind2 = knnsearch([ml_in.wd.xc ml_in.wd.yc], [ml_target.wd.xc, ml_target.wd.yc]); 
ind3 = knnsearch([ml_in.wd.xw ml_in.wd.yw], [ml_target.wd.xw, ml_target.wd.yw]); 

% sort ml_in coordinates (wd) as ml_target
ml_out.wd.xf = ml_in.wd.xf(ind1);
ml_out.wd.yf = ml_in.wd.yf(ind1);
ml_out.wd.xc = ml_in.wd.xc(ind2);
ml_out.wd.yc = ml_in.wd.yc(ind2);
ml_out.wd.xw = ml_in.wd.xw(ind3);
ml_out.wd.yw = ml_in.wd.yw(ind3);

% sort overlay (dx,dy) same as ml_target
for iw = 1:ml_in.nwafer
    ml_out.layer.wr(iw).dx =  ml_in.layer.wr(iw).dx(ind3);
    ml_out.layer.wr(iw).dy =  ml_in.layer.wr(iw).dy(ind3);
end
     