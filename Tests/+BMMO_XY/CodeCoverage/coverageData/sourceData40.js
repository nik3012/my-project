var sourceData40 = {"FileContents":["function res_out = bmmo_apply_parms(res_in, wd, parms, apply_factor, options, varargin)\r","% function res_out = bmmo_apply_parms(res_in, wd, parms, apply_factor, options, varargin)\r","%\r","% Apply the parameters in parms on the input overlay res_in,\r","% yielding the residuals res_out\r","%\r","% This is an implementation of applying the overlay model in\r","% http://techwiki.asml.com/index.php/Overlay_model\r","% It implements y =  Cb + e\r","% where e = res_in, y = res_out, b = parms, and the design matrix C is either\r","% given as wd, or calculated from wd and varargin\r","%\r","% Inputs:\r","%   res_in: (n * m) double matrix of input residuals\r","%   wd:    Two possibilities:\r","%           1) structure of layout marks (from ml structure)\r","%           2) design matrix from bmmo_get_design_matrix\r","%   parms: structure with one fieldname per parameter name\r","%           each field containing the value of the parameter\r","%           value is a 1*q array, where m is evenly divisible by q\r","%   apply_factor: (double) parm values are multiplied by this value\r","%   options: options structure containing parameter table\r","%\r","% Optional Inputs:\r","%   varargin: a variable number (possibly 0) of parameter names and\r","%   options, including the following:\r","%           'xonly': construct only x matrix (default is to construct both)\r","%           'yonly': construct only y matrix\r","%\r","% Output:\r","%   res_out: (n * m) double matrix of output residuals\r","\r","% build a parameter matrix from the input structure\r","parnames = fieldnames(parms);\r","numpars = length(parnames);\r","parm_matrix = struct2array(parms);\r","parm_matrix = reshape(parm_matrix, [], numpars);\r","parm_matrix = parm_matrix' * apply_factor;\r","\r","% tile the matrix so that its size agrees with res_in\r","tile_factor = size(res_in, 2) / size(parm_matrix, 2);\r","parm_matrix = repmat(parm_matrix, 1, tile_factor);\r","\r","if( ~isnumeric(wd) )\r","    % construct design matrix\r","    C = bmmo_get_design_matrix(wd, options, varargin, parnames);\r","else\r","    % design matrix already given\r","    C = wd;\r","end\r","\r","% find NaN rows in res_in\r","validindex = ~isnan(res_in);\r","validindex = all(validindex, 2);\r","\r","% apply the parameters\r","res_out = zeros(size(res_in)) * nan;\r","res_out(validindex,:) = res_in(validindex,:) + (C(validindex,:) * parm_matrix);\r","\r",""],"CoverageData":{"CoveredLineNumbers":[34,35,36,37,38,41,42,44,46,47,49,53,54,57,58],"UnhitLineNumbers":[],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3141,3141,3141,3141,3141,0,0,3141,3141,0,3141,0,3140,1,0,1,0,0,0,3141,3141,0,0,3141,3141,0,0]}}