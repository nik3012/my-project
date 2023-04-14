function FP_SUSD = bmmo_construct_FPS_SUSD(ml, options)
% function FP_SUSD = bmmo_construct_FPS_SUSD(ml, options)
%
% Generate the raw SUSD fingerprint for the combined model
%
% Input: 
%  ml: input ml structure
%  options: structure containing the fields 
%           Scan_direction: vector, per field scan direction (1 or -1)
%           scaling_factor: double, scaling for scan direction
%
% Output: 
%  FP_SUSD: SUSD fingerprint (1x1 cell array of ml structs)

dummy = ml; 
ifield = 1:ml.nfield;
scan_dirs = unique(options.Scan_direction);
FP_SUSD = ovl_get_fields(dummy,[]);

% get the ids of options.Scan_direction which are also in the input layout
field_ids = bmmo_get_field_ids(ml, ml.expinfo);

% Apply ty per field for each scan direction
for idir = 1:length(scan_dirs)
    
    % Get the field IDS for this scan direction
    idx = options.Scan_direction == scan_dirs(idir);
    idx = idx(field_ids); % there can be more exposed fields than ml.nfield 
    ml_field = ovl_get_fields(dummy, ifield(idx));
    
    % Apply ty per field to all fields in this scan direction
    par.ty = scan_dirs(idir)/options.scaling_factor;
    tmp = ovl_model(ml_field, 'perwafer', 'perfield', 'apply', par);
    
    % combine applied fields with previous (fields temporarily in wrong
    % order)
    FP_SUSD = ovl_combine_fields(FP_SUSD, tmp);
end
FP_SUSD = ovl_combine_linear(dummy,0,FP_SUSD,1); % sort the fields into the correct order

FP_SUSD.what = 'SUSD';   

FP_SUSD = {FP_SUSD}; % Put it in a cell, for consistency