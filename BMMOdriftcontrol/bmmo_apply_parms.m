function res_out = bmmo_apply_parms(res_in, wd, parms, apply_factor, options, varargin)
% function res_out = bmmo_apply_parms(res_in, wd, parms, apply_factor, options, varargin)
%
% Apply the parameters in parms on the input overlay res_in,
% yielding the residuals res_out
%
% This is an implementation of applying the overlay model in
% http://techwiki.asml.com/index.php/Overlay_model
% It implements y =  Cb + e
% where e = res_in, y = res_out, b = parms, and the design matrix C is either
% given as wd, or calculated from wd and varargin
%
% Inputs:
%   res_in: (n * m) double matrix of input residuals
%   wd:    Two possibilities:
%           1) structure of layout marks (from ml structure)
%           2) design matrix from bmmo_get_design_matrix
%   parms: structure with one fieldname per parameter name
%           each field containing the value of the parameter
%           value is a 1*q array, where m is evenly divisible by q
%   apply_factor: (double) parm values are multiplied by this value
%   options: options structure containing parameter table
%
% Optional Inputs:
%   varargin: a variable number (possibly 0) of parameter names and
%   options, including the following:
%           'xonly': construct only x matrix (default is to construct both)
%           'yonly': construct only y matrix
%
% Output:
%   res_out: (n * m) double matrix of output residuals

% build a parameter matrix from the input structure
parnames = fieldnames(parms);
numpars = length(parnames);
parm_matrix = struct2array(parms);
parm_matrix = reshape(parm_matrix, [], numpars);
parm_matrix = parm_matrix' * apply_factor;

% tile the matrix so that its size agrees with res_in
tile_factor = size(res_in, 2) / size(parm_matrix, 2);
parm_matrix = repmat(parm_matrix, 1, tile_factor);

if( ~isnumeric(wd) )
    % construct design matrix
    C = bmmo_get_design_matrix(wd, options, varargin, parnames);
else
    % design matrix already given
    C = wd;
end

% find NaN rows in res_in
validindex = ~isnan(res_in);
validindex = all(validindex, 2);

% apply the parameters
res_out = zeros(size(res_in)) * nan;
res_out(validindex,:) = res_in(validindex,:) + (C(validindex,:) * parm_matrix);

