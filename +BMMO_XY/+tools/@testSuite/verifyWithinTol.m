function verifyWithinTol(obj, actual, expected, varargin)
% verifyWithinTol(obj, actual, expected, varargin)
%
% This function verifies whether the (structure) array provided as "actual" 
% is equal to the (structure) array provided as "expected".
%
% The optional input arguments are as follows:
%
%   <label>, <value>    [type]                  default value
%
% - 'type'              [char array]            'abs'
% - 'tol'               [double (real)]         '5e-13'


import matlab.unittest.constraints.IsEqualTo
import matlab.unittest.constraints.AbsoluteTolerance
import matlab.unittest.constraints.RelativeTolerance

in = getComparisonSettings(varargin);

if string(in.type) == "rel"
    obj.verifyThat(actual, IsEqualTo(expected, 'Within', RelativeTolerance(in.tol)));
else
    obj.verifyThat(actual, IsEqualTo(expected, 'Within', AbsoluteTolerance(in.tol)));
end

end