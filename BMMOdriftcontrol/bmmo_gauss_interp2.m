function [oDx, oDy] = bmmo_gauss_interp2(ingx, ingy, invalx, invaly, ogx, ogy, grid_size) 
% function [oDx, oDy] = bmmo_gauss_interp2(ingx, ingy, invalx, invaly, ogx, ogy, grid_size) 
%
% Weighted 2d interpolation using a gaussian function over a square grid
% of the given size. The weight for query mark is determined by its distance to 
% the sample grid, and then calculated by a gaussian function with zero mean and 
% 3sigma = grid_size. The weights are then normalized.
%
% Input:  
%   ingx:           Sample meshgrid x (m*n double)
%   ingy:           Sample meshgrid y (m*n double)
%   invalx:         Input values for dx (m*n double) - a function of ingx, ingy
%   invaly:         Input values for dy (m*n double) - a function of ingx, ingy
%   ogx:            Query meshgrid x (p*q double)
%   ogy:            Query meshgrid y (p*q double)
%   grid_size:      Side length of square interpolation grid (double)
% 
% Output:
%   oDx:            Output interpolated values for dx (p*q double)
%   oDy:            Output interpolated values for dy (p*q double)

DELTA = 2 * eps; % help correct for rounding errors;

% remove NaN values 
ivx = invalx(:);
ivy = invaly(:);
idnan = isnan(ivx) | isnan(ivy);
ivx(idnan) = [];
ivy(idnan) = [];

% generate vectors from the input mesh
ix = ingx(:); ix(idnan) = [];
iy = ingy(:); iy(idnan) = [];
ox = ogx(:);
oy = ogy(:);

oDx = zeros(size(ogx));
oDy = oDx;

% process output marks in chunks, so that we don't allocate matrices
% that are too large
current_index = 1;
num_points = length(ox); % since they're generated from a meshgrid, length(ox) == length(oy)

% set the chunk size we want to interpolate
CHUNKSIZE = 30; % experimentation suggests this value is around optimal for this algorithm
% (at least for the example input)

while current_index < num_points

    if (current_index + CHUNKSIZE) < num_points
        end_point = current_index + CHUNKSIZE;
    else
        end_point = num_points;
    end

    oxchunk = ox(current_index:end_point);
    oychunk = oy(current_index:end_point);

    % generate (large) i * o matrices
    % (output marks in columns)    
    % and get the difference between the two matrices
    % these are the only inputs we need
    [oi, iox] = meshgrid(oxchunk, ix);  
    iox = iox - oi;
    [oi, ioy] = meshgrid(oychunk, iy);    
    ioy = ioy - oi;

    % get the grid radius
    r = grid_size / 2;
    r = r + DELTA; % allow for rounding errors in the input

    % get the valid points for interpolation
    idvalid = sparse(iox > -r  & iox < r ) & sparse(ioy > -r & ioy < r);

    % get the distance and gaussian coefficients
    % to save processing time, just do this for valid points
    distance = sqrt(iox(idvalid).^2 + ioy(idvalid).^2);
    coeff = sub_gaussmf(distance, [grid_size/3 0]);


    % remap the coefficients to an i * o matrix
    % (coefficients for each output mark are in columns)
    normcoeffs = sparse(zeros(length(ivx), length(oxchunk)));
    normcoeffs(idvalid) = coeff;

    % get the vector of sums of each coefficient
    % (sum over the columns)
    coeffsum = sum(normcoeffs);

    % tile so we can do vectorized division
    coeffsum = repmat(coeffsum, length(ix), 1);

    % normalize the coefficients, ignoring zero values 
    % (suppresses DBZ warnings and improves performance)
    idvalid = normcoeffs > 0;
    normcoeffs(idvalid) = normcoeffs(idvalid) ./ coeffsum(idvalid);

    % get the output vectors    
    iv = repmat(ivx, 1, length(oxchunk));
    oDx_chunk = sum(iv .* normcoeffs);
    iv = repmat(ivy, 1, length(oychunk));
    oDy_chunk = sum(iv .* normcoeffs);

    oDx(current_index:end_point) = oDx_chunk;
    oDy(current_index:end_point) = oDy_chunk;
    current_index = end_point + 1;

end

oDx = full(oDx);
oDy = full(oDy);
    
  

function y = sub_gaussmf(x, params)
%GAUSSMF Gaussian curve membership function.
%   GAUSSMF(X, PARAMS) returns a matrix which is the Gaussian
%   membership function evaluated at X. PARAMS is a 2-element vector
%   that determines the shape and position of this membership function.
%   Specifically, the formula for this membership function is:
%
%   GAUSSMF(X, [SIGMA, C]) = EXP(-(X - C).^2/(2*SIGMA^2));
%   
%   For example:
%
%       x = (0:0.1:10)';
%       y1 = gaussmf(x, [0.5 5]);
%       y2 = gaussmf(x, [1 5]);
%       y3 = gaussmf(x, [2 5]);
%       y4 = gaussmf(x, [3 5]);
%       subplot(211); plot(x, [y1 y2 y3 y4]);
%       y1 = gaussmf(x, [1 2]);
%       y2 = gaussmf(x, [1 4]);
%       y3 = gaussmf(x, [1 6]);
%       y4 = gaussmf(x, [1 8]);
%       subplot(212); plot(x, [y1 y2 y3 y4]);
%       set(gcf, 'name', 'gaussmf', 'numbertitle', 'off');
%
%   See also DSIGMF,EVALMF, GAUSS2MF, GBELLMF, MF2MF, PIMF, PSIGMF, SIGMF,
%   SMF, TRAPMF, TRIMF, ZMF.

%   Roger Jang, 6-29-93, 10-5-93.
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.19 $  $Date: 2002/04/14 22:21:52 $

if nargin ~= 2
    error_r12('Two arguments are required by the Gaussian MF.');
elseif length(params) < 2
    error_r12('The Gaussian MF needs at least two parameters.');
elseif params(1) == 0,
    error_r12('The Gaussian MF needs a non-zero sigma.');
end

sigma = params(1); c = params(2);
y = exp(-(x - c).^2/(2*sigma^2));