function mlo = bmmo_ffp_to_ml_simple(ffp, ml_tmp, options)
% function mlo = bmmo_fpp_to_ml_simple(ffp, ml_tmp, options)
%
% Convert ffp (Field fingerprint from SBC2 correction structure) to ml
% structure. By default, a single-field 13x19 ml structure, 1 wafer per chuck, is
% created. Optionally, a template ml_tmp structure can be provided. The the ffp
% data will be mapped to the field layout of ml_tmp, and the chuck corrections
% will be mapped to the wafers assuming starting chuck 1.
%
% NPA the intrafield mark positions will be shifted to XPA field centre.
%
% Input:
%   ffp: 1x2 field fingerprint structure from SBC2 correction
% 
% Optional input:
%   ml_tmp: template ml structure (default: single-layer, 2-wafer 13x19
%       structure)
%   options: bmmo-nxe options structure, used to determine chuck order if
%       present
%
%  Output:
%   mlo: ffp mapped to ml structure

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
   options.model_shift.x = [0 0; 0 0];
   options.model_shift.y = [0 0; 0 0];
end

mlo = ml_tmp;

% ffp might be shifted relative to XPA centre.
% however, since the field positions are symmetrical about (0,0), we
% can determine the (x,y) shifts from the mean
rd = 7; % calculate up to RINT shift values
x_shift = round(mean(ffp(1).x), rd);
y_shift = round(mean(ffp(1).y), rd);

mlo.wd.xf = repmat(ffp(1).x - x_shift, mlo.nfield, 1);
mlo.wd.yf = repmat(ffp(1).y - y_shift, mlo.nfield, 1);
mlo.wd.xw = mlo.wd.xf + mlo.wd.xc;
mlo.wd.yw = mlo.wd.yf + mlo.wd.yc;

nl = mlo.nlayer;

for iw = 1:mlo.nwafer
    mlo.layer(nl).wr(iw).dx = repmat(ffp(options.chuck_usage.chuck_id(iw)).dx, mlo.nfield, 1);
    mlo.layer(nl).wr(iw).dy = repmat(ffp(options.chuck_usage.chuck_id(iw)).dy, mlo.nfield, 1);
end

mlo = bmmo_shift_fields(mlo, options.model_shift.x, options.model_shift.y);
