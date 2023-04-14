function mlo = bmmo_apply_model(mli, parms, factor, options)
% function mlo = bmmo_apply_model(mli, parms, factor, options)
%
% The function models the inter/intrafield parameters using parms and
% estimates the residual by subtracting from mli
%
% Input:
%  mli: input overlay ml structure to remove interfield/intrafield
% parms: interfield/intrafield parameter structure, with one fieldname
%   per parameter name each field containing the value of the parameter
%   value is a 1*q array, where m is evenly divisible by q
% factor: (double) parms values are multiplied by this value
% options: options structure containing parameter table
%
% Output:
%  mlo: residue after removing Interfield/Intrafield content from mli

mlo = mli;
res_in = [[mli.layer.wr.dx]; [mli.layer.wr.dy]];
n = length(mli.layer.wr(1).dx);

res_out = bmmo_apply_parms(res_in, mli.wd, parms, factor, options);


for iw = 1:mli.nwafer
    mlo.layer.wr(iw).dx = res_out(1:n, iw);
    mlo.layer.wr(iw).dy = res_out((n+1):end, iw);
end

