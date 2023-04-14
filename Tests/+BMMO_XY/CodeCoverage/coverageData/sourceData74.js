var sourceData74 = {"FileContents":["function readout_nans = bmmo_count_readout_nans(mli)\r","% function readout_nans = bmmo_count_readout_nans(mli)\r","%\r","% Count the number of nans (dx or dy) per wafer in the input structure. Typically,\r","% these are marks invalidated by Yieldstar readout.\r","%\r","% Input:\r","%   mli: overlay structure\r","% \r","% Output: \r","%   readout_nans: 1* nwafer structure with the following fields:\r","%       x: n * 1, xw-coordinates of points with dx or dy = nan\r","%       y: n * 1, yw-coordinates of points with dx or dy = nan\r","\r","readout_nans = repmat(struct('x', [], 'y', []), 1, mli.nwafer);\r","\r","% only count readout NaNs for single_mark input -- otherwise the number is\r","% meaningless\r","\r","if mli.nmark == 1\r","    for iw = 1:mli.nwafer\r","        invalid_ids_this_wafer =  isnan(mli.layer.wr(iw).dx) | isnan(mli.layer.wr(iw).dy);\r","        readout_nans(iw).x = mli.wd.xw(invalid_ids_this_wafer);\r","        readout_nans(iw).y = mli.wd.yw(invalid_ids_this_wafer);\r","    end\r","end\r","\r",""],"CoverageData":{"CoveredLineNumbers":[15,20,21,22,23,24],"UnhitLineNumbers":[],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,122,0,0,0,0,122,120,622,622,622,0,0,0,0]}}