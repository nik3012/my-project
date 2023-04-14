function [expinfo, sortindex] = bmmo_expinfo_from_tlg(mli, layer)
% function expinfo = bmmo_expinfo_from_tlg(mli, layer)
%
% Read BMMO-NXE expinfo from the info.S structure from the testlog 
% 
% Input:
%   mli: parsed testlog with info.S.compact_expo_results field
%
% Output:
%   layer: layer to read 

% Make sure the required fields are present
validateattributes(mli.info.S.compact_expo_results, {'cell'}, {'nonempty'}, 1);

% get the right subset of fields, depending on the layer
results = mli.info.S.compact_expo_results{1};

nfield = length(results);

xc = zeros(nfield, 1);
yc = zeros(nfield, 1);
v = zeros(nfield, 1);
map_fieldtoexp = zeros(nfield, 1);

for ires = 1:nfield
    map_fieldtoexp(ires) = results(ires).exposure_seq_nr;

    % Also get exposure_position (xc and yc vectors)
    xc(ires) = results(ires).exposure_position.x;
    yc(ires) = results(ires).exposure_position.y;

    % Get scan speed
    v(ires) = results(ires).scan_speed;

    % Build expinfo from exposure positions
    
end

% sort expinfo by exposure sequence number
[map_fieldtoexp, sortindex] = sort(map_fieldtoexp);
xc = xc(sortindex);
yc = yc(sortindex);
v = v(sortindex);
expinfo.xc = xc;
expinfo.yc = yc;
expinfo.v = v;
expinfo.map_fieldtoexp = map_fieldtoexp + 1;
