function filter_out = bmmo_get_empty_filter
% function filter_out = bmmo_get_empty_filter
%
% Get filter structure containing all ones
%
% Input: None
%
% Output:
%   filter_out: structure containing a value of 1 for each correction
%   component

filter_out.WH = 1;
filter_out.MI = 1; 
filter_out.BAO = 1;
filter_out.KA = 1; 
filter_out.INTRAF = 1;
filter_out.SUSD = 1;