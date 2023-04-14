function mlo = bmmo_map_layouts(mli, mlt, tolerance_exponent)
% function mlo = bmmo_map_layouts(mli, mlt, tolerance_exponent)
%
% Map the overlay data in layout mli to target layout mlt, given a
% tolerance exponent of difference on the nominal mark positions
%
% Input: 
%  mli: input ml structure
%  mlt: target ml structure
%  tolerance_exponent: (positive) exponent of tolerance to which
%   mark positions will be rounded.Marks in each structure will be 
%   rounded to the nearest (10^(-tolerance_exponent))m before testing for equality
%
% Note: after rounding to the nearest tolerance, the layout marks must
% correspond exactly

mlo = mlt;
mlo.nwafer = mli.nwafer;
mlo.nlayer = mli.nlayer;

[imask, iloc] = bmmo_wd_ismember(mli.wd.xw, mli.wd.yw, mlt.wd.xw, mlt.wd.yw, tolerance_exponent);

for ilayer = 1:mli.nlayer
    for iwafer = 1:mli.nwafer
        % Initialize output to NaN
        mlo.layer(ilayer).wr(iwafer).dx = nan * zeros(mlo.nfield*mlo.nmark,1);
        mlo.layer(ilayer).wr(iwafer).dy = nan * zeros(mlo.nfield*mlo.nmark,1);
       
        mlo.layer(ilayer).wr(iwafer).dx(iloc(imask)) = mli.layer(ilayer).wr(iwafer).dx(imask);
        mlo.layer(ilayer).wr(iwafer).dy(iloc(imask)) = mli.layer(ilayer).wr(iwafer).dy(imask); 
    end
end