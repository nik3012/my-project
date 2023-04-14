function ka_grid = bmmo_KA_fix_interpolant(ka_grid)    
%function ka_grid = bmmo_KA_fix_interpolant(ka_grid)
% 
% adds interpolants to KA grid, for faster interpolation inside the model
%
% Input
%   ka_grid: input KA grid
%
% Output
%   ka_grid: KA grid with interpolants

gridsize = sqrt(numel(ka_grid.x));

xg = transpose(reshape(ka_grid.x, gridsize, gridsize));
yg = transpose(reshape(ka_grid.y, gridsize, gridsize));
dxg = transpose(reshape(ka_grid.dx, gridsize, gridsize));
dyg = transpose(reshape(ka_grid.dy, gridsize, gridsize));

ka_grid.interpolant_x = griddedInterpolant(xg, yg, dxg, 'linear', 'linear');
ka_grid.interpolant_y = griddedInterpolant(xg, yg, dyg, 'linear', 'linear');