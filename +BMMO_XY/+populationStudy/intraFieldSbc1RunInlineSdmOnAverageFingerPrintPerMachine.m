function sdmResults = intraFieldSbc1RunInlineSdmOnAverageFingerPrintPerMachine(machineNames, dataPath, configuration, pptName, pptPath)
% sdmResults = intraFieldSbc1RunInlineSdmOnAverageFingerPrintPerMachine(machineNames, dataPath, configuration, pptName, pptPath)
%
% Function to plot the sbc1 corrected fingerprints, the total correctables, the total residual, the system residuals and lens residuals for x and y by
% loading the data per machine, runing inlineSdm and extracting the
% fingerprints from which the overlay statistics are calculated. The figures
% are automatically placed inside a ppt.
%
% Input arguments:
% - machineNames     [ cell of char arrays ]  Cell containing the names of
%                                               the machines
% - dataPath         [ char array ]           path of the directory
%                                               containing the ffps
% - configuration    [ function handle ]      Configuration of the machine
%                                               required for running inlineSdm
% - pptName          [ char array ]           Name for the savefile of the ppt
% - pptPath          [ char array ]           Path of the directory where the ppt will be saved 
%
% Output arguments:        
%
% - sdmResults        [ array of structs ]    Calculated overlay values
%                                               from inlineSdm for the
%                                               machines
%
import BMMO_XY.populationStudy.intraField.*
import BMMO_XY.populationTooling.tools.*
import BMMO_XY.populationTooling.plots.*
import BMMO_XY.populationTooling.PPT


% Initialize the PPT
ppt = PPT(pptName, pptPath);
ppt.setTitle('InlineSDM residuals of average fingerprints per machine');

