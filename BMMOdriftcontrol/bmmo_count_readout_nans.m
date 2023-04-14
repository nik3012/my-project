function readout_nans = bmmo_count_readout_nans(mli)
% function readout_nans = bmmo_count_readout_nans(mli)
%
% Count the number of nans (dx or dy) per wafer in the input structure. Typically,
% these are marks invalidated by Yieldstar readout.
%
% Input:
%   mli: overlay structure
% 
% Output: 
%   readout_nans: 1* nwafer structure with the following fields:
%       x: n * 1, xw-coordinates of points with dx or dy = nan
%       y: n * 1, yw-coordinates of points with dx or dy = nan

readout_nans = repmat(struct('x', [], 'y', []), 1, mli.nwafer);

% only count readout NaNs for single_mark input -- otherwise the number is
% meaningless

if mli.nmark == 1
    for iw = 1:mli.nwafer
        invalid_ids_this_wafer =  isnan(mli.layer.wr(iw).dx) | isnan(mli.layer.wr(iw).dy);
        readout_nans(iw).x = mli.wd.xw(invalid_ids_this_wafer);
        readout_nans(iw).y = mli.wd.yw(invalid_ids_this_wafer);
    end
end

