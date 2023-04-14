function ka_grid = bmmo_mlKA_to_grid(ml_ka)
% function ka_grid = bmmo_mlKA_to_grid(ml_ka)
%
% The function converts KA grid in ml struct format to KA grid layout
% format [KA.x KA.y KA.dx KA.dy] and also adds interpolants to the structure.
%
% Input:
%  ml_ka: KA grid in ml struct, single wafer 
% 
% Output:
%  ka_grid: ml_ka converted to KA grid layout (1x1 struct) with interpolants

% map to square KA grid
grid_length = sqrt(ml_ka.nmark);
ka_grid.x = reshape(ml_ka.wd.xf, grid_length, []);
ka_grid.y = reshape(ml_ka.wd.yf, grid_length, []);
ka_grid.dx = reshape(ml_ka.layer.wr.dx, grid_length, []);
ka_grid.dy = reshape(ml_ka.layer.wr.dy, grid_length, []);

ka_grid.interpolant_x = griddedInterpolant(ka_grid.x', ka_grid.y', ka_grid.dx', 'linear', 'linear');
ka_grid.interpolant_y = griddedInterpolant(ka_grid.x', ka_grid.y', ka_grid.dy', 'linear', 'linear');