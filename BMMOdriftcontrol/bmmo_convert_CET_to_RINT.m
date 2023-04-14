function ml_out = bmmo_convert_CET_to_RINT(ml_in, options)
% function ml_out = bmmo_convert_CET_to_RINT(ml_in, options)
%
% Convert a given CET ml structure to RINT using using nearest-8-neighbour
% interpolation of the NaNs (double bounding box) and finally interpolating 
% to RINT layout using bi-cubic interpolation.
%
% Input:
%   ml_in: CET ml structure
%   options: BMMO/BL3 options structure
%
% Output:
%   ml_out: CET ml structure interpolated per field to RINT positions 

%Initilaze
ml_out       = ovl_get_fields(ml_in, []);

% define bounding box paramters in xf,yf
[bbxf, bbyf] = bmmo_get_bounding_box(ml_in);

% Peform per field interpolation of CET NCE
for ifd = 1:ml_in.nfield
    ml_in_fd = ovl_get_fields(ml_in, ifd);
    
    % bouding box paramters in xw, yw
    bbx = bbxf + ml_in_fd.wd.xc(1);
    bby = bbyf + ml_in_fd.wd.yc(1);
    
    % define RINT target layout
    ml_temp       = ml_in_fd;
    ml_temp.wd.xf = options.RINT_target.xf;
    ml_temp.wd.yf = options.RINT_target.yf;
    ml_temp.wd.xw = ml_temp.wd.xc +ml_temp.wd.xf;
    ml_temp.wd.yw = ml_temp.wd.yc +ml_temp.wd.yf;
    
    % resample CET to RINT
    options.intraf_resample_options.bounding_box = [bbx; bby]';
    collect_tol = 1e-18;% larger tolerance for sort2d
    ml_out_fd   = bmmo_resample(ml_in_fd, ml_temp, options.intraf_resample_options, collect_tol);
    ml_out      = ovl_combine_fields(ml_out, ml_out_fd);
end
