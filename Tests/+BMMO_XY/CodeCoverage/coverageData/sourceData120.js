var sourceData120 = {"FileContents":["function field_ids = bmmo_get_field_ids(ml, expinfo, tolerance)\r","% function field_ids = bmmo_get_field_ids(ml, expinfo, tolerance)\r","%\r","% Given an ml structure, and a structure expinfo containing a list of xc,yc\r","% coordinates, return the sorted list of fieldids (in ml) that are found in expinfo \r","% within a given tolerance level\r","%\r","% Input: ml: overlay structure\r","%        expinfo: structure containing the following fields:\r","%           xc: vector of field centre x coordinates\r","%           yc: vector of field centre y coordinates\r","%        tolerance: optional tolerance value for rounding\r","%\r","% Output: field_ids: sorted list of field ids\r","\r","if nargin < 3\r","    tolerance = 10;\r","end\r","exptol = 10^tolerance;\r","\r","% round the input data for comparison\r","xc_in = (round( ml.wd.xc .* exptol)) ./ exptol;\r","yc_in = (round( ml.wd.yc .* exptol)) ./ exptol;\r","\r","mxc_in = (round( expinfo.xc .* exptol)) ./ exptol;\r","myc_in = (round( expinfo.yc .* exptol)) ./ exptol;\r","\r","% find the unique field centres in ml. first, put the fields in columns\r","xc_in = reshape(xc_in, [], ml.nfield);\r","yc_in = reshape(yc_in, [], ml.nfield);\r","\r","% get the first row of the reshaped matrices (which will have the unique\r","% field centre coordinates in order)\r","xc_in = xc_in(1, :);\r","yc_in = yc_in(1, :);\r","\r","% reshape to column vectors\r","xc_in = xc_in';\r","yc_in = yc_in';\r","mxc_in = reshape(mxc_in, [], 1);\r","myc_in = reshape(myc_in, [], 1);\r","\r","layout_c = xc_in + 1i * yc_in;\r","exp_c = mxc_in + 1i * myc_in;\r","\r","% get the indices of exp_c that are also in layout_c\r","[unused, field_ids] = ismember(layout_c, exp_c);\r","\r","\r","\r","\r","\r",""],"CoverageData":{"CoveredLineNumbers":[16,17,19,22,23,25,26,29,30,34,35,38,39,40,41,43,44,47],"UnhitLineNumbers":[],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,240,240,0,240,0,0,240,240,0,240,240,0,0,240,240,0,0,0,240,240,0,0,240,240,240,240,0,240,240,0,0,240,0,0,0,0,0,0]}}