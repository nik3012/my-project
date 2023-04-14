function fullFileName = bmmo_create_full_file_path(file)
% Generate the full file path from a file name

% Convert file to char array and split into parts
[filePath, fileName, fileExt] = fileparts(char(file));

% Generate filepath if required
if string(filePath) == ""
    [filePath, ~, ~] = fileparts(which(file));
end

% Recombine to get the full file path
fullFileName = fullfile(filePath, [fileName fileExt]);

end

