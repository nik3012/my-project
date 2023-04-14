function [xy, dxy] = bmmo_parse_wec(wecfile)
% function [xy, dxy] = bmmo_parse_wec(wecfile)
%
% Parses a WEC file (tested on WEC v1.4 ONLY) to extract the nominal
% positions (xy) and corresponding valid position error (dxy)
%
% Input:
%   wecfile: full path of wec file name (string)
%
% Output:
%   xy: n*2 double vector of x (col 1) and y (col 2) mark positions in metres, for the n
%       marks in the wec file
%   dxy: n*2 double vector of dx (col 1) and dy (col 2) position errors in metres, for the n
%       marks in the WEC file. Invalid position errors are set to NaN
%   
%   NB This is only tested on WEC v1.4
%   
%   20160113 SBPR Creation. This uses the RapidXml C++ library Copyright (c) 2006, 2007 Marcin Kalicinski 

[xy, dxy, valid] = bmmo_parse_wec_mex(wecfile);

xy = xy * 1e-3;
dxy = dxy * 1e-9;
dxy(~valid) = NaN;