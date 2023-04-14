function [xshift, yshift] = bmmo_get_shifts_from_expinfo(mli, expinfo)
% function [xshift, yshift] = bmmo_get_shifts_from_expinfo(mli, expinfo)
%
% Determine the relative layer shifts from expinfo
%
% Input: mli: overlay structure
%        expinfo: structure with fields
%           xc: 2n * 1 double vector of x field centre coordinates
%           yc: 2n * 1 double vector of y field centre coordinates
%
% Output:
%   xshift: x field centre shift to layer 2 (double)
%   yshift: y field centre shift to layer 2 (double)
%
% 20170519 SBPR Creation

nfield = mli.nfield;

v1 = [expinfo.xc(1:nfield), expinfo.yc(1:nfield)];
v2 = [expinfo.xc((nfield+1):end), expinfo.yc((nfield+1):end)];
I = knnsearch(v1, v2);
diffs = v2(I, :) - v1;

shifts = mean(diffs);
xshift = shifts(1);
yshift = shifts(2);
