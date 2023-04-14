function intraFieldSbc1GetAverageFingerPrintPerMachine(machineNames, dataPath, pptName, pptPath)
% intraFieldSbc1GetAverageFingerPrintPerMachine(machineNames, dataPath, pptName, pptPath)
%
% Function that loads the intrafield fingerprints, calculates 
% and plots the average ffps per machine per partitioned dataset.
%
% Input arguments:
% - machineNames     [ cell of char arrays ]  Cell containing the names of
%                                               the machines
% - dataPath         [ char array ]           Path of the directory
%                                               containing the ffps
% - pptName          [ char array ]           Name for the savefile of the ppt
% - pptPath          [ char array ]           Path of the directory where the ppt will be saved 
%

import BMMO_XY.populationTooling.plots.*
import BMMO_XY.populationTooling.PPT


% Initialize the PPT
ppt = PPT(pptName, pptPath);
ppt.setTitle('Average fingerprints per machine');

for machineIndex = 1 : length(machineNames)
    
    % Shortcut to the machine name
    machineName = machineNames{machineIndex};
    ppt.insertChapter(machineName);  
    load([dataPath filesep machineName filesep 'intraFieldSbc1TimeSplit_' machineName '.mat'], 'partitionedFfps');

    % Create the averaged final and start fingerprints
    cellFfps = reshape([partitionedFfps{1}; partitionedFfps{2}], 1, 2 * length(partitionedFfps{1})); 
    for cellIndex = 1 : length(cellFfps) 
        
        % Select the last 5 fingerprints
        try
            selection = num2cell(cellFfps{cellIndex}((end - 4) : end));
        catch
            selection = num2cell(cellFfps{cellIndex});
        end
        
        % Average the fingerprints
        finalFingerPrint{machineIndex}(cellIndex) = ovl_average(selection{:}, 'overall');
                
        % Create the plots
        figs{machineIndex}(cellIndex) = fieldFingerPrintPlot(finalFingerPrint{machineIndex}(cellIndex), ...
            ['Average final fingerprint of machine: ' machineName ' set: ' cellIndex], 2);

    end
    
    % Create the slide
    ppt.insertFigures('Average final fingerprints', machineName, figs{machineIndex});
    close(figs{machineIndex});
    
    % Save the results
    finalFingerPrintPerMachine = finalFingerPrint{machineIndex};
    save([dataPath filesep machineName filesep 'intraFieldSbc1AverageFingerPrints_' machineName '.mat'], 'finalFingerPrintPerMachine');
    
end

end