classdef PPT
    
    properties (SetAccess = immutable)
        
        filehandle
        filename
        
    end
    
    properties (Hidden)
        
        cleanup
        
    end
    
    methods
        
        function obj = PPT(filename, filelocation)
            
            % Input arguments processing
            if ~exist('filelocation', 'var')
                filelocation = pwd;
            end
            
            % Define the filename
            obj.filename = [strip(filelocation, 'right', filesep) ...
                            filesep ...
                            BMMO_XY.populationTooling.tools.files.stripFileExt(filename) ...
                            '.pptx'];
                        
            % Check if the file already exists
            if exist(obj.filename, 'file') == 2
                warning('%s already exists, will append to it.', obj.filename)
            end
            
            % Open the PPT
            try
                % Suppress a warning about an "unrecognized pragma" in the function openppt
                warning('off', 'all');
                [~, obj.filehandle] = openppt(obj.filename, 'new');
                warning('on', 'all');
            catch ME
                error('Could not open the PPT, see:\n%s', ME.message);
            end
            
            % Make sure to save the PPT at destruction
            obj.cleanup = onCleanup(@() closeFile(obj));
            
        end
        
        % Save the PPT
        saveFile(obj)
        
        % Close the PPT
        closeFile(obj)
        
        % Set the title of the PPT
        setTitle(obj, title)
        
        % Insert a plot into a new slide of the PPT
        insertFigures(obj, slideTitle, slideSubtitle, figures, useRows)
        
        % Insert an animation into a new slide of the PPT
        insertAnimation(obj, slideTitle, slideSubtitle, animationFile)
        
        % Insert a slide to indicate a new chapter of the PPT
        insertChapter(obj, chapterTitle)
        
    end
    
end

