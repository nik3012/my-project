function scaled_fps = bmmo_scale_fps(fps_in, scaling_factor, options)
% function scaled_fps = bmmo_scale_fps(fps_in, scaling_factor, options)
%
% Scale a structure with a certain number of fields, each of which is a
% vector of ml structures
%
% Input: 
%  fps in: structure containing fields, each of which is a vector of
%               ml structures
%  scaling_factor: factor by which to scale ml structures
%  options: BMMO/BL3 default options structure
%
% Output: 
%  scaled_fps: scaled fingerprints

fps_fieldnames = fieldnames(fps_in);
scaled_fps = fps_in;

for iname = 1:length(fps_fieldnames)
   f_name = fps_fieldnames{iname};
   for chuck_id = options.chuck_usage.chuck_id_used
       scaled_fps.(f_name)(chuck_id) = ovl_combine_linear(scaled_fps.(f_name)(chuck_id), scaling_factor);
   end
end

