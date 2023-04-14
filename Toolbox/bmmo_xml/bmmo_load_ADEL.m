function xmlData = bmmo_load_ADEL(xmlFile, save)
% Given the file name/path for an ADEL/IDAT (Protected) file, the
% function decrypts the file and loads it to a struct 
%
% Input
%   xmlFile: ADEL/IDAT (Protected) file name/path
%
% Output:
%   xmlData: XML file loaded into Matlab variable using xml_load


import BMMO_XY.tools.xml.decrypt

% Input argument parsing
if nargin == 1
    save = false;
end

% Create full file path
xmlFile = bmmo_create_full_file_path(xmlFile);
[filePath, fileName, fileExt] = fileparts(xmlFile);

% Copy file to temp folder
tempFolderName = char(java.util.UUID.randomUUID);
tempXmlPath    = [tempdir tempFolderName];
tempXmlFile    = [tempXmlPath filesep fileName fileExt];
oldXmlFile     = xmlFile;
xmlFile        = tempXmlFile;

mkdir(tempdir, tempFolderName);
copyfile(oldXmlFile, tempXmlPath);

% Uncompress if required
if string(fileExt) == ".gz"
    gunzip(xmlFile);
    xmlFile                       = [filePath filesep fileName];
    [filePath, fileName, fileExt] = fileparts(xmlFile);
end

% Decrypt if required
xmlFileDecrypted = fullfile(filePath, [fileName '_decrypted' fileExt]);
protected        = 'Protected';
if isfile(xmlFileDecrypted)
    xmlFile = xmlFileDecrypted;
elseif sub_bmmo_determine_encrypted(xmlFile)
    xmlFile = decrypt(xmlFile);
else
    protected = '';
end

% Load to structure
xmlData = xml_load(xmlFile);

% Print diagnostics
fprintf('Loading %s%s\n', xmlData.Header.DocumentType, protected);

% Cleanup
if save
    [oldFilePath, ~, ~] = fileparts(oldXmlFile);
    [status, msg] = copyfile(xmlFile, oldFilePath, 'f');
    if status == 0
        error(msg)
    end
end
rmdir(tempXmlPath, 's');

end


function encrypted = sub_bmmo_determine_encrypted(xmlFile)

% Open the file
filehandle = fopen(xmlFile,'r');
if filehandle == -1
    error('could not open file: %s', xmlFile);
end

% Make sure that we close the filehandle
encrypted = false;
try
    % Check the first 60 lines of the file
    for line_number = 1:60
        % Check the results
        if encrypted
            break
        end
        % Make sure that we don't reach the end of the file
        if ~feof(filehandle)
            % Store the line as a string
            line = string(fgetl(filehandle));
            % Check if the EncryptedData node is found
            if contains(line, "<EncryptedData>", 'IgnoreCase', true)
                encrypted = true;
            end
        end
    end
catch ME
    fclose(filehandle);
    rethrow(ME)
end

% Close the file
fclose(filehandle);

end