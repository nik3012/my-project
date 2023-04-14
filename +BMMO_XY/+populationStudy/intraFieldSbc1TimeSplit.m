function intraFieldSbc1TimeSplit(machineNames, dataPath)
% intraFieldSbc1TimeSplit(machineNames, dataPath)
%
% Function to partition the datasets per chuck for different machines in between
% setup actions. The partitioned datasets are saved. The setup actions are estimated from sudden changes in
% kpis. Figures for fieldfingerprints of the partitioned datasets per chuck
% are made and placed in a Gif.
%
% Input arguments:
% - machineNames     [ cell of char arrays ]   Array containing the names of
%                                                the machines
% - dataPath         [ char array ]            path of the directory
%                                                containing the ffps
%
%
% NOTE: do the input arguments make sense? Where is ffps? partitionedDates,
% etcetc.
import BMMO_XY.populationTooling.tools.*
import BMMO_XY.populationStudy.intraField.*

for machineIndex = 1 : length(machineNames)
    
    machineName = machineNames{machineIndex};
    
    file = [dataPath filesep machineName filesep 'intraFieldSbc1Study_' machineName '.mat'];
    disp(['loading ' file '...'])
    load(file);
    
    ffpsChk1 = arrayfun(@(x) ovl_combine_wafers(ffps(x), 1), 1 : length(ffps));
    ffpsChk2 = arrayfun(@(x) ovl_combine_wafers(ffps(x), 2), 1 : length(ffps));
    
    setupActionIndexChk1 = getSetupActionIndexFromPartitionedDates(partitionedDates{1}, dates);
    setupActionIndexChk2 = getSetupActionIndexFromPartitionedDates(partitionedDates{2}, dates);
    
    [partitionedFfpsChk1, ~] = partitionDataSetupActionDates(ffpsChk1, dates, setupActionIndexChk1);
    [partitionedFfpsChk2, ~] = partitionDataSetupActionDates(ffpsChk2, dates, setupActionIndexChk2);

    partitionedFfps = {partitionedFfpsChk1, partitionedFfpsChk2};
 
    figs{1}     = [];
    figs{2}     = [];
    filename{1} = ['sbc1_controlled_ffps_' machineName '_chk1_set'];
    filename{2} = ['sbc1_controlled_ffps_' machineName '_chk2_set'];
    for index = 1 : length(partitionedFfps{1})
        for chuckIndex = [1 2]
            figs{chuckIndex} = [figs{chuckIndex}, ...
                generateFieldFingerPrintGif(partitionedFfps{chuckIndex}{index}, ...
                partitionedDates{chuckIndex}{index}, ...
                ['SBC1 controlled residuals of machine: ' machineName], ...
                [filename{chuckIndex} num2str(index)], ...
                [dataPath filesep machineName], ...
                2)];
        end
    end
    close(figs{1});
    close(figs{2});
    
    save([dataPath filesep machineName filesep 'intraFieldSbc1TimeSplit_' machineName '.mat'], ...
        'partitionedFfps', 'partitionedDates'); 
    
end

end