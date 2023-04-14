function xmlFileDecrypted = decrypt(xmlFile)
% function xmlFileDecrypted = decrypt(xmlFile)
%
% Function that takes a protected ADEL or IDAT and decrypts it using
% ADELDecryptor, ADD or the XMLschema ADELdecryptor and outputs the
% full path of the decrypted file
%
% Input:
% xmlFile               [ char array ]        full path of the protected ADEL- or IDAT-file
%
% Output:
% xmlFileDecrypted      [ char array ]        full path of the decrypted ADEL- or IDAT-file
%


% Get the paths the ADEL/IDAT file to decrypt and create the names of the
% decrypted files
[~, xmlFileDecrypted, ~] = sub_getDecrypedFilePath(xmlFile, tempdir);

% Check whether the decrypted file already exists in the folder, then no
% decryption is required.
if isfile(xmlFileDecrypted)
    return
end

% Load the configuration
config = bmmoDecrypterConfig('decrypterConfiguration.json');

% Create the input for the decryption and the output file-location for when there
% is no write-access in the folder and do the decryption
switch config.decryptionMethod
    case 'ADELDecryptor'
        xmlFileDecrypted = sub_winDecryption(config.decrypterExecutable, xmlFile, '"%s" -i:"%s" -o:"%s"', tempdir);
    case 'ADD'
        xmlFileDecrypted = sub_winDecryption(config.decrypterExecutable, xmlFile, '"%s" -i "%s" -o "%s"', getenv('TMP'));
    otherwise
        xmlFileDecrypted = sub_linuxDecryption(config.token, config.comment, xmlFile, tempdir);
end

end


function xmlFileDecrypted = sub_winDecryption(decrypterExecutable, xmlFile, decryptionInput, tempdirPath)

import BMMO_XY.tools.*

% Get the filepath and construct the paths for the decrypted file
[filePath, xmlFileDecrypted, xmlFileDecryptedTemp] = sub_getDecrypedFilePath(xmlFile, tempdirPath);

% Decrypt and place the file in the same location as the protected file
[~, ~] = system(sprintf(decryptionInput, decrypterExecutable, xmlFile, filePath));

% If there is no write-access, status code 20 will be thrown for
% ADELdecryptor. Currently (15-12-2022), ADD is bugged and will always
% throw status code 0, therefore we check whether the decrypted file
% exists, instead of checking the status.

if ~isfile(xmlFileDecrypted)
    
    % Check if the file exists in the temporary directory, delete it if it does
    if isfile(xmlFileDecryptedTemp)
        delete(xmlFileDecryptedTemp);
    end
    
    % Decrypt and place the file in the temp directory
    [status, ~] = system(sprintf(decryptionInput, decrypterExecutable, xmlFile, tempdirPath));
    
    if isfile(xmlFileDecryptedTemp)
        xmlFileDecrypted = xmlFileDecryptedTemp;

        warning('No write access to folder of inputfile, placed decrypted file in folder: %s', tempdirPath);
    else
        error(getErrorId('noFile'), 'Decryption was unsuccessful, status code: %s (%s)', string(status), decrypterExecutable);
    end
end

end


function xmlFileDecrypted = sub_linuxDecryption(token, comment, xmlFile, tempdirPath)

import BMMO_XY.tools.*

% Get the filepath and construct the paths for the decrypted file
[~, xmlFileDecrypted, xmlFileDecryptedTemp] = sub_getDecrypedFilePath(xmlFile, tempdirPath);

% URL of the decryption service
url = 'https://crypto.asml.com/ADD/decrypt';

% Construct the command to decrypt
baseCommand = sprintf('curl -A "FC-065/%s" -H "token: %s" -H "streaming: yes" -F "file=@%s" -o %s %s', ...
                      comment, ...
                      token, ...
                      '%s', ...
                      '%s', ...
                      url);

% Construct the full command
shellCommand = sprintf(baseCommand, xmlFile, xmlFileDecrypted);

% Decrypt and place the file in the same location as the protected file
[status, msg] = system(shellCommand);

% If the status is 23, that means that the output directory is read only
if status == 23

    % Construct the full command with the output located in the temporary
    % directory
    shellCommand = sprintf(baseCommand, xmlFile, xmlFileDecryptedTemp);

    % Decrypt and place the file in the temp directory
    [status, msg] = system(shellCommand);

    % Point to the temporary directory
    xmlFileDecrypted = xmlFileDecryptedTemp;
    
    warning('No write access to folder of inputfile, placed decrypted file in folder: %s', tempdirPath);
end

% Print debug information to STDOUT
debugEnv = getenv('BMMO_XY_DECRYPT_DEBUG');
if ~isempty(debugEnv) && strcmp(debugEnv, 'true')
    disp([newline newline 'BMMO_XY_DECRYPT_DEBUG output:' newline shellCommand newline]);
end

if status ~= 0
    error(getErrorId('nonZeroStatus'), 'Decryption was unsuccessful, status code: %s, message: %s (%s)', string(status), msg, url);
end

end


function [filePath, xmlFileDecrypted, xmlFileDecryptedTemp] = sub_getDecrypedFilePath(xmlFile, tempdirPath)

[filePath, fileName, fileExt] = fileparts(xmlFile);

xmlFileDecrypted     = [filePath filesep fileName '_decrypted' fileExt];
xmlFileDecryptedTemp = [tempdirPath filesep fileName '_decrypted' fileExt];

end
