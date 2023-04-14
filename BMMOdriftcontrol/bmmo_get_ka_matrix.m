function ka_mat = bmmo_get_ka_matrix(ml, order)
% function ka_mat = bmmo_get_ka_matrix(ml, order)
%
% Given an input ml structure with m marks in ml.wd.xw/yw, return an m * (order + 1)
% matrix of polynomial functions for this input, where each column of the
% matrix is a unique function f(xw, yw) =  xw^n1.yw^n2, n1 + n2 = order,
% n1, n2 >= 0
%
% Input:
%   ml: ml data structure
%   order: polynomial order
% 
% Output:
%   ka_mat: m * (order + 1) matrix

% Get the exponents for this order
x_exp = order:-1:0;
y_exp = 0:order;

% make tiled matrices of exponents and x,y values for vectorized calculation
x = repmat(ml.wd.xw, 1, order + 1);
y = repmat(ml.wd.yw, 1, order + 1);
x_exp = repmat(x_exp, length(ml.wd.xw), 1);
y_exp = repmat(y_exp, length(ml.wd.yw), 1);

% Generate a matrix of KA values for this order
ka_mat =  x.^x_exp .* y.^y_exp; 
