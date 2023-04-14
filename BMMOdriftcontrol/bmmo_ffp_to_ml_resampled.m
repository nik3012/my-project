function mlo = bmmo_ffp_to_ml_resampled(ffp, ml_tmp, options)
% function mlo = bmmo_ffp_to_ml_resampled(ffp, ml_tmp, options)
%
% Convert ffp (Field fingerprint from SBC2 correction structure) to ml
% structure and also interpolates it from XPA to RINT layout. 
% By default, a single-field 13x19 ml structure, 1 wafer per chuck, is
% created. Optionally, a template ml_tmp structure can be provided. The resampled ffp
% data will be distributed to the wafer layout given in ml_tmp. The chuck corrections
% will be mapped to the wafers assuming starting chuck 1 by default if 
% options structure is not provided.
%
% Input:
%   ffp: 1x2 field fingerprint structure from SBC2 correction
% 
% Optional input:
%   ml_tmp: template ml structure (default: single-layer, 2-wafer 13x19
%       structure)
%  options: BMMO/BL3 default options structure 
%
%  Output:
%   mlo: ffp mapped to ml_tmp structure

if nargin < 2
    % create a dummy ml_tmp
    ml_tmp.nwafer = 2;
    ml_tmp.wd.xc = zeros(size(ffp(1).x));
    ml_tmp.wd.yc = ml_tmp.wd.xc;
    ml_tmp.nfield = 1;
    ml_tmp.nlayer = 1;
    ml_tmp.nmark = length(ml_tmp.wd.xc);
    ml_tmp.tlgname = '';
end
    
if nargin < 3
   options.chuck_usage.chuck_id = ones(1, ml_tmp.nwafer);
   options.chuck_usage.chuck_id(2:2:end) = 2;
   options.chuck_usage.chuck_id_used = 1:2;
end

mlo = ml_tmp;
if isfield(mlo.wd, 'xf')
    ml_intra = bmmo_ffp_to_ml_simple(ffp);
    ml_intra_resampled = bmmo_correct_intrafield_shift(ml_intra, options);
    mlt = ovl_get_wafers(mlo, []);
    for iw = 1:mlo.nwafer
        ml_temp = ovl_distribute_field(ovl_get_wafers(ml_intra_resampled, options.chuck_usage.chuck_id(iw)), ovl_get_wafers(mlo, iw));
        mlt = ovl_combine_wafers(mlt, ml_temp);
    end
end

nl = mlo.nlayer;

for iw = 1:mlo.nwafer
    mlo.layer(nl).wr(iw).dx = mlt.layer.wr(options.chuck_usage.chuck_id(iw)).dx;
    mlo.layer(nl).wr(iw).dy = mlt.layer.wr(options.chuck_usage.chuck_id(iw)).dy;
end
