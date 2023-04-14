function [mlo, coeff] = bmmo_fit_model_perwafer(mli, options, varargin)
% function [mlo, coeff] = bmmo_fit_model_perwafer(mli, options, varargin)
%
% Fit the given parameters to the input overlay for each wafer, yielding 
% residuals mlo and fit coefficients coeff
%
% Inputs:
%   mli: ml overlay structure
%   options: options structure containing parameter table
%  
% Optional Inputs:
%   varargin: a variable number (possibly 0) of parameter names and
%            options, including the following:
%           '10par': fit 10par
%           '6par': fit 6par
%           'tx', 'ty', etc: parameters to fit
%
% Output: 
%   mlo: residue after per wafer removal of Interfield/Intrafield content
%       from mli  
%   coeff: q * m double matrix of fit coefficients, where q is the number of
%       parameters
%
% NB Make sure to call this function with valid parameter lists!
% NO checking is done on parameter order, duplication or validity

mlo = mli;

wd_in = mli.wd;

dxs = horzcat(mli.layer.wr.dx);
dys = horzcat(mli.layer.wr.dy);

lenx = size(dxs, 1);

res_in = [dxs ; dys];

[res_out, coeff] = bmmo_fit_parms(res_in, wd_in, options, varargin);

for ilayer = 1:mli.nlayer
    for iwafer = 1:mli.nwafer
        column = (mli.nwafer * (ilayer-1)) + iwafer;
        mlo.layer(ilayer).wr(iwafer).dx = res_out(1:lenx, column );
        mlo.layer(ilayer).wr(iwafer).dy = res_out((lenx+1):end, column);
    end
end

