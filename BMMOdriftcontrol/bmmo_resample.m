function ml_out = bmmo_resample(mli, ml_target, options, collect_tol)
% function ml_out = bmmo_resample(mli, ml_target, options, collect_tol)
%  
%   Interpolates the input data (ml_in) to another layout (ml_target). 
%  
%   For instance, it can be used to downsample 13x19 to say 7x7, dyna25, etc.
%   But also the other way around: to upsample e.g. DYNA25 to 13x19 by means 
%   of interpolation. 
%  
%   NOTE:
%    * half-invalid marks (only dx or dy NaN) are not supported
%  
%   Input:
%     ml_in                      : input overlay data to be interpolated
%     ml_target                  : data set with template layout
%     options                    : options structure with following fields:
%       interp_type              : interpolation type for
%                                       bmmo_interp2_dxdydz
%                                   'nearest', 'linear', 'bilinear', 'cubic', 'gauss'
%       bounding box             : if numeric, a bounding box of the specified size will be added
%                                   to the input data. It is the
%                                   responsibility of the caller to ensure
%                                   that the input data is contained in the
%                                   bounding box
%       nan_interpolation       : interpolation type for removing NaNs from
%                                   input data. 'near4' for iterative
%                                   4-nearest-neighbour algorithm.
%                                   'diagonal' for 8-nearest-neighbour.
%                                   Any other string for no NaN
%                                   interpolation.
%       gauss_radius            : optional radius for Gaussian
%                                   interpolation.
%       wafersize               : diameter of the wafer. Points outside this
%                                   diameter will have their values set to
%                                   NaN.
%   Input optional:
%       collect_tol             : tolerance thereshold to sort wafer
%                                 coordinates
%  
%   Output:
%     ml_out                     : interpolated data

ml_out = ml_target;

if isnumeric(options.bounding_box)
    ml_in_bb = bmmo_add_bounding_box(mli, options.bounding_box);
else
    ml_in_bb = mli;
end

if nargin > 3
    ilayout = sort2d(ml_in_bb.wd.xw, ml_in_bb.wd.yw, collect_tol);
    olayout = sort2d(ml_out.wd.xw , ml_out.wd.yw, collect_tol);
else
    ilayout = sort2d(ml_in_bb.wd.xw, ml_in_bb.wd.yw);
    olayout = sort2d(ml_out.wd.xw , ml_out.wd.yw);
end

for it_layer = 1:ml_in_bb.nlayer
    for it_wafer = 1:ml_in_bb.nwafer
        
        input_wr = ml_in_bb.layer(it_layer).wr(it_wafer);

        input_mesh.dx     = ilayout.meshgrid.x * nan;
        input_mesh.dy     = input_mesh.dx;

        lidx = ilayout.idx > 0;
        input_mesh.dx(lidx) = input_wr.dx(ilayout.idx(lidx));
        input_mesh.dy(lidx) = input_wr.dy(ilayout.idx(lidx));
        
        %  fill NaNs if needed 
        if strcmp(options.nan_interpolation, 'diagonal')
              input_mesh.dx = bmmo_interp_nans(input_mesh.dx, ilayout.sorted.x, ilayout.sorted.y, 'diagonal', 1);
              input_mesh.dy = bmmo_interp_nans(input_mesh.dy, ilayout.sorted.x, ilayout.sorted.y, 'diagonal', 1);
%               input_mesh.dx = interp_nans(input_mesh.dx, ilayout.sorted.x, ilayout.sorted.y);
%               input_mesh.dy = interp_nans(input_mesh.dy, ilayout.sorted.x, ilayout.sorted.y);
              
        elseif strcmp(options.nan_interpolation, 'near4')
              input_mesh.dx = bmmo_interp_nans(input_mesh.dx, ilayout.sorted.x, ilayout.sorted.y, 'updown', 1);
              input_mesh.dy = bmmo_interp_nans(input_mesh.dy, ilayout.sorted.x, ilayout.sorted.y, 'updown', 1);
%              input_mesh.dx = interp_nans(input_mesh.dx, ilayout.sorted.x, ilayout.sorted.y);
%              input_mesh.dy = interp_nans(input_mesh.dy, ilayout.sorted.x, ilayout.sorted.y);
        end

        % interpolate
        [ml_out.layer(it_layer).wr(it_wafer).dx, ml_out.layer(it_layer).wr(it_wafer).dy] = bmmo_interp2_dxdydz(input_mesh, ilayout, olayout, options);

        % filter anything outside intended area
        idx_outer = find((ml_out.wd.xw.^2 + ml_out.wd.yw.^2) > (options.wafersize*0.5)^2);
        ml_out.layer(it_layer).wr(it_wafer).dx(idx_outer) = NaN;
        ml_out.layer(it_layer).wr(it_wafer).dy(idx_outer) = NaN;
    end
end
