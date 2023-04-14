function [mlo, coeff] = bmmo_fit_model(mli, options, varargin)
% function [mlo, coeff] = bmmo_fit_model(mli, options, varargin)
%
% Fit the given parameters to the input ml overlay struct, yielding 
% residuals mlo and fit coefficients coeff
%
% Input:
%  mli: ml overlay structure
%  options: options structure containing parameter table
%  
% Optional Inputs:
%   varargin: a variable number (possibly 0) of parameter names and
%            options, including the following:
%           '10par': fit 10par
%           '6par': fit 6par
%           'tx', 'ty', etc: parameters to fit
%
% Output: 
%   mlo: ml struct of output residuals
%   coeff: values of fit coefficents

wd_in = struct;
[wd_in.xc, wd_in.yc, wd_in.xf, wd_in.yf, dxc, dyc] = ovl_concat_wafer_results(mli);
wd_in.xw = wd_in.xc + wd_in.xf;
wd_in.yw = wd_in.yc + wd_in.yf;
res_in = [dxc; dyc];
lenx = length(dxc);

[res_out, coeff_out] = bmmo_fit_parms(res_in, wd_in, options, varargin);

mlo = ovl_distribute_wafer_results(mli, res_out(1:lenx), res_out((lenx+1):end));

coeff = bmmo_get_apply_par(coeff_out, varargin);

