var sourceData194 = {"FileContents":["function sdmResults = intraFieldSbc1RunInlineSdmOnAverageFingerPrintPerMachine(machineNames, dataPath, configuration, pptName, pptPath)\r","% sdmResults = intraFieldSbc1RunInlineSdmOnAverageFingerPrintPerMachine(machineNames, dataPath, configuration, pptName, pptPath)\r","%\r","% Function to plot the sbc1 corrected fingerprints, the total correctables, the total residual, the system residuals and lens residuals for x and y by\r","% loading the data per machine, runing inlineSdm and extracting the\r","% fingerprints from which the overlay statistics are calculated. The figures\r","% are automatically placed inside a ppt.\r","%\r","% Input arguments:\r","% - machineNames     [ cell of char arrays ]  Cell containing the names of\r","%                                               the machines\r","% - dataPath         [ char array ]           path of the directory\r","%                                               containing the ffps\r","% - configuration    [ function handle ]      Configuration of the machine\r","%                                               required for running inlineSdm\r","% - pptName          [ char array ]           Name for the savefile of the ppt\r","% - pptPath          [ char array ]           Path of the directory where the ppt will be saved \r","%\r","% Output arguments:        \r","%\r","% - sdmResults        [ array of structs ]    Calculated overlay values\r","%                                               from inlineSdm for the\r","%                                               machines\r","%\r","import BMMO_XY.populationStudy.intraField.*\r","import BMMO_XY.populationTooling.tools.*\r","import BMMO_XY.populationTooling.plots.*\r","import BMMO_XY.populationTooling.PPT\r","\r","\r","% Initialize the PPT\r","ppt = PPT(pptName, pptPath);\r","ppt.setTitle('InlineSDM residuals of average fingerprints per machine');\r","\r","for machineIndex = 1 : length(machineNames)\r","    \r","    % Shortcut to the machine name\r","    machineName = machineNames{machineIndex}; \r","    load([dataPath filesep machineName filesep 'intraFieldSbc1AverageFingerPrints_' machineName '.mat'], 'finalFingerPrintPerMachine');\r","    amountOfTimeSlices = length(finalFingerPrintPerMachine);\r","    \r","    % Run InlineSDM\r","    reports = getInlineSdmReportsFromMls(finalFingerPrintPerMachine, configuration);\r","    \r","    % Extract the various fingerprints\r","    sdmResults.(machineName).input              = finalFingerPrintPerMachine;\r","    sdmResults.(machineName).systemCorrectables = extractArrayFromStruct(reports, 'hoc.mlHocCorr');\r","    sdmResults.(machineName).systemResiduals    = extractArrayFromStruct(reports, 'hoc.mlHocRes');\r","    sdmResults.(machineName).totalCorrectables  = extractArrayFromStruct(reports, 'cor');\r","    sdmResults.(machineName).totalResiduals     = extractArrayFromStruct(reports, 'res');\r","    sdmResults.(machineName).lensCorrectables   = arrayfun(@(x) ovl_sub(sdmResults.(machineName).totalCorrectables(x), sdmResults.(machineName).systemCorrectables(x)), 1 : length(sdmResults.(machineName).totalCorrectables));\r","    sdmResults.(machineName).lensResiduals      = arrayfun(@(x) ovl_sub(sdmResults.(machineName).totalResiduals(x), sdmResults.(machineName).systemResiduals(x)), 1 : length(sdmResults.(machineName).totalResiduals));\r","    \r","    % Calculate overlay values\r","    sdmResults.(machineName).ovl.input              = arrayfun(@(x) ovl_calc_overlay(sdmResults.(machineName).input(x)), 1 : amountOfTimeSlices);\r","    sdmResults.(machineName).ovl.systemCorrectables = arrayfun(@(x) ovl_calc_overlay(sdmResults.(machineName).systemCorrectables(x)), 1 : amountOfTimeSlices);\r","    sdmResults.(machineName).ovl.systemResiduals    = arrayfun(@(x) ovl_calc_overlay(sdmResults.(machineName).systemResiduals(x)), 1 : amountOfTimeSlices);\r","    sdmResults.(machineName).ovl.totalCorrectables  = arrayfun(@(x) ovl_calc_overlay(sdmResults.(machineName).totalCorrectables(x)), 1 : amountOfTimeSlices);\r","    sdmResults.(machineName).ovl.totalResiduals     = arrayfun(@(x) ovl_calc_overlay(sdmResults.(machineName).totalResiduals(x)), 1 : amountOfTimeSlices);\r","    sdmResults.(machineName).ovl.lensCorrectables   = arrayfun(@(x) ovl_calc_overlay(sdmResults.(machineName).lensCorrectables(x)), 1 : amountOfTimeSlices);\r","    sdmResults.(machineName).ovl.lensResiduals      = arrayfun(@(x) ovl_calc_overlay(sdmResults.(machineName).lensResiduals(x)), 1 : amountOfTimeSlices);\r","    \r","    % Create the figs\r","    figs{machineIndex}{1} = fieldFingerPrintPlot(sdmResults.(machineName).input, ['SBC1 corrected fingerprint of machine: ' machineName], 2);\r","    figs{machineIndex}{2} = fieldFingerPrintPlot(sdmResults.(machineName).totalCorrectables, ['Total correctables of machine: ' machineName], 2);\r","    figs{machineIndex}{3} = fieldFingerPrintPlot(sdmResults.(machineName).totalResiduals, ['Total residuals of machine: ' machineName], 1);\r","    figs{machineIndex}{4} = fieldFingerPrintPlot(sdmResults.(machineName).systemResiduals, ['System residuals of machine: ' machineName], 1);\r","    figs{machineIndex}{5} = fieldFingerPrintPlot(sdmResults.(machineName).lensResiduals, ['Lens residuals of machine: ' machineName], 1);\r","\r","    % Create the slides\r","    ppt.insertChapter(machineName);    \r","    for timeSliceIndex = 1 : amountOfTimeSlices\r","        textFig(timeSliceIndex) = textBoxPlot(['Raw ovl 99.7 (x,y) (nm): ' num2str(1e9 * sdmResults.(machineName).ovl.input(timeSliceIndex).ox997) '  ' num2str(1e9 * sdmResults.(machineName).ovl.input(timeSliceIndex).oy997)], ...\r","            ['Total correctable ovl 99.7 (x,y) (nm): ' num2str(1e9 * sdmResults.(machineName).ovl.totalCorrectables(timeSliceIndex).ox997) '  ' num2str(1e9 * sdmResults.(machineName).ovl.totalCorrectables(timeSliceIndex).oy997)], ...\r","            ['Total residuals ovl 99.7 (x,y) (nm): ' num2str(1e9 * sdmResults.(machineName).ovl.totalResiduals(timeSliceIndex).ox997) '  ' num2str(1e9 * sdmResults.(machineName).ovl.totalResiduals(timeSliceIndex).oy997)], ...\r","            ['System residuals ovl 99.7 (x,y) (nm): ' num2str(1e9 * sdmResults.(machineName).ovl.systemResiduals(timeSliceIndex).ox997) '  ' num2str(1e9 * sdmResults.(machineName).ovl.systemResiduals(timeSliceIndex).oy997)], ...\r","            ['Lens residuals ovl 99.7 (x,y) (nm): ' num2str(1e9 * sdmResults.(machineName).ovl.lensResiduals(timeSliceIndex).ox997) '  ' num2str(1e9 * sdmResults.(machineName).ovl.lensResiduals(timeSliceIndex).oy997)]);\r","        ppt.insertFigures(['Results from SDM model of machine: ' machineName], ['Set: ' num2str(timeSliceIndex)], ...\r","            [figs{machineIndex}{1}(timeSliceIndex) ...\r","            figs{machineIndex}{2}(timeSliceIndex) ...\r","            figs{machineIndex}{3}(timeSliceIndex) ...\r","            figs{machineIndex}{4}(timeSliceIndex) ...\r","            figs{machineIndex}{5}(timeSliceIndex) ...\r","            textFig(timeSliceIndex)]);\r","    end\r","    \r","    close(textFig);\r","    close(figs{machineIndex}{:});    \r","    \r","end\r","\r","end"],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[32,33,35,38,39,40,43,46,47,48,49,50,51,52,55,56,57,58,59,60,61,64,65,66,67,68,71,72,73,74,75,76,77,78,79,80,81,82,83,84,87,88],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}