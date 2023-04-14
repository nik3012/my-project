function bar_struct = bmmo_log_progress(msg, bar_struct)
% function bmmo_log_progress(msg, bar_struct)
%
% Log progress message either to stdout or to a progress bar
%
% Input:
%   msg: progress message to log
%
% Optional input:
%   bar_struct: progress bar structure with following fields
%       update: handle to update function for progress bar
%
% Output: bar_struct: input bar_struct updated after logging progress
%       message
%
% 20170131 SBPR Creation

if nargin < 2
    bar_struct = [];
end

if isstruct(bar_struct)
    bar_struct = feval(bar_struct.update, msg, bar_struct); 
else
    disp(msg);
end