for machineIndex = 1 : length(machineNames)
    
    % Shortcut to the machine name
    machineName = machineNames{machineIndex}; 
    load([dataPath filesep machineName filesep 'intraFieldSbc1AverageFingerPrints_' machineName '.mat'], 'finalFingerPrintPerMachine');
    amountOfTimeSlices = length(finalFingerPrintPerMachine);
    
    % Run InlineSDM
    reports = getInlineSdmReportsFromMls(finalFingerPrintPerMachine, configuration);
    
    % Extract the various fingerprints
    sdmResults.(machineName).input              = finalFingerPrintPerMachine;
    sdmResults.(machineName).systemCorrectables = extractArrayFromStruct(reports, 'hoc.mlHocCorr');
    sdmResults.(machineName).systemResiduals    = extractArrayFromStruct(reports, 'hoc.mlHocRes');
    sdmResults.(machineName).totalCorrectables  = extractArrayFromStruct(reports, 'cor');
    sdmResults.(machineName).totalResiduals     = extractArrayFromStruct(reports, 'res');
    sdmResults.(machineName).lensCorrectables   = arrayfun(@(x) ovl_sub(sdmResults.(machineName).totalCorrectables(x), sdmResults.(machineName).systemCorrectables(x)), 1 : length(sdmResults.(machineName).totalCorrectables));
    sdmResults.(machineName).lensResiduals      = arrayfun(@(x) ovl_sub(sdmResults.(machineName).totalResiduals(x), sdmResults.(machineName).systemResiduals(x)), 1 : length(sdmResults.(machineName).totalResiduals));
    
    % Calculate overlay values
    sdmResults.(machineName).ovl.input              = arrayfun(@(x) ovl_calc_overlay(sdmResults.(machineName).input(x)), 1 : amountOfTimeSlices);
    sdmResults.(machineName).ovl.systemCorrectables = arrayfun(@(x) ovl_calc_overlay(sdmResults.(machineName).systemCorrectables(x)), 1 : amountOfTimeSlices);
    sdmResults.(machineName).ovl.systemResiduals    = arrayfun(@(x) ovl_calc_overlay(sdmResults.(machineName).systemResiduals(x)), 1 : amountOfTimeSlices);
    sdmResults.(machineName).ovl.totalCorrectables  = arrayfun(@(x) ovl_calc_overlay(sdmResults.(machineName).totalCorrectables(x)), 1 : amountOfTimeSlices);
    sdmResults.(machineName).ovl.totalResiduals     = arrayfun(@(x) ovl_calc_overlay(sdmResults.(machineName).totalResiduals(x)), 1 : amountOfTimeSlices);
    sdmResults.(machineName).ovl.lensCorrectables   = arrayfun(@(x) ovl_calc_overlay(sdmResults.(machineName).lensCorrectables(x)), 1 : amountOfTimeSlices);
    sdmResults.(machineName).ovl.lensResiduals      = arrayfun(@(x) ovl_calc_overlay(sdmResults.(machineName).lensResiduals(x)), 1 : amountOfTimeSlices);
    
    % Create the figs
    figs{machineIndex}{1} = fieldFingerPrintPlot(sdmResults.(machineName).input, ['SBC1 corrected fingerprint of machine: ' machineName], 2);
    figs{machineIndex}{2} = fieldFingerPrintPlot(sdmResults.(machineName).totalCorrectables, ['Total correctables of machine: ' machineName], 2);
    figs{machineIndex}{3} = fieldFingerPrintPlot(sdmResults.(machineName).totalResiduals, ['Total residuals of machine: ' machineName], 1);
    figs{machineIndex}{4} = fieldFingerPrintPlot(sdmResults.(machineName).systemResiduals, ['System residuals of machine: ' machineName], 1);
    figs{machineIndex}{5} = fieldFingerPrintPlot(sdmResults.(machineName).lensResiduals, ['Lens residuals of machine: ' machineName], 1);

    % Create the slides
    ppt.insertChapter(machineName);    
    for timeSliceIndex = 1 : amountOfTimeSlices
        textFig(timeSliceIndex) = textBoxPlot(['Raw ovl 99.7 (x,y) (nm): ' num2str(1e9 * sdmResults.(machineName).ovl.input(timeSliceIndex).ox997) '  ' num2str(1e9 * sdmResults.(machineName).ovl.input(timeSliceIndex).oy997)], ...
            ['Total correctable ovl 99.7 (x,y) (nm): ' num2str(1e9 * sdmResults.(machineName).ovl.totalCorrectables(timeSliceIndex).ox997) '  ' num2str(1e9 * sdmResults.(machineName).ovl.totalCorrectables(timeSliceIndex).oy997)], ...
            ['Total residuals ovl 99.7 (x,y) (nm): ' num2str(1e9 * sdmResults.(machineName).ovl.totalResiduals(timeSliceIndex).ox997) '  ' num2str(1e9 * sdmResults.(machineName).ovl.totalResiduals(timeSliceIndex).oy997)], ...
            ['System residuals ovl 99.7 (x,y) (nm): ' num2str(1e9 * sdmResults.(machineName).ovl.systemResiduals(timeSliceIndex).ox997) '  ' num2str(1e9 * sdmResults.(machineName).ovl.systemResiduals(timeSliceIndex).oy997)], ...
            ['Lens residuals ovl 99.7 (x,y) (nm): ' num2str(1e9 * sdmResults.(machineName).ovl.lensResiduals(timeSliceIndex).ox997) '  ' num2str(1e9 * sdmResults.(machineName).ovl.lensResiduals(timeSliceIndex).oy997)]);
        ppt.insertFigures(['Results from SDM model of machine: ' machineName], ['Set: ' num2str(timeSliceIndex)], ...
            [figs{machineIndex}{1}(timeSliceIndex) ...
            figs{machineIndex}{2}(timeSliceIndex) ...
            figs{machineIndex}{3}(timeSliceIndex) ...
            figs{machineIndex}{4}(timeSliceIndex) ...
            figs{machineIndex}{5}(timeSliceIndex) ...
            textFig(timeSliceIndex)]);
    end
    
    close(textFig);
    close(figs{machineIndex}{:});    
    
end

end