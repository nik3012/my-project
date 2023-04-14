function [expinfo, scan_direction] = bmmo_kt_expinfo_subset(ml, expinfo, scan_direction)
% function [expinfo, scan_direction] = bmmo_kt_expinfo_subset(ml, expinfo, scan_direction)

% This function takes as input an ml, exposure field centers in expinfo,
% and scan directions per field. It will match the exposure information to
% the field centers found in the ml. The outputs are the expinfo and
% scan_direction that match with ml.
% Input
%   ml: ml structure to which exposure info will be matched
%   expinfo: structure containing exposure field centers
%   scan_direction: vector of scan directions per exposure field
%
% Output:
%   expinfo: structure with the exposure field centers that match the input ml
%   scan_direction: vector of scan directions per field matching the input ml

mlFieldCenters = unique([ml.wd.xc, ml.wd.yc], 'rows');
expinfoFieldCenters = [expinfo.xc, expinfo.yc];

numberOfFieldsInMl = length(mlFieldCenters);
numberOfFieldsInExpinfo = length(expinfo.xc);
numberOfScanDirections = length(scan_direction);

% Check the number of fields in the inputs; throw errors if needed
assert(numberOfFieldsInExpinfo == numberOfScanDirections,       ...
       ['Invalid input: Number of exposure field centers (%d)', ...
        ' does not match number of scan directions (%d)'],      ...
        numberOfFieldsInExpinfo, numberOfScanDirections);
        
assert(numberOfFieldsInExpinfo >= numberOfFieldsInMl, ...
      ['Number of exposure field centers (%d) is smaller than the number'       , ...
       ' of field centers in the input overlay (%d). A mapping cannot be made.'], ...
       numberOfFieldsInExpinfo, numberOfFieldsInMl);

% Find field centers that are both in expinfoFieldCenters and
% mlFieldCenters; then check if this covers all fields in ml.
overlappingExpinfoFieldCenters = ismembertol(expinfoFieldCenters, mlFieldCenters, 1e-9, 'byRows', true, 'DataScale', 1);

assert(sum(overlappingExpinfoFieldCenters) == numberOfFieldsInMl, ...
      ('Exposure information was not found for all fields in the input ml, a mapping could not be made.'));
  
% Select the right subset of exposure field centers to output
expinfo.xc = expinfo.xc(overlappingExpinfoFieldCenters);
expinfo.yc = expinfo.yc(overlappingExpinfoFieldCenters);
expinfo.v = zeros(size(expinfo.xc));
scan_direction = scan_direction(overlappingExpinfoFieldCenters);
% Since fields are now in exposure order, mapping field to expose is 1:nfield
expinfo.map_fieldtoexp = (1:ml.nfield)';
end

