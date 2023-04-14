function stats = bmmo_default_outlier_stats(mli)
% function stats = bmmo_default_outlier_stats(mli)
%
% Create an all-zero outlier statistics structure based on the input mli
%
% Input: 
%   mli:        standard overlay structure
%
% Output: 
% stats:        structure with the following field: 
%       layer: 1 x nlayer array of structures with the following field:
%       wafer: 1 x n wafer array of structures with following fields (initialised to zero):
%           n: (double) number of outliers in this wafer
%           x: 1 x n double array of xw-coordinates of outliers
%           y: 1 x n double array of yw-coordinates of outliers
%         idx: 1 x n double array of layer.wr.dx/dy indices of outliers
%           r: 1 x n double array of outlier nominal distances from centre of wafer
%          dr: 1 x n double array of outlier distances from nominal mark position


stats = repmat(struct('layer', []), 1, mli.nlayer);
waferstats = repmat(struct('x', [], 'y', [], 'idx', [], 'r', [], 'dr', [], 'n', 0), 1,mli.nwafer);

for il = 1:mli.nlayer
    stats.layer(il).wafer = waferstats;
end