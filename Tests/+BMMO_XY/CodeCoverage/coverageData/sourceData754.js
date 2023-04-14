var sourceData754 = {"FileContents":["function ffpo = bmmo_map_ffp(ml, ffp)\r","% function ffpo = bmmo_map_ffp(ml, ffp)\r","%\r","% Map SBC2 field fingerprint (ffp) to field layout of ml structure\r","%\r","% Input:\r","%   ml: overlay structure with m marks per field\r","%   ffp: 1*2 SBC2 field fingerprint structure, with following fields\r","%       x: n*1 vector of nominal x mark positions\r","%       y: n*1 vector of nominal y mark positions\r","%       dx: n*1 vector of x offsets for each mark\r","%       dy: n*1 vector of y offsets for each mark\r","%\r","% Output\r","%   ffpo: 1*2 SBC2 field fingerprint with layout mapped to ml, with following fields:\r","%       x: m*1 vector of nominal x mark positions\r","%       y: m*1 vector of nominal y mark positions\r","%       dx: m*1 vector of x offsets for each mark\r","%       dy: m*1 vector of y offsets for each mark\r","%\r","%   20170601 SBPR Added documentation\r","\r","% get index I\r","mlf = ovl_get_fields(ml, 1);\r","\r","I = knnsearch([ffp(1).x ffp(1).y], [mlf.wd.xf mlf.wd.yf]);\r","\r","for ic = 1:length(ffp)\r","    ffpo(ic).x = mlf.wd.xf;\r","    ffpo(ic).y = mlf.wd.yf;\r","    ffpo(ic).dx = ffp(ic).dx(I);\r","    ffpo(ic).dy = ffp(ic).dy(I);\r","end"],"CoverageData":{"CoveredLineNumbers":[24,26,28,29,30,31,32],"UnhitLineNumbers":[],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,1,2,2,2,2,0]}}