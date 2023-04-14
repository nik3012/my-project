function ml = appendInfoToMl(ml, ADELler)
% function ml_out = appendInfoToMl(ml, ADELler)
%
% This function takes an ml-struct (as obtained by ovl_read_adelmetrology) and the path of an ADELler from the same lot. 
% It appends the exposure information to the overlay measurements and outputs the appended ml structure.
%
% Inputs:
%   - ml:           ml struct obtained by parsing an ADELmetrology using
%                   ovl_read_adelmetrology
%   - ADELler:      full path of the ADELler, or xml_loaded ADELler 
%
% Output:
%   - ml_out:       ml structure with exposure information from parsed ADELler,
%                   fields sorted in expose order
%
% Note: this function should only be used for the (de)correction tooling for
% OPO data and does not support other usecases (05-12-2022).
%


% Load ADELler if it is not already loaded
if ischar(ADELler)
    ADELler = bmmo_load_ADEL(ADELler);
end

% Append relevant ADELler data to ml
ml = bmmo_kt_process_adeller_input(ml, ADELler);

% Reorder the fields to exposure order
ml = bmmo_sort_ml(ml, bmmo_construct_layout(ml.expinfo.xc, ml.expinfo.yc, ml, ml.nlayer, ml.nwafer));

% Extract the wafer IDs
widsReadoutOrder        = ml.info.meas.wafer.waferid;
[~, ~, widsExposeOrder] = bmmo_expinfo_from_adeller(ADELler);

% Exact WID matching
[mappingSuccessful, mapping] = mapWaferIds(widsExposeOrder, widsReadoutOrder);

% Approximate WID matching
if ~mappingSuccessful    
    
    % Before WID matching, select only the characters after the dot from all WIDs
    [mappingSuccessful, mapping] = mapWaferIds(arrayfun(@(x) extractAfter(x, '.'), widsExposeOrder) , ...
                                                  arrayfun(@(x) extractAfter(x, '.'), widsReadoutOrder));
    if ~mappingSuccessful
        throwMatchingError(widsReadoutOrder, widsExposeOrder);
    end
end

% Reorder the info field according to the wafer mapping
ml.info = infoToReadoutOrder(ml.info, mapping);

end


function [mappingSuccessful, mapping] = mapWaferIds(exposeWaferIds, readoutWaferIds)

% Mapping details
mappingSuccessful = false;
mapping            = [];

% Sanity check on wafer IDs
numberOfReadoutWafers = numel(readoutWaferIds);
numberOfExposeWafers  = numel(exposeWaferIds);
if length(unique(readoutWaferIds)) ~= numberOfReadoutWafers || ...
   length(unique(exposeWaferIds))  ~= numberOfExposeWafers  || ...
   numberOfReadoutWafers          >  numberOfExposeWafers  
    return
end

% Reshape to make sure both cell arrays have same shape
exposeWaferIds  = reshape(exposeWaferIds, [numberOfExposeWafers 1]);
readoutWaferIds = reshape(readoutWaferIds, [numberOfReadoutWafers 1]);

% Try to match
[~, indexExpose, indexExposeAndReadout] = unique([exposeWaferIds; readoutWaferIds], 'stable');
if isequal(indexExpose, (1 : numberOfExposeWafers)')
    mappingSuccessful = true;
    mapping            = indexExposeAndReadout(numberOfExposeWafers + 1 : end);
end
end


function throwMatchingError(widsReadoutOrder, widsExposeOrder)

% Construct a string that lists the readout WIDs and subsequently the expose WIDs
str = sprintf('Readout WIDs\n');
for index = 1 : length(widsReadoutOrder)
    str = sprintf('%s%s\n', str, widsReadoutOrder{index});
end
str = sprintf('%s\nExposure WIDs\n', str);
for index = 1 : length(widsExposeOrder)
    str = sprintf('%s%s\n', str, widsExposeOrder{index});
end

error('No mapping could be made between readout wafer IDs and exposure wafer IDs found in ADELler.\n%s', str)
end


function info = infoToReadoutOrder(info, waferMapping)

info.report_data.FIWA_translation.x = info.report_data.FIWA_translation.x(waferMapping);
info.report_data.FIWA_translation.y = info.report_data.FIWA_translation.y(waferMapping);
info.F.chuck_id                     = info.F.chuck_id(waferMapping);
info.F.wafer_accepted               = info.F.wafer_accepted(waferMapping);

if length(unique(info.F.chuck_id)) == 1
    info.F.chuck_operation = 'ONE_CHUCK';
end
end