function SUT = createSUT(obj, functionString)
% function SUT = createSUT(functionString, tempDir)
%
% This function creates a struct containing function handles to all the
% function definitions contained in the file associated with
% "functionString".


import BMMO_XY.tools.*

%% Define the file names
fullFileName = which(functionString);

[~, fileName, fileExt] = fileparts(fullFileName);

SUTfileName = [obj.testTempDir filesep fileName '_SUT' fileExt];

%% Read the function file
filehandle = fopen(fullFileName, 'r');
if filehandle == -1
    error(getErrorId('openFile'), 'could not open file: %s', fullFileName);
end
lines = {};
try
    while ~feof(filehandle)
        lines = [lines; {fgetl(filehandle)}];               
    end
catch ME
    fclose(filehandle);
    rethrow(ME)
end
fclose(filehandle);

%% Append the top function that will return the function handles
lines = [{['function functionHandles = ' fileName '_SUT()']}; ...
         { 'functionHandles = localfunctions();'}; ...
         { 'end'}; ...
         { ''}; ...
         lines];

%% Write the SUT .m file
filehandle = fopen(SUTfileName, 'w');
if filehandle == -1
    error(getErrorId('openSUTfile'), 'could not open file: %s', SUTfileName);
end
try
    for index = 1 : length(lines)
        fprintf(filehandle, '%s\n', lines{index});
    end
catch ME
    fclose(filehandle);
    rethrow(ME)
end
fclose(filehandle);

%% Create the SUT struct
functionHandles = feval([fileName '_SUT']);
for index = 1 : length(functionHandles)
    SUT.(func2str(functionHandles{index})) = functionHandles{index};
end

end
