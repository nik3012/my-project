function intraf_out = bmmo_intrafield_interpolation_gridded(intraf_in, intraf_target, resample_options)
% function intraf_out = bmmo_intrafield_interpolation_gridded(intraf_in, intraf_target, resample_options)
%
% 'Fast' intrafield interpolation for BL3 CET residual /INTRAF model
%   Same interface as bmmo_resample
%
% Input:
%   intraf_in: ml structure containing original data to be resampled
%   intraf_target: ml structure specifying target layout on which to
%       resample
%   resample_options: structure containing the following fields:
%       nan_interpolation: how to extrapolate / interpolate NaNs (char
%       array)
%       bounding_box: dimensions of square bounding box around data
%       interp_type: interpolation type (cf. Matlab interp2 options)
%       extrap_type: extrapolation type (cf. Matlab griddedInterpolant
%       options)
%       Optional fields
%        xf_grid: ND grid of target layout
%        yf_grid: ND grid of target layout
%        index_out: index mapping disto to ND grid
%
% Output:
%  intraf_out: intraf_in interpolated to marks given in intraf_target

if ~isfield(resample_options, 'xf_grid')
    [resample_options.xf_grid, resample_options.yf_grid, resample_options.index_out] = bmmo_fix_nd_grid(intraf_in.wd.xf, intraf_in.wd.yf);
end

intraf_out = intraf_target;

[nx, ny] = size(resample_options.xf_grid);

dx_interpolant = griddedInterpolant(resample_options.xf_grid, resample_options.yf_grid, ...
    reshape(intraf_in.layer.wr.dx(resample_options.index_out), nx, ny), resample_options.interp_type, resample_options.extrap_type);
dy_interpolant = griddedInterpolant(resample_options.xf_grid, resample_options.yf_grid, ...
    reshape(intraf_in.layer.wr.dy(resample_options.index_out), nx, ny), resample_options.interp_type, resample_options.extrap_type);

for iw = 1:intraf_target.nwafer        
    intraf_out.layer.wr(iw).dx = dx_interpolant(intraf_target.wd.xf, intraf_target.wd.yf);
    intraf_out.layer.wr(iw).dy = dy_interpolant(intraf_target.wd.xf, intraf_target.wd.yf);
end
        
        