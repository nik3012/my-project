function [mlo, coeff] = bmmo_fit_model_pw_perfield(mli, options, varargin)
% function [mlo, coeff] = bmmo_fit_model_pw_perfield(mli, options, varargin)
%
% Fit the given parameters to the input overlay per wafer and per field, yielding 
% residuals mlo and fit coefficients coeff
%
% Inputs:
%   mli: ml overlay structure
%   options: options structure containing parameter table
%  
% Optional Inputs:
%   varargin: a variable number (possibly 0) of parameter names and
%             options, including the following:
%            '10par': fit 10par
%            '6par': fit 6par
%            'tx', 'ty', etc: parameters to fit
%
% Output: 
%   mlo: residue after per wafer and per field removal of Interfield/Intrafield 
%       content from mli  
%   coeff: q * m double matrix of fit coefficients, where q is the number of
%       parameters
%
% NB Make sure to call this function with valid parameter lists!
% NO checking is done on parameter order, duplication or validity

mlo = mli;

% get the field layout
wd_in = ovl_get_fields(mli, 1);
wd_in = wd_in.wd;
wd_in.xc = zeros(size(wd_in.xc));
wd_in.yc = zeros(size(wd_in.yc));

% get dy and dy input
dxs = horzcat(mli.layer.wr.dx);
dys = horzcat(mli.layer.wr.dy);

% reshape to put fields in columns
dxs = reshape(dxs, mli.nmark, []);
dys = reshape(dys, mli.nmark, []);

lenx = size(dxs, 1);

res_in = [dxs ; dys];

[res_out, coeff] = bmmo_fit_parms(res_in, wd_in, options, varargin);

for ilayer = 1:mli.nlayer
    base_layer_offset = (ilayer-1) * (mli.nwafer * mli.nfield);
    for iwafer = 1:mli.nwafer
        base_wafer_offset = ((iwafer-1) * (mli.nfield)) + base_layer_offset;
        columns_in_wafer = (base_wafer_offset + 1):(base_wafer_offset + mli.nfield);
        dxs = res_out(1:lenx, columns_in_wafer);
        dys = res_out((lenx+1):end, columns_in_wafer);
        mlo.layer(ilayer).wr(iwafer).dx = dxs(:);
        mlo.layer(ilayer).wr(iwafer).dy = dys(:);    
    end
end