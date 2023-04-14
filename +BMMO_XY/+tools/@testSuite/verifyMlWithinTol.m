function verifyMlWithinTol(obj, actual, expected, varargin)
% verifyMlWithinTol(obj, actual, expected, varargin)
%
% This function verifies whether the ml provided as "actual" is equal to 
% the ml provided as "expected". 
% When comparing overlapping marks only:
% "expected" is to be the superset of the subset "actual".
%
% The optional input arguments are as follows:
%
%   <label>, <value>    [type]                  default value
%
% - 'type'              [char array]            'abs'
% - 'tol'               [double (real)]         '5e-13'
% - 'perMark'           [char array]            false


import matlab.unittest.constraints.IsTrue

in = getComparisonSettings(varargin);

fieldNames = {'nmark', 'nfield', 'nwafer', 'nlayer', 'wd', 'layer'};

for nameIndex = 1 : length(fieldNames)
    fieldName = fieldNames{nameIndex};
    obj.verifyThat(isfield(actual, fieldName), IsTrue);
    obj.verifyThat(isfield(expected, fieldName), IsTrue);
end

% Restructure "expected" to set marks of subset "actual"
if in.perMark
    expected = subSortMarks(obj, actual, expected);
end

obj.verifyEqual(actual.nmark, expected.nmark);
obj.verifyEqual(actual.nfield, expected.nfield);
obj.verifyEqual(actual.nwafer, expected.nwafer);
obj.verifyEqual(actual.nlayer, expected.nlayer);

obj.verifyWithinTol(actual.wd, expected.wd, 'tol', obj.mlWdTol, 'type', 'abs');
obj.verifyWithinTol(actual.layer, expected.layer, 'tol', in.tol, 'type', in.type);
end


% "expected" is reduced and sorted to its subset "actual"
function expected = subSortMarks(obj, actual, expected)
    
    % Find rounded mark positions
    roundedActualMarkPostitions   = round([actual.wd.xw, actual.wd.yw], 6);
    roundedExpectedMarkPostitions = round([expected.wd.xw, expected.wd.yw], 6);

    % Check if actual is non-empty
    obj.assertTrue(~isempty(roundedActualMarkPostitions), 'Actual ml wafer definition is empty');

    % Create mapping for actual mark positions to match those of expected
    [check, mapping] = ismember(roundedActualMarkPostitions, roundedExpectedMarkPostitions, 'rows');
    
    % Check if actual is in fact a subset of expected
    obj.assertTrue(all(check), 'Actual ml is not a subset of expected ml');

    % Obtain position and overlay fieldnames for simple access
    positionFields = fieldnames(expected.wd);
    overlayFields  = fieldnames(expected.layer.wr);

    % Apply mapping to position
    for posFieldIndex = 1:length(positionFields)
        expectedPos = expected.wd.(positionFields{posFieldIndex});
        expected.wd.(positionFields{posFieldIndex}) = expectedPos(mapping, :);
    end
    
    % Apply mapping to overlay for each wafer
    for ovlFieldIndex = 1:length(overlayFields)
        for waferIndex = 1:expected.nwafer
            expectedOvl = expected.layer.wr(waferIndex).(overlayFields{ovlFieldIndex});
            expected.layer.wr(waferIndex).(overlayFields{ovlFieldIndex}) = expectedOvl(mapping, :);
        end
    end

    expected.nfield = actual.nfield;
    expected.nmark  = actual.nmark;
end