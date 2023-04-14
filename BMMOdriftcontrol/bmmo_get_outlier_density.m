function [mean_density, max_density_per_wafer, index_per_wafer]= bmmo_get_outlier_density(input_mli, model_results, options)
% function [mean_density, max_density_per_wafer, index_per_wafer] = bmmo_get_outlier_density(input_mli, model_results, options)
%
% Get the mean outlier density per wafer
% The outlier density of a wafer is the maximum ratio of outliers to marks 
% in the marks within a given radius of each outlier in that wafer. See
% D000810611 for the definition.
%
% Input: 
%  input_mli: raw input including invalidated marks from yieldstar
%  stat: computed outlier statistics
%
% Optional input:
%  options: default options structure
%   
% Output: 
%  mean_density: the mean of the maximum outlier densities per wafer
      
if nargin < 3
    options = bmmo_default_options_structure;
end

all_wafer_points = [input_mli.wd.xw input_mli.wd.yw];

max_density_per_wafer = zeros(1, input_mli.nwafer);
index_per_wafer = zeros(1, input_mli.nwafer);

stat = model_results.outlier_stats;
readout_nans = model_results.readout_nans;

% only calculate for single-mark field input, otherwise the density value
% is incorrect
if input_mli.nmark == 1
    for iw = 1:input_mli.nwafer

        outlier_points = [stat.layer.wafer(iw).x stat.layer.wafer(iw).y; readout_nans(iw).x readout_nans(iw).y];

        if size(outlier_points, 1) > 500
            % Too many outliers: skip the density calculation and set
            % density to maximum
            max_density_per_wafer(iw) = 1;
        elseif size(outlier_points, 1) > 0
            % get distance matrices for neighbouring outliers and points
            d_mat_outliers = bmmo_pdist2(outlier_points, outlier_points);
            d_mat_marks = bmmo_pdist2(all_wafer_points, outlier_points);
                   
            % per outlier, get the marks and outliers in the neighbourhood
            outliers_in_neighbourhood = sum(double(d_mat_outliers < options.outlier_check_radius));
            marks_in_neighbourhood = sum(double(d_mat_marks < options.outlier_check_radius));

            [max_density_per_wafer(iw), index_per_wafer(iw)] = max(outliers_in_neighbourhood ./ marks_in_neighbourhood);
            
        end
    end
end

mean_density = mean(max_density_per_wafer);

