function mlo = bmmo_construct_layout(xc, yc, mark_layout, nlayer, nwafer)
% function mlo = bmmo_construct_layout(xc, yc, intrafield_layout)
% 
% Given field centre positions and an intrafield layout, return an empty 
%   layout structure with the given number of layers and wafers
% 
% Input: xc: nfield * 1 vector of x field centre positions in exposure order
%        yc: nfield * 1 vector of y field centre positions in exposure order
%        layout: valid intrafield layout for ovl_create_dummy: can be an ml
%           structure
%        nlayer: number of layers
%        nwafer: number of wafers
%
% Output: mlo: 1 * nlayer layout with field centre coordinates from xc, yc
%
% 20170519 SBPR Adapted from bmmo_construct_13x19_layout


% Create the wd portion of an ml structure based on the field centre
% coordinates in expinfo

% Use expinfo to construct the xc,yc values
mlo.nfield   = length(xc);

% Get the intrafield coordinates
dummy_wafer = ovl_create_dummy('marklayout', mark_layout, 'nlayer', 1,  'nwafer', 1);
dummy_field = ovl_get_fields(dummy_wafer, 1);

mlo.nmark    = dummy_field.nmark;
mlo.nlayer   = 1;
mlo.nwafer   = nwafer;
mlo.nlayer   = nlayer;
mlo.expinfo.xc = xc;
mlo.expinfo.yc = yc;

mlo.wd.xc = reshape(repmat(xc, 1, mlo.nmark)',[],1);
mlo.wd.yc = reshape(repmat(yc, 1, mlo.nmark)',[],1);
mlo.wd.xf = reshape(repmat(dummy_field.wd.xf,[mlo.nfield 1]),[],1);
mlo.wd.yf = reshape(repmat(dummy_field.wd.yf,[mlo.nfield 1]),[],1);
mlo.wd.xw = mlo.wd.xc + mlo.wd.xf;
mlo.wd.yw = mlo.wd.yc + mlo.wd.yf;

for il = 1:mlo.nlayer
   for iw = 1:mlo.nwafer
       mlo.layer(il).wr(iw).dx = NaN * zeros(size(mlo.wd.xw));
       mlo.layer(il).wr(iw).dy = mlo.layer(il).wr(iw).dx;
   end
end

