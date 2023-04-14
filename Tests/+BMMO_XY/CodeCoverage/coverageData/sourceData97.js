var sourceData97 = {"FileContents":["function [ml_fit, coeff]= bmmo_fit_poly(ml, n)\r","% function mlo = bmmo_fit_poly(mli, n)\r","%\r","% Fit an nth order polynomial through the input ml data, returning the fitted \r","% fingerprint, the residual, and the fit coefficients\r","%\r","% Input: \r","%   ml: ml structure with 1 layer and 1 wafer\r","%   n: order of polynomial to fit\r","%\r","% Output:\r","%   ml_fit: fitted fingerprint\r","%   coeff: ((n + 1)*2) * 1 vector of fit coefficients\r","\r","if (ml.nwafer > 1)\r","    ml = ovl_get_wafers(ml, 1);\r","end\r","\r","% Get the linear system for the fit\r","[M, y, tmp_fit, nnan] = bmmo_get_poly_linear_system(ml, n);\r","\r","% perform the fit\r","coeff = pinv(M) * y;\r","fit = M * coeff;\r","\r","tmp_fit(nnan) = fit; %overwrites all non-NaN values of tmp_fit with fit\r","\r","% put dx and dy values in columns\r","tmp_fit = reshape(tmp_fit, [], 2);\r","\r","ml_fit = ml;\r","ml_fit.layer.wr.dx = tmp_fit(:,1);\r","ml_fit.layer.wr.dy = tmp_fit(:,2);\r","\r","\r",""],"CoverageData":{"CoveredLineNumbers":[15,20,23,24,26,29,31,32,33],"UnhitLineNumbers":16,"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,4,0,0,4,4,0,4,0,0,4,0,4,4,4,0,0,0]}}