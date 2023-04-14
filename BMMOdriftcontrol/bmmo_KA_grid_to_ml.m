function ml_ka = bmmo_KA_grid_to_ml(ka_grid)
% function ml_ka = bmmo_KA_grid_to_ml(ka_grid)
%
% The function converts KA grid to ml structure
%
% Input:
%  ka_grid: input KA grid (1x1 struct, containing fields: x,y,dx,dy)
%
% Output:
%  ml_ka: ka_grid converted to ml struct

ml_ka.wd.xf = reshape(ka_grid.x, [], 1);
ml_ka.wd.yf = reshape(ka_grid.y, [], 1);
ml_ka.wd.xc = zeros(size(ml_ka.wd.xf));
ml_ka.wd.yc = ml_ka.wd.xc;
ml_ka.wd.xw = ml_ka.wd.xf;
ml_ka.wd.yw = ml_ka.wd.yf;

ml_ka.nlayer = 1;
ml_ka.nwafer = 1;
ml_ka.nfield = 1;
ml_ka.nmark = numel(ml_ka.wd.xf);
ml_ka.tlgname = ' ';

ml_ka.layer.wr.dx = reshape(ka_grid.dx, [], 1);
ml_ka.layer.wr.dy = reshape(ka_grid.dy, [], 1);

