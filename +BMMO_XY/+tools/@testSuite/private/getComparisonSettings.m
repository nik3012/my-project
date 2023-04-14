function inputArguments = getComparisonSettings(inargs)
% function inputArguments = getComparisonSettings(inargs)
%
% This function provides input argument parsing for "verifyMlEqual" and
% "verifyStructEqual".
%
% Optional inputs:
% type:     Comparison type        
%                   'abs'   : absolute comparison
%                   'rel'   : relative comparison
%
% tol:      Defined tolerance
%
% perMark:     Marks to compare
%                   'false' : compare marks as given
%                   'true'  : compare marks only at matching positions


p = inputParser;

validationFunctionText   = @(x) (ischar(x));
validationFunctionDouble = @(x) (isa(x, 'double') && isreal(x));

defaultType    = 'abs';
defaultTol     = 5e-13;
defaultPerMark = false;


p.addParameter('type', defaultType, validationFunctionText);
p.addParameter('tol', defaultTol, validationFunctionDouble);
p.addParameter('perMark', defaultPerMark);

p.parse(inargs{:});

inputArguments = p.Results;

end