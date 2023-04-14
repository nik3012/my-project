function [xy, dxy] = bmmo_get_nominal_from_wec_rec(wec)
% function [xy, dxy] = bmmo_get_nominal_from_wec_rec(wec)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%

wectargets = wec.ErrorCorrectionData.TargetList;

nmark = length(wectargets);
xy = nan * zeros(nmark, 2);
dxy = nan * zeros(nmark, 2); 
for ii = 1:nmark
    xy(ii, 1) = sscanf(wectargets(ii).elt.NominalPosition.X, '%f');
    xy(ii, 2) = sscanf(wectargets(ii).elt.NominalPosition.Y, '%f');
    if strcmp(wectargets(ii).elt.ErrorValidity.X, 'true')
        dxy(ii,1) = sscanf(wectargets(ii).elt.PositionError.X, '%f');
    end
    if strcmp(wectargets(ii).elt.ErrorValidity.Y, 'true')
        dxy(ii,2) = sscanf(wectargets(ii).elt.PositionError.Y, '%f');
    end
end

xy = xy * 1e-3;
dxy = dxy * 1e-9;

