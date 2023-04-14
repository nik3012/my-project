function [setupActionDates, setupActionIndex] = estimateSetupActionDatesFromKpis(kpis, lotDates, thresholdScale)
% [setupActionDates, setupActionIndex] = estimateSetupActionDatesFromKpis(kpis, lotDates, thresholdScale)
%
% Function that estimates the dates at which setup actions took place in
% large datasets. It looks at sudden changes in kpis above a certain
% threshold. The function gives the dates at which setup actions took place
% and the corresponding values of the indices.
%
% Input arguments:
% - kpis            [ array of structs ]             structs containing the kpis
%                                                      from the inlineSdm models
% - lotDates        [ array of datetimes ]           Dates of the jobs
% - thresholdScale  [ double ]                       Maximum allowed relative change of the kpis
%                                                    from one data set to the other. Changes above
%                                                      the threshold indicate a setup action.
%
% Output arguments:
% - setupActionDates       [ array of structs ]      lotDates at which setup actions were performed (kpi changes above the threshold)  
% - setupActionIndex       [ array of structs ]      Indices of the lotDates at which setup actions were performed 
%                                                      (kpi changes above the threshold)
%


setupActionDateIndex = 1;
for kpiIndex = 1 : length(kpis)
    KPI = kpis{kpiIndex};
    thresholdUpdateLimit = 0.01 * max(abs(KPI));
    threshold = thresholdScale * abs(KPI(1));
    for dateIndex = 2 : length(lotDates)
        delta = abs(KPI(dateIndex) - KPI(dateIndex - 1));
        if delta >= threshold
            setupActionIndex{setupActionDateIndex} = dateIndex;
            setupActionDateIndex = setupActionDateIndex + 1;
        end
        if delta >= thresholdUpdateLimit
            threshold = thresholdScale * delta;
        end
    end
end

setupActionIndex = unique(cell2mat(setupActionIndex));
setupActionDates = lotDates(setupActionIndex);

end