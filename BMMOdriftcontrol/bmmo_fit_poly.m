function [ml_fit, coeff]= bmmo_fit_poly(ml, n)
% function mlo = bmmo_fit_poly(mli, n)
%
% Fit an nth order polynomial through the input ml data, returning the fitted 
% fingerprint, the residual, and the fit coefficients
%
% Input: 
%   ml: ml structure with 1 layer and 1 wafer
%   n: order of polynomial to fit
%
% Output:
%   ml_fit: fitted fingerprint
%   coeff: ((n + 1)*2) * 1 vector of fit coefficients

if (ml.nwafer > 1)
    ml = ovl_get_wafers(ml, 1);
end

% Get the linear system for the fit
[M, y, tmp_fit, nnan] = bmmo_get_poly_linear_system(ml, n);

% perform the fit
coeff = pinv(M) * y;
fit = M * coeff;

tmp_fit(nnan) = fit; %overwrites all non-NaN values of tmp_fit with fit

% put dx and dy values in columns
tmp_fit = reshape(tmp_fit, [], 2);

ml_fit = ml;
ml_fit.layer.wr.dx = tmp_fit(:,1);
ml_fit.layer.wr.dy = tmp_fit(:,2);


