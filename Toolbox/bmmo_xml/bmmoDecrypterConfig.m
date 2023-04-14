classdef (Sealed) bmmoDecrypterConfig
%% <help_update_needed>
%  for the class and for the function
%
%    
    properties

        decryptionMethod    = '';
        decrypterExecutable = 'NOT PROVIDED';
        token               = 'NOT PROVIDED';
        comment             = 'NOT PROVIDED';
        
    end
    
    properties (Constant, Hidden = true)
        
        dialogPrompt      = {'Enter web decrypter service token:', 'Enter comment:'};
        dialogTitle       = 'Credential input';
        dialogDims        = [1 35];
        dialogDefInput    = {'','Baseliner_Overlay_EUV'};
        dialogWindowStyle = 'normal';
        
        defaultDecrypterLocations = {'C:\Program Files\ASML\ASML Data Decrypter\ASML Data Decrypter.exe',...
                                     'C:\Program Files\ASML\ADELDecryptor\ADELDecryptor.exe',...
                                     'C:\Program Files\ASML\ADELDecryptor 1.4\ADELDecryptor.exe'
                                     };
        
    end
    
    properties (Hidden = true)
        
        fileName
        filePath
        file
        
    end
    
    methods
        
        function obj = bmmoDecrypterConfig(fileName)

            if isfile(which(fileName))
                [obj.filePath, fileName, fileExt] = fileparts(bmmo_create_full_file_path(fileName));
                obj.fileName                      = [fileName fileExt];
                obj.file                          = [obj.filePath filesep obj.fileName];
                
                valid = readDecrypterConfiguration; 
                if ~valid
                    fprintf('"%s" points to an incorrect decrypter executable, it will be updated\n', obj.file);    
                    constructDecrypterConfiguration;
                    obj.writeJson(obj, obj.file);
                end                
            else
                obj.fileName = fileName;
                fprintf('"%s" not in search path\n', obj.fileName);
                constructDecrypterConfiguration;
                obj.writeJson(obj);
            end
            
            obj.decryptionMethod = determineDecryptionMethod;
                    
            
            function constructDecrypterConfiguration
                
                if ispc
                    if isfile(obj.defaultDecrypterLocations{1})
                        obj.decrypterExecutable = obj.defaultDecrypterLocations{1};
                    elseif isfile(obj.defaultDecrypterLocations{2})
                        obj.decrypterExecutable = obj.defaultDecrypterLocations{2};
                    elseif isfile(obj.defaultDecrypterLocations{3})
                        obj.decrypterExecutable = obj.defaultDecrypterLocations{3};
                    else
                        fprintf('Requesting the user to specify the location of decrypter executable via GUI\n');
                        [fileNameDecryptor, filePathDecrypter] = uigetfile('', '"ADELDecryptor.exe" or "ASML Data Decrypter.exe"');
                        obj.decrypterExecutable                = [filePathDecrypter filesep fileNameDecryptor];
                    end
                else
                    fprintf('Requesting the user to specify the token and comment for the web decryption service via GUI\n');
                    opts.WindowStyle = obj.dialogWindowStyle;
                    userInput        = inputdlg(obj.dialogPrompt, obj.dialogTitle, obj.dialogDims, obj.dialogDefInput, opts);
                    try
                        obj.token   = userInput{1};
                        obj.comment = userInput{2};
                    catch
                        error('Input of token and comment in dialog box is incorrectly formatted');
                    end
                end
                
            end
            
        
            function valid = readDecrypterConfiguration
                
                try
                    jsonStruct = jsondecode(fileread(obj.file));
                catch
                    error('It seems that there is something wrong with %s. Please remove the file', obj.file);
                end
                
                valid = true;
                
                try
                    if string(jsonStruct.decrypterExecutable) ~= "NOT PROVIDED" && ~isfile(jsonStruct.decrypterExecutable)
                        valid = false;
                    else
                        obj.decrypterExecutable = jsonStruct.decrypterExecutable;
                    end
                    obj.token   = jsonStruct.token;
                    obj.comment = jsonStruct.comment;
                catch
                    error('JSON file "%s" is not correctly formatted', which(obj.fileName));
                end
                
            end
        
            
            function decryptionMethod = determineDecryptionMethod
                
                if string(obj.decrypterExecutable) == "NOT PROVIDED"
                    decryptionMethod = 'web';
                else 
                    [status, cmdout] = system(sprintf('"%s" -h', obj.decrypterExecutable));
                    if status == 10 && isempty(cmdout)
                        decryptionMethod = 'ADELDecryptor';
                    elseif status == 0
                        decryptionMethod = 'ADD';
                    else
                        error('Could not determine the decryption method');
                    end    
                end
                
            end
            
        end
        
    end
       
    methods (Static, Access = private)
        
        function writeJson(obj, file)
            jsonStruct.decrypterExecutable = strrep(obj.decrypterExecutable, '\', '\\');
            jsonStruct.token               = obj.token;
            jsonStruct.comment             = obj.comment;
             
            if ~exist('file', 'var')
                fprintf('Requesting the user to specify the location where to create the new configuration file via GUI\nThe location must be part of the matlab search path.\n');
                [~, filePath, ~] = uiputfile(obj.fileName);
                file             = [filePath filesep obj.fileName];
            end
            
            try
                fileHandle = fopen(file, 'w');
                fprintf(fileHandle, jsonencode(jsonStruct));
                fclose(fileHandle);
            catch
                warning('Unable to write "%s" to provided location', file);
            end
        end
        
    end
    
end
