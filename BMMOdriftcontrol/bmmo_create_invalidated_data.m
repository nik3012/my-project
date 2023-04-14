function invalid = bmmo_create_invalidated_data(mli, model_results)
% function invalid = bmmo_create_invalidated_data(mli, model_results)
% 
% Given model results containing outlier stats, create the 
% invalidated_data structure as defined in D000810611
%
% Input:
%   mli: overlay structure
%   model_results: intermediate model results structure as defined in
%       bmmo_default_model_result
%   
% Output:
%   invalid: 1*nwafer structure containing the following fields
%       mark: mark invalidated by outlier removal
%           mark.x: x-coordinate of mark relative to wafer centre (m)
%           mark.y: y-coordinate of mark relative to wafer centre (m)

nwafer = length(model_results.outlier_stats.layer.wafer);
invalid.invalidation_reasons = {'Invalidated by Metro', 'Invalidated by W2W', 'Invalidated by Model'};
invalid.invalidated_data = repmat(struct('mark', []), 1, nwafer);

for iw = 1:nwafer

   invalids_this_wafer = length(model_results.readout_nans(iw).x);
   
   % allocate the invalid marks 
   outliers_this_wafer = length(model_results.outlier_stats.layer.wafer(iw).x); 
   invalid.invalidated_data(iw).mark = repmat(struct('reasonid', 1, 'x', 0, 'y', 0), invalids_this_wafer + outliers_this_wafer, 1);
   
   % Fill in readout invalids
   for ii = 1:invalids_this_wafer
       invalid.invalidated_data(iw).mark(ii).reasonid = 1;
       invalid.invalidated_data(iw).mark(ii).x = model_results.readout_nans(iw).x(ii);
       invalid.invalidated_data(iw).mark(ii).y = model_results.readout_nans(iw).y(ii);
   end
    
   % Fill in outlier invalids
   for ii = 1:outliers_this_wafer
       invalid.invalidated_data(iw).mark(invalids_this_wafer + ii).reasonid = model_results.outlier_stats.layer.wafer(iw).type(ii);
       invalid.invalidated_data(iw).mark(invalids_this_wafer + ii).x = model_results.outlier_stats.layer.wafer(iw).x(ii);
       invalid.invalidated_data(iw).mark(invalids_this_wafer + ii).y = model_results.outlier_stats.layer.wafer(iw).y(ii);
   end
end
