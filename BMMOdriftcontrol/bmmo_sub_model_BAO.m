function results_out = bmmo_sub_model_BAO(results_in, options)
% function results_out = bmmo_sub_model_BAO(results_in, options)
%
% The BAO sub-mdel
%
% Input:
%   results_in: structure containing various results from other models
%   options: options structure
%
% Output: 
%   results_out: structure containing output results
%       This function adds the following fields:
%           BAO: 1 * max_chuck array of BAO corrections
%           Calib_KA: 1 * max chuck array of BAO calibrations
%           interfield: 1 * max chuck array of interfield models

results_out = results_in;

for chuck_id = options.chuck_usage.chuck_id_used
    
    % Calculate 10par 
    [results_out.interfield_residual(chuck_id), results_out.BAO.tenpar(chuck_id)] = bmmo_model_BAO(results_out.interfield_residual(chuck_id), options);
  

    % Sum all BAO corrections
    results_out.BAO.correction(chuck_id) = bmmo_add_BAOs(...
       results_out.BAO.tenpar(chuck_id)); 
end


