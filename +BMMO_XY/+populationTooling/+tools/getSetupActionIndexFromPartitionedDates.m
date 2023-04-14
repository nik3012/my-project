function setupActionIndex = getSetupActionIndexFromPartitionedDates(partitionedDates, lotDates)
% setupActionIndex = getSetupActionIndexFromPartitionedDates(partitionedDates, lotDates)
%
% Function that determines at which indices setup actions were performed.
%
% Input Arguments:
% - partitionedDates        [ cell of structs ]     Structs containing the
%                                                     dates at which setup actions were performed
% - lotDates                [ array of datetimes ]  Array containing the
%                                                     datetimes of the jobs
% 
% Output Arguments:
% - setupActionIndex        [ array of doubles ]    Array containing the
%                                                     indices indicating when setup actions were performed.
%
% NOTE: This function does the same as: estimateSetupActionDatesFromKpis                                              

for index = 1 : (length(partitionedDates) - 1)
    setupActionIndex(index) = find(lotDates == partitionedDates{index + 1}(1));
end

end