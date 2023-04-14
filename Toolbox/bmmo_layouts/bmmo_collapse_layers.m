function [mlo, expinfo, xshift, yshift, layer_fields] = bmmo_collapse_layers(mli, expinfo)
% function [mlo, expinfo, xshift, yshift] = bmmo_collapse_layers(mli, expinfo)
%
% Convert n-field 2-layer structure to single-layer structure with 2n
% fields, with a field centre shift for the second layer. Optionally
% provide exposure info with field order; otherwise a default field order
% will be used.
%
% Input:
%   mli: overlay structure with 2 layers
%
% Optional Input:
%   expinfo: structure with fields
%       xc: 2n * 1 double vector of x field centre coordinates
%       yc: 2n * 1 double vector of y field centre coordinates
%
% Output:
%   mlo: overlay structure with 1 layer
%   expinfo: cf optional input
%   xshift: x field centre shift to layer 2 (double)
%   yshift: y field centre shift to layer 2 (double)
%   layer_fields: cell array with field IDs per layer
%
% 20170519 SBPR Creation

mlo = ovl_get_layers(mli, 1);
layer_fields{1} = 1:mlo.nfield;

if nargin < 2
    % initialize a default shift
    xshift = 0.52e-3;
    yshift = -0.52e-3;
    % generate a default expinfo with n layers
    expinfo = bmmo_get_default_expinfo(mlo);
    for il = 2:mli.nlayer
       newxc = expinfo.xc(1:mli.nfield) + (xshift * (il-1));
       newyc = expinfo.yc(1:mli.nfield) + (yshift * (il-1));
       newv = v(1:mli.nfield);
       expinfo.xc = [expinfo.xc ; newxc];
       expinfo.yc = [expinfo.yc ; newyc];
       expinfo.v = [expinfo.v ; newv];
    end
else
    %determine xshift and yshift from expinfo
    [xshift, yshift] = bmmo_get_shifts_from_expinfo(mli, expinfo);
end

shift_mag = sqrt(xshift^2 + yshift^2) + 1e-3;
tmpxc = reshape(expinfo.xc, [], mli.nlayer);
tmpyc = reshape(expinfo.yc, [], mli.nlayer);

for il = 2:mli.nlayer
   ml_il = ovl_get_layers(mli, il);
   
   % generate a template layout with same field ordering as in expinfo
   xc = tmpxc(:, il);
   yc = tmpyc(:, il);
   
   mlt = bmmo_construct_layout(xc, yc, ml_il, 1, ml_il.nwafer);
   
   mlmap = bmmo_map_shifted_layouts(ml_il, mlt, shift_mag);
   
   mlo = ovl_combine_fields(mlo, mlmap);
   layer_fields{il} = ((mli.nfield * (il-1)) + 1):(mli.nfield * il);
end


