function ml_apply = bmmo_apply_poly(ml, n, coeff)
% function ml_apply = bmmo_apply_poly(ml, n, coeff)
%
% Apply polynomial coefficients of order n to the input structure
%
% Input:
%   ml: structure with 1 layer and 1 wafer
%   n: maximum polynomial order
%   coeff: full set of coefficients of this order
%
% Output:
%   ml_apply: the result of applying the coefficients

% Get the linear system
[M, y, tmp_fit, nnan] = bmmo_get_poly_linear_system(ml, n);

% apply the fit coefficients
fit = (M * coeff) + y;

tmp_fit(nnan) = fit; %overwrites all non-NaN values of tmp_fit with fit

% put dx and dy values in columns
tmp_fit = reshape(tmp_fit, [], 2);

ml_apply = ml;
ml_apply.layer.wr.dx = tmp_fit(:,1);
ml_apply.layer.wr.dy = tmp_fit(:,2);
