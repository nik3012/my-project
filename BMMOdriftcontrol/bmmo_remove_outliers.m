function results_out = bmmo_remove_outliers(results_in, options)
% function results_out = bmmo_remove_outliers(results_in, options)
%
% Wrapper for bmmo_outlier_removal; same interface as sub-model functions
%
% Input:
%   results_in: structure containing the following field:
%       ml_outlier_removed: input ml structure for outlier removal
%   options: BMMO/BL3 default options structure
%
% Output: 
%   results_out: structure containing the following fields:
%       ml_outlier_removed: input ml structure after outlier removal
%       outlier_stats: outlier removal statistics, as defined in
%       bmmo_default_outlier_stats

results_out = results_in;

[results_out.ml_outlier_removed, results_out.outlier_stats] = bmmo_outlier_removal(results_in.ml_outlier_removed, options);

if options.WH.use_raw
    results_out.WH.input = bmmo_outlier_removal(options.WH.raw, options);
else    
    results_out.WH.input = results_out.ml_outlier_removed;
end

results_out.interfield_residual = bmmo_average_chuck(results_out.ml_outlier_removed, options);
results_out.INTRAF.residual = bmmo_average_chuck(results_out.ml_outlier_removed, options);

