function [grid_out_x, grid_out_y, index_out, num_unique_x] = bmmo_fix_nd_grid(grid_in_x, grid_in_y)
%function [grid_out_x, grid_out_y, index_out, num_unique_x] = bmmo_fix_nd_grid(grid_in_x, grid_in_y)
%
% Rearranges the input grid if necessary to ensure that it is in ndgrid
% format
%
% Input:
%       grid_in_x: vector or matrix that specifies a full grid of x
%           coordinates
%       grid_in_y: vector or matrix that specifies a full grid of y
%           coordinates
%
% Output:
%       grid_out_x: input x-grid in ndgrid format
%       grid_out_y: input y_grid in ndgrid format
%       index_out: linear mapping index between input and output grids
%       num_unique_x: number of unique elements in x

TOL = 1e-12;

% check that the fir
unique_x = uniquetol(grid_in_x, TOL);
unique_y = uniquetol(grid_in_y, TOL);

num_unique_x = numel(unique_x);

[grid_out_x, grid_out_y] = ndgrid(unique_x, unique_y);

index_out = knnsearch([reshape(grid_in_x, [], 1), reshape(grid_in_y, [], 1)], ...
    [reshape(grid_out_x, [], 1), reshape(grid_out_y, [], 1)]);

index_out = reshape(index_out, num_unique_x, []);




