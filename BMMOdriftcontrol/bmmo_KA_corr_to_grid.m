function ka_grid = bmmo_KA_corr_to_grid(corr)
%function ka_grid = bmmo_KA_corr_to_grid(corr)
%
% Converts a KA grid in the format of the correction structure
% to a model internal grid structure with interpolants.
% Interpolants allow for faster bilinear interpolation of the grid
%
% Input
%   corr:    KA correction set
%
% Output
%   ka_grid: interpolated KA correction to KA grid
%

grid_length = sqrt(numel(corr.x));
ka_grid.x = reshape(corr.x, grid_length, []);
ka_grid.y = reshape(corr.y, grid_length, []);
ka_grid.dx = reshape(corr.dx, grid_length, []);
ka_grid.dy = reshape(corr.dy, grid_length, []);

ka_grid.interpolant_x = griddedInterpolant(ka_grid.x', ka_grid.y', ka_grid.dx', 'linear', 'linear');
ka_grid.interpolant_y = griddedInterpolant(ka_grid.x', ka_grid.y', ka_grid.dy', 'linear', 'linear');

