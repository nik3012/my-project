function ka_grid_out = bmmo_KA_grid_subset(ka_grid, KA_start)
% function ka_grid_out = bmmo_KA_grid_subset(ka_grid, KA_start)
%
% This function generates a reduced KA grid map from the provided input,
% ka_grid. 
%
% Input:
%  ka_grid: input KA grid (1x1 struct, containing fields: x,y,dx,dy)
%  KA_start: starting x and y value of the reduced KA grid map in m,eg: -0.15
%
% Output:
%  ka_grid_out: reduced KA grid 

TOL = 1e-15;
ka_grid_out = ka_grid;

idx_start = find(abs(ka_grid.interpolant_x.GridVectors{1} - KA_start) < TOL);
idx_end = find(abs(ka_grid.interpolant_x.GridVectors{1} + KA_start) < TOL);

ka_grid_out.x = ka_grid.x(idx_start:idx_end, idx_start:idx_end);
ka_grid_out.y = ka_grid.y(idx_start:idx_end, idx_start:idx_end);
ka_grid_out.dx = ka_grid.dx(idx_start:idx_end, idx_start:idx_end);
ka_grid_out.dy = ka_grid.dy(idx_start:idx_end, idx_start:idx_end);

ka_grid_out.interpolant_x = griddedInterpolant(ka_grid_out.x', ka_grid_out.y', ka_grid_out.dx', 'linear', 'linear');
ka_grid_out.interpolant_y = griddedInterpolant(ka_grid_out.x', ka_grid_out.y', ka_grid_out.dy', 'linear', 'linear');