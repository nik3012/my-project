function filter_out = bmmo_get_inverse_filter(filter_in)
% function filter_out = bmmo_get_inverse_filter(filter_in)
%
% Get (1 - filter) for the input filter
%
% Input
%   filter_in: structure containing filter coefficients for each component
%
% Output
%   filter_out: structure containing for each component value f of
%   filter_in, the value (1-f)

filter_out = filter_in;
filter_out.WH = 1 - filter_in.WH;
filter_out.MI = 1 - filter_in.MI;
filter_out.BAO = 1 - filter_in.BAO;
filter_out.KA = 1 - filter_in.KA;
filter_out.INTRAF = 1 - filter_in.INTRAF;

if isfield(filter_out, 'SUSD')
    filter_out.SUSD = 1 - filter_out.SUSD;
end