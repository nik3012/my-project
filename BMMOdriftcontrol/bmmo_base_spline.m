function x_out = bmmo_base_spline(x, x_start, x_end, nr_segments, options)
% function x_out = bmmo_base_spline(x, x_start, x_end, nr_segments, options)
%
% Wrapper for ovl_metro_base_spline, allowing selection of splines and
% manipulation of the spline matrix
%
% Input:
%   x            vector of x positions
%   x_start      Start position of spline
%   x_end        End position of spline
%   nr_segments  Number of segments in the spline
%   options      BMMO/BL3 options structure, containing at least the
%      following fields:
%           extra_splines: 1*4 double array with the following values
%               0/1/2   constant extrapolation 1 absent/present/present and reversed
%               0/1/2   constant extrapolation 2
%               0/1/2   translation absent/present/present and reversed
%                           (reversed is meaningless)
%               0/1/2   rotation absent/present/present and reversed
%
% Output:
%   x_out:     length(x)*(nr_segments+1) matrix with selected base
%               functions

% fill in a default value if not there already
try
    options.extra_splines;
catch
    options.extra_splines = [1 1 1 1];
end

% First calculate the number of splines to retrieve from
% ovl_metro_base_spline, based on the sum of extra_splines
totalextra = sum(options.extra_splines);

% ovl_metro_base_spline returns 4 extra splines
% after manipulation, the total number of splines should be nr_segments + 1
DEFAULT_EXTRA_SPLINES = 4;
requested_segments = nr_segments + (DEFAULT_EXTRA_SPLINES - totalextra);

% get the splines
x_sparse = ovl_metro_base_spline(x, x_start, x_end, requested_segments);
x_full = full(x_sparse);

% start with just the basic spline functions
x_out = x_full(:, 1:(end - DEFAULT_EXTRA_SPLINES));
last_basic_column = (size(x_full, 2) - DEFAULT_EXTRA_SPLINES);

% add the selected extra splines in the requested formats
for is = 1:length(options.extra_splines)
    this_spline =  x_full(:, last_basic_column + is);
    switch options.extra_splines(is)
        case 1
            % just append the spline fn to the output
            x_out = [x_out, this_spline];
        case 2
            % append the spline fn and its reverse
            x_out = [x_out, this_spline, this_spline(end:-1:1)];
            
            % otherwise do nothing
    end
    
end

