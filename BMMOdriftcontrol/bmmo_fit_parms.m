function [res, coeff] = bmmo_fit_parms(overlay_in, wd, options, varargin)
% function [res, coeff] = bmmo_fit_parms(overlay_in, wd, options, varargin)
%
% Fit the given parameters to the input overlay, yielding residuals res and
% fit coefficients coeff
%
% This is an implementation of fitting the overlay model in 
% http://techwiki.asml.com/index.php/Overlay_model
% It implements 
%   b = pinv(C) * y
% and
%   e =  y - (C * b) 
% where e = res, y = overlay_in, b = coeff, and the design matrix C is either
% given as wd, or calculated from wd and varargin
% 
%  
% Inputs:
%   overlay_in: (n * m) double matrix of input overlay 
%   wd:    Two possibilities:
%           1) structure of layout marks (from ml structure)
%           2) design matrix from bmmo_get_design_matrix
%   options: options structure containing parameter table
%  
% Optional Inputs:
%   varargin: a variable number (possibly 0) of parameter names and
%            options, including the following:
%           '10par': fit 10par
%           '6par': fit 6par
%           'tx', 'ty', etc: parameters to fit
%
%
% Output: 
%   res: (n * m) double matrix of output residuals
%   coeff: q * m double matrix of fit coefficients, where q is the number of
%       parameters
%
% NB Make sure to call this function with valid parameter lists!
% NO checking is done on parameter order, duplication or validity

if( ~isnumeric(wd) )
    % construct design matrix
    C = bmmo_get_design_matrix(wd, options, varargin);
else
    % design matrix already given
    C = wd;
end

% remove all-NaN rows in overlay_in
overlay_nans = isnan(overlay_in);
validindex = ~all(overlay_nans, 2);

% remove rows with NaNs from the design matrix
validC = ~isnan(C);
validC = all(validC, 2);
validindex = validindex & validC;

Cvalid = C(validindex, :);

% allocate the residual input
res = zeros(size(overlay_in)) * NaN;

% check if the only nans in the input are in all-nan rows
% if so, the computation of coefficients can be vectorized
if isequal(all(overlay_nans, 2), any(overlay_nans, 2))
    ovalid = overlay_in(validindex, :);
    coeff = pinv(Cvalid) * ovalid;
    res(validindex, :) = ovalid - (Cvalid * coeff);
else
    % otherwise, we compute coefficients column by column
    input_cols = size(overlay_in, 2);
    
    % allocate the coefficients structure
    coeff = zeros(size(Cvalid, 2), input_cols);
    
    for ic = 1:input_cols
        %remove nans from the input
        ov_c = overlay_in(:, ic);
        valid_index_c = ~isnan(ov_c);
        ov_c = ov_c(validindex);
        valid_ov_c = ~isnan(ov_c);
        ov_c = ov_c(valid_ov_c);
        Cv_c = Cvalid(valid_ov_c, :);
        
        coeff(:, ic) = pinv(Cv_c) * ov_c;
        res(valid_index_c, ic) = ov_c - (Cv_c * coeff(:, ic));
    end
end

