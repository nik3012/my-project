function filter_out = bmmo_get_dynamic_filter_coefficients(filter_in, delta_t, wafers_per_chuck, T1, T2, platform)
% function filter_out = bmmo_get_dynamic_filter_coefficients(filter_in, delta_t, wafers_per_chuck, T1, T2, platform)
%
% Calculate dynamic time filter coefficients based on wafers per chuck and
% time since last bmmo lot
%
% Input :
%   filter_in: structure containing filter coefficient values for WH, SUSD, MI,
%              KA, BAO, INTRAF (each field is a 1x1 double value)
%   delta_t:   time interval since previous BMMO-NXE lot (vector of double
%              values)
%   wafers_per_chuck: maximum number of wafers per chuck
%   T1:        time threshold to begin dynamic filter 
%   T2:        time threshold to set filter to 1
%   platform:  'LIS' or 'OTAS'
%
% Output: 
% filter_out: structure containing adaptive time filter coefficient values
%             for WH, SUSD, MI, KA, BAO, INTRAF (each field is a 1x1 double value)
%
%  See D000323756 for a description of the algorithm in OTAS
%  See D000810611 for LIS

filter_max = 1;

tt = T2 - T1;

if strcmp(platform,'LIS')
    wafer_scaling_factor = sqrt(2 / wafers_per_chuck);
else
    wafer_scaling_factor = sqrt(3 / wafers_per_chuck);
end

fn = fieldnames(filter_in);

for ii = 1:length(fn)
    base = filter_in.(fn{ii}) / wafer_scaling_factor;
    filter_out.(fn{ii})(1:numel(delta_t)) = base;   
    mid_indices = delta_t > T1 & delta_t < T2;  
    filter_out.(fn{ii})(mid_indices) = ((filter_max - base) * (delta_t(mid_indices) - T2))/tt + filter_max;   
    filter_out.(fn{ii})(delta_t >= T2) = filter_max;
    filter_out.(fn{ii})(filter_out.(fn{ii}) > filter_max) = filter_max;
end


