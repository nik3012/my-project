
function [expinfo, mark_type, adeller_wids, scan_direction] = bmmo_expinfo_from_adeller(adeller)
% function [expinfo, mark_type] = bmmo_expinfo_from_adeller(adeller)
%
% Given an adeller, extract the field centres into an expinfo structure
% and return the number of fields
% 
% Input:
%   adeller: full path of valid ADELler.xml file
%
% Output: 
%   expinfo: structure containing the following fields
%       xc: numfields * 1 vector of field centre x coordinates in m
%       yc: numfields * 1 vector of field centre y coordinates in m
%   mark_type: alignment mark type used
%   adeller_wids: Exposure Wafer_ids from Adeller
%
% 20160331 SBPR Creation
% 20200918 ANBZ Updated for Exposure Wafer_ids output from Adeller

% Allow pre-loaded input
if ischar(adeller)
    ler = xml_load(adeller);
else
    ler = adeller;
end
    
[expinfo, scan_direction] = bmmo_kt_expinfo_from_ler(ler);

mark_type = ler.Input.WaferSettings.WaferGenericSettings.AlignmentSettings.WaferAlignmentStrategySettings(1).elt.MarkList(10).elt.MarkType;

for i =1:length(ler.Results.WaferResultList)
    adeller_wids{i} = ler.Results.WaferResultList(i).elt.WaferId;
end
