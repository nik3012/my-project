function [M, y, ovl_vec ,valid]= bmmo_get_poly_linear_system(ml, n)
% function [M, y, ovl_vec ,valid]= bmmo_get_poly_linear_system(ml, n)
%
% Get a linear system for polynomial fitting
%
% Input: 
%   ml: ml structure with 1 layer and 1 wafer
%   n: order of polynomial to fit
%
% Output:
%   M: design matrix of linear system, NaNs removed
%   y: overlay vector with NaNs removed
%   ovl_vec: overlay vector (inlcuding NaNs)
%   valid: valid indices of overlay vector

% Allocate the KA matrix
ka_size = sum(1:(n+1));
ka_mat = zeros(length(ml.wd.xw), ka_size);

for in = 0:n
    % Get a basic matrix of polynomials for order n
    % this is a m*(n+1) matrix, where m is the total number of marks in ml
    ka_mat(:, sub_get_cols(in)) = bmmo_get_ka_matrix(ml, in);    
end

% Create a zero matrix for tiling
zero_mat = zeros(size(ka_mat));

% Build the design matrix M 
M = [ka_mat, zero_mat; zero_mat, ka_mat];

% Build the overlay vector y
% First allocate an output for the fit
ovl_vec = [ml.layer.wr.dx; ml.layer.wr.dy];

% Remove NaNs from y and M
valid = ~isnan(ovl_vec);
y = ovl_vec(valid);
M = M(valid, :);



function v = sub_get_cols(n)

min = sum(0:n)+1;
max = sum(0:n+1);
v = min:max;
