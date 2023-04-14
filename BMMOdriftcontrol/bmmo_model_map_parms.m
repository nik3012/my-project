function [x_out, y_out, params] = bmmo_model_map_parms(x_mirr, y_mirr, options, params)
% function [x_out, y_out, params] = bmmo_model_map_parms(x_mirr, y_mirr, options, params)
% 
% Remove 10par from the input mirror maps
%
% Input:
%  x_mirr: X mirror map
%  y_mirr: Y mirror map
%
% Optional Input:
%  options: BMMO/BL3 option structure
%  params: Remove 10 par from mirror maps using the parameters given in
%   params (ovl_model format)
%
% Output:
%   x_out: X mirror map with 10par removed
%   y_out: Y mirror map with 10par removed
%   params: 10 par list in ovl_model format (same as Optional input, if
%   provided)

if nargin < 3
    options = bmmo_default_options_structure;
end

if nargin < 4
    apply_par = 0;
else
    apply_par = 1;
end

% create filler zeros and index maps
z = zeros(size(y_mirr.x));
o = z + 1;
xmirr_map = logical([o; z]);
ymirr_map = logical([z; o]);

% Initialize layout to zeros, overlay to NaN
ml.wd.xc = [z; z];
ml.wd.yc = ml.wd.xc;
ml.wd.xf = ml.wd.xc;
ml.wd.yf = ml.wd.xc;
ml.layer.wr.dx = nan * ml.wd.xc;
ml.layer.wr.dy = nan * ml.wd.yc;

% The mirror map coordinates are wafer-centric
ml.wd.xc(ymirr_map) = y_mirr.x;
ml.wd.yc(xmirr_map) = x_mirr.y;
ml.wd.xw = ml.wd.xc;
ml.wd.yw = ml.wd.yc;

ml.layer.wr.dx(xmirr_map) = x_mirr.dx; 
ml.layer.wr.dy(ymirr_map) = y_mirr.dy;

% single-mark field
ml.nwafer = 1;
ml.nlayer = 1;
ml.nfield = length(ml.wd.xc);
ml.nmark = 1;
ml.tlgname = '';

% Remove edge before calculating 10par
ml_noedge = ovl_remove_edge(ml, options.edge_clearance);

if ~apply_par 
    [unused, params] = ovl_model(ml_noedge, '6parwafer'); 
end

%mlr = ovl_model(ml, 'apply', params, -1);
mlr = bmmo_apply_model(ml, params, -1, options);

x_out = x_mirr;
y_out = y_mirr;

x_out.dx = mlr.layer.wr.dx(xmirr_map);
y_out.dy = mlr.layer.wr.dy(ymirr_map);

