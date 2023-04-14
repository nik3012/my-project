function mlo = bmmo_shift_fields(mli, xshift, yshift, layer)
% function mlo = bmmo_shift_fields(mli, xshift, yshift, layer)
%
% Given an input structure, shift the fields by the given xshift and yshift
% in xf and yf
%
% Input
%   mli:        ml structure
%   x_shift:    (at least) layer * n array, where n is either 1 (if only field centre
%               coordinates are to be shifted) or 2 (if intrafield coordinates are also to be shifted)
%   y_shift:    (at least) layer * n array, where n is either 1 (if only field centre
%               coordinates are to be shifted) or 2 (if intrafield coordinates are also to be shifted)
%   layer: (optional) layer which is to be shifted; defaults to 1
%
%   An example of a valid x_shift is as follows:
%
%   xc shift   xf shift
%  [100e-6     -250e-6    layer 1 shift 
%   0          520e-6]    layer 2 shift
%
%   In the above example, for layer 1, 100e-6 will be added to xc and
%   -250e-6 to xf.
%
% Output:
%   mlo:        mli after shifts applied

% Default layer for backwards compatibility
if nargin < 4
    layer = 1;
end

mlo = mli;

% Names of coordinate fields
x_coord = {'xc', 'xf'};
y_coord = {'yc', 'yf'};

% Perform the shift
xs = xshift(layer, :);
for ic = 1:length(xs)
    mlo.wd.(x_coord{ic}) = mlo.wd.(x_coord{ic}) + xshift(layer, ic);
    mlo.wd.(y_coord{ic}) = mlo.wd.(y_coord{ic}) + yshift(layer, ic);
end
mlo.wd.xw = mlo.wd.xc + mlo.wd.xf;
mlo.wd.yw = mlo.wd.yc + mlo.wd.yf;