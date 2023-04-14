function array = extractArrayFromStruct(inStruct, fieldName)
% array = extractArrayFromStruct(inStruct, fieldName)
%
% Function that extracts a specified array from a struct and places it in a new array. 
%
% Input Arguments:
% - inStruct          [ array of structs ] An array of structs containing the
%                                            data which needs to be extracted
% - fieldName         [ string ]           String with the name of the array that needs to
%                                            be extracted from the struct
%
% Output Arguments:
% - array              [ array ]           Array containing the extracted data.  
%

% Manipulate the input to the subsref function
fhandle = @(x) subsref(inStruct(x), stringToSubsref(string(fieldName)));

% Extract the values
try
    % Default where all the elements are valid inputs for an array
    array = arrayfun(fhandle, (1 : length(inStruct)));
catch
    % Alternative where the elements have to be stored in a cell array
    try
        array = arrayfun(fhandle, (1 : length(inStruct)), 'UniformOutput', false);
    catch ME
        rethrow(ME)
    end
end

end


function S = stringToSubsref(str)

% Split the string
str                 = string(str);
delimiters          = [".", "(", ").", ")", "{", "}.", "}"];
[strElem, strDelim] = split(str, delimiters);

% Construct the subsref types
S(1).type = '.';
for index = 1 : length(strDelim)
    switch strDelim(index)
        case {".", ").", "}."}
            S(index + 1).type = '.';
        case "("
            S(index + 1).type = '()';
        case "{"
            S(index + 1).type = '{}';
        otherwise
    end            
end

% Construct the subsref subs
for index = 1 : length(S)
    switch S(index).type
        case '.'
            S(index).subs = char(strElem(index));
        case {'()', '{}'}
            numericValue = sscanf(strElem(index), '%f', 1);
            if numericValue
                S(index).subs = {numericValue};
            else
                S(index).subs = char(strElem(index));
            end
        otherwise
    end
end

end