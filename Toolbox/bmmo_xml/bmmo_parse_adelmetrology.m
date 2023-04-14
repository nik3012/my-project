function [xc, yc, xf, yf, labelid, dx, dy, validx, validy, labels, readout_date] = bmmo_parse_adelmetrology(filename)
% function [xc, yc, xf, yf, labelid, dx, dy, validx, validy, labels] = bmmo_parse_adelmetrology(filename)
%
% Parse Yieldstar ADELmetrology file to get wafer overlay data
%
% Input
%   filename: full path of ADELmetrology XML file
%
% Output (all measurements in metres)
%   xc: nmark * 1 double vector of field centre x coordinates
%   yc: nmark * 1 double vector of field centre y coordinates
%   xf: nmark * 1 double vector of intrafield x coordinates
%   yf: nmark * 1 double vector of intrafield y coordinates
%   labelid: nmark * 1 double vector of label ids (indices of labels cell
%           array)
%   dx: nmark * nwafer double matrix of valid dx overlay measurements
%   dy: nmark * nwafer double matrix of valid dy overlay measurements
%   labels: 1 * nlabels cell array of target label names
%
% This function uses the RapidXml C++ library Copyright (c) 2006, 2007 Marcin Kalicinski 
%
% 20170113 SBPR Creation

[xc, yc, xf, yf, labelid, dx, dy, validx, validy, labels, datestr] = bmmo_parse_adelmetrology_mex(filename);

try
    readout_date = bmmo_parse_adel_timestamp(datestr);
catch
    readout_date = 0;
end
    
xc = xc * 1e-3;
yc = yc * 1e-3;
xf = xf * 1e-3;
yf = yf * 1e-3;
dx = dx * 1e-9;
dy = dy * 1e-9;
