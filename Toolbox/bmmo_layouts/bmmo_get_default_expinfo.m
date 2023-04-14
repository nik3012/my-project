function expinfo = bmmo_get_default_expinfo(mli)
% function expinfo = bmmo_get_default_expinfo(mli)
%
% Return a default expinfo structure baed on the field centre coordinates in mli
% with the same exposure order as the input
%
% Input 
%   mli: any valid ovl ml structure
%
% Output:
%   expinfo: expinfo structure as defined in EDS D000323756
%
% 20160602 SBPR Creation

expinfo.xc = zeros(mli.nfield, 1);
expinfo.yc = expinfo.xc;
expinfo.map_fieldtoexp = (1:mli.nfield)';
expinfo.v = ones(mli.nfield, 1);

xcs = reshape(mli.wd.xc, [], mli.nfield);
ycs = reshape(mli.wd.yc, [], mli.nfield);

expinfo.xc = xcs(1, :)';
expinfo.yc = ycs(1, :)';
expinfo.v(2:2:end) = -1; 


