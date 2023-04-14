function intraFieldMachineSelectionStudy(machineNames, simPath, pptName, pptPath, configuration)
% intraFieldMachineSelectionStudy(machineNames, simPath, pptName, pptPath, configuration)
%
% Function to load a series of simulated (rerun or self-correction)
% datasets for a selection of machines, extract the fieldfingerprints and
% plot the total-, sytsem- and lens-residual kpis and place them in a ppt.
%
% Input arguments:
% - machineNames     [ cell of char arrays ]  Cell containing the names of
%                                               the machines
% - simPath          [ char array ]           Path of the directory
%                                               containing the simulation data (.mat files)
% - pptName          [ char array ]           Name for the savefile of the ppt
% - pptPath          [ char array ]           Path of the directory where the ppt will be saved 
% - configuration    [ function handle ]      configuration of the machine
%                                               default use: configuration = bl3_3600D_model_configuration
%

import BMMO_XY.populationTooling.PPT
import BMMO_XY.populationStudy.intraField.plotSystemAndLensResidualKpis
import BMMO_XY.populationTooling.tools.*

% Initialize the PPT
ppt = PPT(pptName, pptPath);
ppt.setTitle('Intrafield BL4 machine selection study');

for machineIndex = 1 : length(machineNames)
    % Select the machine that will be processed
    machine = machineNames{machineIndex};
    ppt.insertChapter(['Machine: ' machine]);
    
    % Load the data
    file = [simPath filesep 'selfCorrectOutputs_Raw_' machine '.mat'];
    disp(['loading ' file '...'])
    load(file);
    
    % Generate the InlineSDM residual total, system and lens plots
    ffps = extractArrayFromStruct(selfCorrectOutputs, 'wdms.rawIntrafieldFp');
    figs = plotSystemAndLensResidualKpis(ffps, lot_dates, machine, configuration);
    
    % Insert the figures into the PPT
    ppt.insertFigures('InlineSDM residuals decomposition', [machine ' chuck 1'], figs(1));
    ppt.insertFigures('InlineSDM residuals decomposition', [machine ' chuck 2'], figs(2)); 
    close(figs)
    
end

end