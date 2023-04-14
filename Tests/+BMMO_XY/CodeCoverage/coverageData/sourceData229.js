var sourceData229 = {"FileContents":["function ml = appendInfoToMl(ml, ADELler)\r","% function ml_out = appendInfoToMl(ml, ADELler)\r","%\r","% This function takes an ml-struct (as obtained by ovl_read_adelmetrology) and the path of an ADELler from the same lot. \r","% It appends the exposure information to the overlay measurements and outputs the appended ml structure.\r","%\r","% Inputs:\r","%   - ml:           ml struct obtained by parsing an ADELmetrology using\r","%                   ovl_read_adelmetrology\r","%   - ADELler:      full path of the ADELler, or xml_loaded ADELler \r","%\r","% Output:\r","%   - ml_out:       ml structure with exposure information from parsed ADELler,\r","%                   fields sorted in expose order\r","%\r","% Note: this function should only be used for the (de)correction tooling for\r","% OPO data and does not support other usecases (05-12-2022).\r","%\r","\r","\r","% Load ADELler if it is not already loaded\r","if ischar(ADELler)\r","    ADELler = bmmo_load_ADEL(ADELler);\r","end\r","\r","% Append relevant ADELler data to ml\r","ml = bmmo_kt_process_adeller_input(ml, ADELler);\r","\r","% Reorder the fields to exposure order\r","ml = bmmo_sort_ml(ml, bmmo_construct_layout(ml.expinfo.xc, ml.expinfo.yc, ml, ml.nlayer, ml.nwafer));\r","\r","% Extract the wafer IDs\r","widsReadoutOrder        = ml.info.meas.wafer.waferid;\r","[~, ~, widsExposeOrder] = bmmo_expinfo_from_adeller(ADELler);\r","\r","% Exact WID matching\r","[mappingSuccessful, mapping] = mapWaferIds(widsExposeOrder, widsReadoutOrder);\r","\r","% Approximate WID matching\r","if ~mappingSuccessful    \r","    \r","    % Before WID matching, select only the characters after the dot from all WIDs\r","    [mappingSuccessful, mapping] = mapWaferIds(arrayfun(@(x) extractAfter(x, '.'), widsExposeOrder) , ...\r","                                                  arrayfun(@(x) extractAfter(x, '.'), widsReadoutOrder));\r","    if ~mappingSuccessful\r","        throwMatchingError(widsReadoutOrder, widsExposeOrder);\r","    end\r","end\r","\r","% Reorder the info field according to the wafer mapping\r","ml.info = infoToReadoutOrder(ml.info, mapping);\r","\r","end\r","\r","\r","function [mappingSuccessful, mapping] = mapWaferIds(exposeWaferIds, readoutWaferIds)\r","\r","% Mapping details\r","mappingSuccessful = false;\r","mapping            = [];\r","\r","% Sanity check on wafer IDs\r","numberOfReadoutWafers = numel(readoutWaferIds);\r","numberOfExposeWafers  = numel(exposeWaferIds);\r","if length(unique(readoutWaferIds)) ~= numberOfReadoutWafers || ...\r","   length(unique(exposeWaferIds))  ~= numberOfExposeWafers  || ...\r","   numberOfReadoutWafers          >  numberOfExposeWafers  \r","    return\r","end\r","\r","% Reshape to make sure both cell arrays have same shape\r","exposeWaferIds  = reshape(exposeWaferIds, [numberOfExposeWafers 1]);\r","readoutWaferIds = reshape(readoutWaferIds, [numberOfReadoutWafers 1]);\r","\r","% Try to match\r","[~, indexExpose, indexExposeAndReadout] = unique([exposeWaferIds; readoutWaferIds], 'stable');\r","if isequal(indexExpose, (1 : numberOfExposeWafers)')\r","    mappingSuccessful = true;\r","    mapping            = indexExposeAndReadout(numberOfExposeWafers + 1 : end);\r","end\r","end\r","\r","\r","function throwMatchingError(widsReadoutOrder, widsExposeOrder)\r","\r","% Construct a string that lists the readout WIDs and subsequently the expose WIDs\r","str = sprintf('Readout WIDs\\n');\r","for index = 1 : length(widsReadoutOrder)\r","    str = sprintf('%s%s\\n', str, widsReadoutOrder{index});\r","end\r","str = sprintf('%s\\nExposure WIDs\\n', str);\r","for index = 1 : length(widsExposeOrder)\r","    str = sprintf('%s%s\\n', str, widsExposeOrder{index});\r","end\r","\r","error('No mapping could be made between readout wafer IDs and exposure wafer IDs found in ADELler.\\n%s', str)\r","end\r","\r","\r","function info = infoToReadoutOrder(info, waferMapping)\r","\r","info.report_data.FIWA_translation.x = info.report_data.FIWA_translation.x(waferMapping);\r","info.report_data.FIWA_translation.y = info.report_data.FIWA_translation.y(waferMapping);\r","info.F.chuck_id                     = info.F.chuck_id(waferMapping);\r","info.F.wafer_accepted               = info.F.wafer_accepted(waferMapping);\r","\r","if length(unique(info.F.chuck_id)) == 1\r","    info.F.chuck_operation = 'ONE_CHUCK';\r","end\r","end"],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[22,23,27,30,33,34,37,40,43,44,45,46,51,59,60,63,64,65,66,67,68,72,73,76,77,78,79,87,88,89,91,92,93,96,102,103,104,105,107,108],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}