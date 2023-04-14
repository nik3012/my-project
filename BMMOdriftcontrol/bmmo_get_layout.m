function [ml, mi] = bmmo_get_layout(mli, layout, options)
%function [ml, mi] = bmmo_get_layout(mli, layout, options)
%
% Wrapper for ovl_get_layout to get desired layout from Baseliner ml struct
% (RINT target)
%
% Input:
%  mli: input ml struct
%  layout: desired reduced layout type, eg:'BA-XY-DYNA-25'
%  options: BMMO/BL3 option structure
%
% Output:
%   ml: overlay data with reduced layout
%   mi: index into full layout of selected marks

mark_layout = bmmo_get_mark_layout(layout, options);

[ml, mi] = ovl_get_layout(mli, mark_layout);