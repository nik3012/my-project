function [mlo, fieldnos] = bmmo_get_innerfields(mli, options)
% function [mlo, fieldnos] = bmmo_get_innerfields(mli, options)
%
% Wrapper for ovl_get_innerfields (while the required update is under CCB
% review)
% Return the fields with all marks within the radius options.edge_clearance
%
% Input:
%   mli: standard overlay structure
%   options: bmmo options structure as defined in
%       bmmo_default_options_structure/bl3_default_options_structure
%
% Output:
%   mlo: mli with fields with marks outside options.edge_clearance removed
%   fieldnos: the field selection from mli, such that mlo =
%       ovl_get_fields(mli, fieldnos)
%
% Eventually, this function can be replaced by this line
% [mlo, fieldnos] = ovl_get_innerfields(mli, 'radius', options.edge_clearance, 'marks');

threshold = options.edge_clearance ^2;

% reshape xw, yw to put fields in columns
xw = reshape(mli.wd.xw, mli.nmark, []);
yw = reshape(mli.wd.yw, mli.nmark, []);

% get a squared distance matrix (since we're only interested in
% comparing with radius^2, we don't need to get the square root)
sqdist = xw.^2 +  yw.^2;

% the inner fields are those columns for which every mark is within
% the threshold
fieldnos = find(all(sqdist < threshold));

mlo = ovl_get_fields(mli, fieldnos);


