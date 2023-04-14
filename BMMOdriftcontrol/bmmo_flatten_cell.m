function s = bmmo_flatten_cell(c)
% function s = bmmo_flatten_cell(c)
%
% Convert multiple-nested cell array of strings to a flat
% cell array of strings. This is added to allow horzcat of strings and
% cell array of strings in Matlab R13, where the notation L = [C{:}] 
% will not work in general
% Note: this function is not overlay specific 
%
% Input: 
%  c: multiple-nested cell array 
%
% Output:
%   s =  c converted to flat cell array of strings
% Example:
%   C = {'A',{'B','C'}}
%   L = flatten_cell(C)
%   L = {'A', 'B', 'C'}
%
% See also: cell2str

clen = length(c);
for ic = 1:clen
    if(iscell(c{ic}))
        c{ic} = bmmo_flatten_cell(c{ic});
    else
        c(ic) = {c(ic)};
    end
end

if clen > 0
    s = [c{:}];
else
    s = c;
end