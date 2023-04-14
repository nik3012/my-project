function field_ids = bmmo_get_field_ids(ml, expinfo, tolerance)
% function field_ids = bmmo_get_field_ids(ml, expinfo, tolerance)
%
% Given an ml structure, and a structure expinfo containing a list of xc,yc
% coordinates, return the sorted list of fieldids (in ml) that are found in expinfo 
% within a given tolerance level
%
% Input: ml: overlay structure
%        expinfo: structure containing the following fields:
%           xc: vector of field centre x coordinates
%           yc: vector of field centre y coordinates
%        tolerance: optional tolerance value for rounding
%
% Output: field_ids: sorted list of field ids

if nargin < 3
    tolerance = 10;
end
exptol = 10^tolerance;

% round the input data for comparison
xc_in = (round( ml.wd.xc .* exptol)) ./ exptol;
yc_in = (round( ml.wd.yc .* exptol)) ./ exptol;

mxc_in = (round( expinfo.xc .* exptol)) ./ exptol;
myc_in = (round( expinfo.yc .* exptol)) ./ exptol;

% find the unique field centres in ml. first, put the fields in columns
xc_in = reshape(xc_in, [], ml.nfield);
yc_in = reshape(yc_in, [], ml.nfield);

% get the first row of the reshaped matrices (which will have the unique
% field centre coordinates in order)
xc_in = xc_in(1, :);
yc_in = yc_in(1, :);

% reshape to column vectors
xc_in = xc_in';
yc_in = yc_in';
mxc_in = reshape(mxc_in, [], 1);
myc_in = reshape(myc_in, [], 1);

layout_c = xc_in + 1i * yc_in;
exp_c = mxc_in + 1i * myc_in;

% get the indices of exp_c that are also in layout_c
[unused, field_ids] = ismember(layout_c, exp_c);





