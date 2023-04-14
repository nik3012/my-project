function identifier = getErrorId(identCode)
% function identifier = getErrorId(identCode)
%
% This function creates a char array that is formatted in accordance with
% the requirements that Matlab poses on error identifiers.
%
% EXAMPLE:
%
% Suppose that a function called "foo" throws an error like this:
% "error(getErrorId('missingArgument'), 'The first input argument is required');"
%
% The resulting error message would be:
% "The first input argument is required"
%
% And the resulting error identifier would be:
% "BMMO-XY:foo:missingArgument"

REPO_NAME = 'BMMO-XY';

try
    % Get the call stack
    stackStruct = dbstack('-completenames');
    
    % Get the calling function name
    callingFunctionName = stackStruct(2).name;

    % Append the code to the error identifier
    identifier = [REPO_NAME ':' callingFunctionName ':' identCode];
catch ME
    % Rethrow as a warning
    warning(ME.identifier, 'Something went wrong in "BMMO_XY.tools.getErrorId", see: %s', ME.message);

    % Provide a sane default
    identifier = identCode;
end

end
