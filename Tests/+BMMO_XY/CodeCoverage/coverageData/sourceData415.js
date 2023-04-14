var sourceData415 = {"FileContents":["function [xshift, yshift] = bmmo_get_shifts_from_expinfo(mli, expinfo)\r","% function [xshift, yshift] = bmmo_get_shifts_from_expinfo(mli, expinfo)\r","%\r","% Determine the relative layer shifts from expinfo\r","%\r","% Input: mli: overlay structure\r","%        expinfo: structure with fields\r","%           xc: 2n * 1 double vector of x field centre coordinates\r","%           yc: 2n * 1 double vector of y field centre coordinates\r","%\r","% Output:\r","%   xshift: x field centre shift to layer 2 (double)\r","%   yshift: y field centre shift to layer 2 (double)\r","%\r","% 20170519 SBPR Creation\r","\r","nfield = mli.nfield;\r","\r","v1 = [expinfo.xc(1:nfield), expinfo.yc(1:nfield)];\r","v2 = [expinfo.xc((nfield+1):end), expinfo.yc((nfield+1):end)];\r","I = knnsearch(v1, v2);\r","diffs = v2(I, :) - v1;\r","\r","shifts = mean(diffs);\r","xshift = shifts(1);\r","yshift = shifts(2);\r",""],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[17,19,20,21,22,24,25,26],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}