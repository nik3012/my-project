
function mlp_d25 = bmmo_get_dyna25_layout(mlp, options)
% function mlp_d25 = bmmo_get_dyna25_layout(mlp, options)
%
% Downsample the sparse fields in the BMMO-NXE layout from 7x7 to dyna 25
%
% Input:
%   mlp: field-reconstructed BMMO-NXE layout as output by
%       bmmo_process_input
%   options: bmmo-nxe options structure
%
% Output:
%   mlp_d25: mlp with 7x7 fields downsampled to dyna25
%
% 20170720 SBPR Creation

mlp_d25 = mlp;

% downsample the relevant fields from mlp
dense_fields = [options.fid_intrafield, options.fid_left_right_edgefield, options.fid_top_bottom_edgefield];
sparse_fields = setdiff(1:mlp.nfield, dense_fields);

% get the IDs of all marks that correspond to the sparse data fields 
sparse_data = ovl_get_fields(mlp, sparse_fields);
spids = knnsearch([mlp.wd.xw mlp.wd.yw], [sparse_data.wd.xw sparse_data.wd.yw] );

sp_logindex = false(size(mlp.wd.xw));
sp_logindex(spids) = true;

% get the IDs of all marks that do NOT correspond to dyna25 fields
dyna_25_field = ovl_get_fields(ovl_get_layout(ovl_create_dummy('nwafer', 1, 'nlayer', 1)), 1);
bmmo_field = ovl_get_fields(ovl_get_wafers(mlp,1),1);

fids = knnsearch([bmmo_field.wd.xf bmmo_field.wd.yf], [dyna_25_field.wd.xf dyna_25_field.wd.yf] );

f_logindex = true(size(bmmo_field.wd.xf));
f_logindex(fids) = false;
f_logindex = repmat(f_logindex, 1, mlp.nfield);

f_logindex = reshape(f_logindex, [], 1);

% AND them and map the result on overlay data
d25_index = f_logindex & sp_logindex;

for iw = 1:mlp.nwafer
   mlp_d25.layer.wr(iw).dx(d25_index) = NaN;
   mlp_d25.layer.wr(iw).dy(d25_index) = NaN;
end



