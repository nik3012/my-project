var sourceData146 = {"FileContents":["function mlo = bmmo_map_to_smf(mlp, mli, shift)\r","% function mlo = bmmo_map_to_smf(mlp, mli, shift)\r","%\r","% Converts the input mlp structure to SMF and also maps to the given SMF \r","% structure mli using shift as threshold for mapping\r","%\r","% Input: \r","%  mlp: overlay structure \r","%  mli: overlay structure in smf format\r","%  shift: threshold for mapping\r","%\r","% Output:\r","%  mlo: overlay structure mlp with same layout as mli\r","\r","if nargin < 3\r","    shift = 0.0003;\r","end\r","\r","mlc = bmmo_convert_to_smf(mlp);\r","mlo = mli;\r","\r","[idx2, D] = knnsearch([mlc.wd.xw mlc.wd.yw], [mli.wd.xw mli.wd.yw]);\r","valid = D < shift;\r","\r","for iw = 1:mli.nwafer\r","    mlo.layer.wr(iw).dx = mli.layer.wr(iw).dx * NaN;\r","    mlo.layer.wr(iw).dy = mli.layer.wr(iw).dy * NaN;\r","    mlo.layer.wr(iw).dx(valid) = mlc.layer.wr(iw).dx(idx2(valid));\r","    mlo.layer.wr(iw).dy(valid) = mlc.layer.wr(iw).dy(idx2(valid));\r","end"],"CoverageData":{"CoveredLineNumbers":[15,16,19,20,22,23,25,26,27,28,29],"UnhitLineNumbers":[],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,21,21,0,0,21,21,0,21,21,0,21,88,88,88,88,0]}}