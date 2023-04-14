function mlo = bmmo_model_mmo(mli, options)
% function mlo = bmmo_model_mmo(mli, options)
%
% Apply ATP-MMO model on field-reconstructed input data
%  1. Remove 3mm edge
%  2. Remove w2w outliers per chuck
%  3. Remove 10 par per chuck
%
% Input
%   mli: overlay structure
%
% Optional Input:
%   options: structure containing the following fields
%       chuck_usage.chuck_id_used: 1 * number of chucks double array
%           containing chuck ids
%       chuck_usage.chuck_id: 1 * mli.nwafer double array containing for
%           each wafer the chuck id of that wafer
%       
% If no options input is provided, values will be filled in from
% bmmo_default_options_structure
%
% Output
%   mlo: residual of ATP-MMO model on input structure

if nargin < 2
    options = bmmo_default_options_structure;
end

%  1. Remove 3mm edge
mlo = ovl_remove_edge(mli, 0.147);

% 2. Remove w2w outliers
%mlo = bmmo_remove_w2w_outliers(mlo, options);
mlo = ovl_w2w_outliers(mlo, 'oddeven');

mlt = ovl_get_wafers(mlo, []);

% 3. Remove 10 par per chuck

for ic = options.chuck_usage.chuck_id_used
   wafers_this_chuck = find(options.chuck_usage.chuck_id == ic);
   ml_this_chuck = ovl_get_wafers(mlo, wafers_this_chuck);
       
   ml_this_chuck = bmmo_model_BAO(ml_this_chuck, options);
   mlt = ovl_combine_wafers(mlt, ml_this_chuck);
end

% The wafer ids in mlt are sorted
% Now unsort them to the original order

[unused, id1] = sort(options.chuck_usage.chuck_id);
[unused, ids] = sort(id1);

mlo = ovl_get_wafers(mlt, ids);

