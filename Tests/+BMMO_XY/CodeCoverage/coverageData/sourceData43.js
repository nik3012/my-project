var sourceData43 = {"FileContents":["function mlo = bmmo_average(mli)\r","% function mlo = bmmo_average(mli)\r","%\r","% Cut-down, optimized version of ovl_average that works with empty\r","% structures.\r","%\r","% Input:\r","%   mli: overlay structure\r","%\r","% Output\r","%   mlo: overlay structure with wafers in mli (if any) averaged to a single\r","%   wafer\r","\r","mlo = mli;\r","\r","tmp_nwafer = 0;\r","waf = struct('dx', [], 'dy', []);\r","layer = struct('wr', repmat(waf, 1, tmp_nwafer));\r","newlayer = repmat(layer, 1, mli.nlayer);\r","mlo.layer = newlayer;\r","mlo.nwafer = tmp_nwafer;\r","\r","for il = 1:mli.nlayer\r","    dxmat = horzcat(mli.layer(il).wr.dx);\r","    dymat = horzcat(mli.layer(il).wr.dy);\r","    \r","    nw = double(size(dxmat, 2) > 0);\r","    for iw = 1:nw\r","        mlo.layer(il).wr(nw).dx = nanmean_r12(dxmat, 2);\r","        mlo.layer(il).wr(nw).dy = nanmean_r12(dymat, 2);\r","    end\r","    mlo.nwafer = nw;\r","end\r","\r",""],"CoverageData":{"CoveredLineNumbers":[14,16,17,18,19,20,21,23,24,25,27,28,29,30,32],"UnhitLineNumbers":[],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,5611,0,5611,5611,5611,5611,5611,5611,0,5611,5611,5611,0,5611,5611,5604,5604,0,5611,0,0,0]}}