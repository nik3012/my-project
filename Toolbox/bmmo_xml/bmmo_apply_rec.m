function mlo = bmmo_apply_rec(mli, recfile, factor)
% function mlo = bmmo_apply_rec(mli, recfile, factor)
%
% Apply rec from ADEL xml file on the input overlay structure
%
% Input
%   mli: overlay structure
%   recfile: full path of ADELreticleErrorCorrection xml file
%
% Optional input
%   factor: scaling factor (default: 1)
%
% Output:
%   out: mlo: input overlay structure with REC applied
%
% 20170425 SBPR Added scaling factor and documentation
% 20170509 SBPR Added multi-layer support

if nargin < 3
    factor = 1;
end

% load the rec file
recdata = xml_load(recfile);
[xy, dxy] = bmmo_get_nominal_from_wec_rec(recdata);

% convert it to ml_field
ml_field.wd.xf = xy(:,1);
ml_field.wd.yf = xy(:,2);
ml_field.wd.xw = ml_field.wd.xf;
ml_field.wd.yw = ml_field.wd.yf;
ml_field.wd.xc = zeros(size(ml_field.wd.xf));
ml_field.wd.yc = ml_field.wd.xc;

ml_field.tlgname = 'rec';

ml_field.nwafer = 1;
ml_field.nfield = 1;
ml_field.nlayer = mli.nlayer;
ml_field.nmark = length(ml_field.wd.xf);

for il = 1:ml_field.nlayer 
    ml_field.layer(il).wr.dx = dxy(:,1) * 0;
    ml_field.layer(il).wr.dy = dxy(:,2) * 0;
end

% only apply rec to the 'top' layer
ml_field.layer(ml_field.nlayer).wr.dx = dxy(:,1) * factor;
ml_field.layer(ml_field.nlayer).wr.dy = dxy(:,2) * factor;

mlo = ovl_sub_field(mli, ml_field);