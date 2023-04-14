function [partitionedData, partitionedDates] = partitionDataSetupActionDates(data, lotDates, setupActionIndex)
% [partitionedData, partitionedDates] = partitionDataSetupActionDates(data, lotDates, setupActionIndex)
%
% Function that partitions the data and lotdates in segments on when
% setup actions were performed based on setActionIndex from
% estimateSetupActionDatesFromKpis
%
% Input Arguments:
% - data                    [ array of structs ]    Structs containing the
%                                                     data of the jobs
% - lotDates                [ array of datetimes ]  Array containing the
%                                                     datetimes of the jobs
% - setupActionIndex        [ array of doubles ]    Array containing the indices indicating with
%                                                     setup actions were performed.
% 
% Output Arguments:
% - partitionedData         [ array of structs ]    Structs containing the
%                                                     partitioned data of the jobs
% - partitionedDates        [ array of structs ]    Structs containing the
%                                                     partitioned dates of the jobs
%                                               

setupActionIndex     = [1, setupActionIndex];
amountOfSetupActions = length(setupActionIndex);

for index = 2 : amountOfSetupActions
    partitionRange{index - 1}   = setupActionIndex(index - 1) : (setupActionIndex(index) - 1);
    partitionedData{index - 1}  = data(partitionRange{index - 1});
    partitionedDates{index - 1} = lotDates(partitionRange{index - 1});
end

partitionRange{amountOfSetupActions}   = setupActionIndex(end) : length(lotDates);
partitionedData{amountOfSetupActions}  = data(partitionRange{amountOfSetupActions});
partitionedDates{amountOfSetupActions} = lotDates(partitionRange{amountOfSetupActions});

end