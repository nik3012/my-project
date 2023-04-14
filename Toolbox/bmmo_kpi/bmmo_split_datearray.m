function dates_out = bmmo_split_datearray(dates_in)
% function dates_out = bmmo_split_datearray(dates_in)
%
% Expand a datetime array such that for each element in the input array
% there are three dates in the output, with equal time between them
%
% Input:
%   dates_in: 1*n datetime array
%
% Output:
%   dates_out: 1*(3n) datetime array
%
% 20171006 SBPR Creation

dur = reshape(diff([dates_in dates_in(end)+3]) / 3, [], 1);

dates_out = repmat(reshape(dates_in, [], 1), 1, 3);

dates_out(:, 2) = dates_out(:,2) + dur;
dates_out(:, 3) = dates_out(:,3) + (dur * 2);
dates_out = reshape(dates_out', 1, []);