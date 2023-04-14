function [mlo, field_ids, xc, yc] = bmmo_get_dense_fields(mli)
% function [mlo, field_ids, xc, yc] = bmmo_get_dense_fields(mli)
%
% Get fields which have more non-NaN marks than a certain threshold value.
%   e.g. can be used to determine the 13x19 fields in bmmo layout without
%   knowing the field ids.
%
threshold = 150; % more than 7x19

data = nanmean([mli.layer(1).wr.dx], 2);

data = reshape(data, mli.nmark, []);

validperfield = sum(double(~isnan(data)));

field_ids = find(validperfield >= threshold);

mlo = ovl_get_fields(mli, field_ids);

xyc = unique([mlo.wd.xc mlo.wd.yc], 'rows');

xc = xyc(:,1);
yc = xyc(:,2);


