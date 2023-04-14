function mlo = bmmo_map_to_smf(mlp, mli, shift)
% function mlo = bmmo_map_to_smf(mlp, mli, shift)
%
% Converts the input mlp structure to SMF and also maps to the given SMF 
% structure mli using shift as threshold for mapping
%
% Input: 
%  mlp: overlay structure 
%  mli: overlay structure in smf format
%  shift: threshold for mapping
%
% Output:
%  mlo: overlay structure mlp with same layout as mli

if nargin < 3
    shift = 0.0003;
end

mlc = bmmo_convert_to_smf(mlp);
mlo = mli;

[idx2, D] = knnsearch([mlc.wd.xw mlc.wd.yw], [mli.wd.xw mli.wd.yw]);
valid = D < shift;

for iw = 1:mli.nwafer
    mlo.layer.wr(iw).dx = mli.layer.wr(iw).dx * NaN;
    mlo.layer.wr(iw).dy = mli.layer.wr(iw).dy * NaN;
    mlo.layer.wr(iw).dx(valid) = mlc.layer.wr(iw).dx(idx2(valid));
    mlo.layer.wr(iw).dy(valid) = mlc.layer.wr(iw).dy(idx2(valid));
end