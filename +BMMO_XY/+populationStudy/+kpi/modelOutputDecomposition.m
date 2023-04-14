function figs = modelOutputDecomposition(simOutputs, lotDates, machineName)
%figs = modelOutputDecomposition(simOutputs, lotDates, machineName)
%
% This function generates 2 figures (1 per chuck), both containing trend line plots of
% the 99.7 percentile of the uncontrolled overlay values and total filtered correction
% overlay values. The figures also contain trend bar plots of the 99.7 percentile of the
% overlay values of the KA, BAO, MI, INTRAF and SUSD corrections.
%
% Input arguments:
% - simOutputs      [array of struct]               Structs containing the
%                                                      outputs as defined by the rerun/selfcorrection scripts
% - lotDates        [cell array of datetime]        Dates of the jobs
% - machineName     [char array]                    Name of the machine
%
% Output arguments:
% - figs            [array of figure]               The two figures containing the 
%                                                      trend plots


import BMMO_XY.populationTooling.plots.*
import BMMO_XY.populationTooling.tools.*

% Certain KPIs (in this case KA and MI) have different names when the job is ran on OTAS vs LIS.

% Try to obtain the platform from simOutputs. Check which jobs are LIS and
% OTAS and create a logical array with LIS = 1 and OTAS = 0
% (isLISindexArray). 
platformCellArray = extractArrayFromStruct(simOutputs, 'bmmoInputsRecorrected.info.configuration_data.platform');
isLISindexArray = cellfun(@(x) string(x) == "LIS", platformCellArray);

%Additionally, a logical array is created with LIS = 0 and OTAS = 1 (isOTASindexArray).
%Together the logical arrays are used to check whether all the KPIs have a
%platform. If not, a warning is given and all jobs without a platform are
%removed.
isOTASindexArray = cellfun(@(x) string(x) == "OTAS", platformCellArray);
indexArray = logical(isLISindexArray + isOTASindexArray);
if any(~indexArray)
    simOutputs = simOutputs(indexArray);
    lotDates = lotDates(indexArray);
    isLISindexArray = isLISindexArray(indexArray);
    isOTASindexArray = isOTASindexArray(indexArray);
    
    noPlatformIndex = find(indexArray==0);

warning('Platform unknown or not found for jobs with index %s. These jobs are not included.', num2str(reshape(noPlatformIndex, 1,[])));
end

% Extract KPIs which are all the same
uncontrolled  = extractOvlKpis(extractArrayFromStruct(simOutputs, 'kpis.uncontrolled.overlay'), '997');
totalFiltered = extractOvlKpis(extractArrayFromStruct(simOutputs, 'kpis.correction.total_filtered.total'), '997');
BAO           = extractOvlKpis(extractArrayFromStruct(simOutputs, 'kpis.correction.total_filtered.bao'), '997');
INTRAF        = extractOvlKpis(extractArrayFromStruct(simOutputs, 'kpis.correction.total_filtered.intra_raw'), '997');
SUSD          = extractSusdOvlKpis(extractArrayFromStruct(simOutputs, 'kpis.correction.total_filtered.susd'));

% Extract KPIs for MI and KA
% If all the jobs are either OTAS or LIS and we try to look for LIS or OTAS
% kpis respectively, an empty double array is created, which is not
% compatible with a struct array. Therefore, some if-statements need to be
% included. Jobs that have no platform associated are automatically
% omitted.
%OTAS
if any(isOTASindexArray)
    MI_raw(isOTASindexArray) = extractArrayFromStruct(simOutputs(isOTASindexArray), 'kpis.correction.total_filtered.mirror');
    KA_raw(isOTASindexArray) = extractArrayFromStruct(simOutputs(isOTASindexArray), 'kpis.correction.total_filtered.grid');
end
%LIS
if any(isLISindexArray)
    MI_raw(isLISindexArray)  = extractArrayFromStruct(simOutputs(isLISindexArray), 'kpis.correction.total_filtered.mirror.exp');
    KA_raw(isLISindexArray)  = extractArrayFromStruct(simOutputs(isLISindexArray), 'kpis.correction.total_filtered.grid.exp');
end

% Extract the 99.7% kpis
MI = extractMiOvlKpis(MI_raw, '997');
KA = extractOvlKpis(KA_raw, '997');

% Plot the values for Chuck 1
resetColors;
[fig1, ~] = trendLinePlot(lotDates, scaleCellArray({uncontrolled.chk1.x, totalFiltered.chk1.x}, 10^9), ...
                          'valuesDescription', {'Uncontrolled', 'SBC2A Total'}, ...
                          'figureUnit', 'Metro data (uncontrolled)/(sbc2a total) [nm]', ...
                          'figureTitle', ['SBC2A correction decomposition: ' machineName '. Chuck 1, ovX/ovY 99.7%']);
[fig1, ~] = trendBarPlot(lotDates, scaleCellArray({SUSD.chk1.x, BAO.chk1.x, KA.chk1.x, MI.chk1.x, INTRAF.chk1.x}, 10^9), ...
                         'valuesDescription', {'SUSD', 'BAO', 'KA', 'MI', 'INTRAF'}, ...
                         'figureUnit', 'sbc2a modelled content [nm]', ...
                         'useFigure', fig1);
resetColors;
[fig1, ~] = trendLinePlot(lotDates, scaleCellArray({uncontrolled.chk1.y, totalFiltered.chk1.y}, -10^9), 'useFigure', fig1);
[fig1, ~] = trendBarPlot(lotDates, scaleCellArray({SUSD.chk1.y, BAO.chk1.y, KA.chk1.y, MI.chk1.y, INTRAF.chk1.y}, -10^9), 'useFigure', fig1);


% Plot the values for Chuck 2
resetColors;
[fig2, ~] = trendLinePlot(lotDates, scaleCellArray({uncontrolled.chk2.x, totalFiltered.chk2.x}, 10^9), ...
                          'valuesDescription', {'Uncontrolled', 'SBC2A Total'}, ...
                          'figureUnit', 'Metro data (uncontrolled)/(sbc2a total) [nm]', ...
                          'figureTitle', ['SBC2A correction decomposition: ' machineName '. Chuck 2, ovX/ovY 99.7%']);
[fig2, ~] = trendBarPlot(lotDates, scaleCellArray({SUSD.chk2.x, BAO.chk2.x, KA.chk2.x, MI.chk2.x, INTRAF.chk2.x}, 10^9), ...
                         'valuesDescription', {'SUSD', 'BAO', 'KA', 'MI', 'INTRAF'}, ...
                         'figureUnit', 'sbc2a modelled content [nm]', ...
                         'useFigure', fig2);
resetColors;
[fig2, ~] = trendLinePlot(lotDates, scaleCellArray({uncontrolled.chk2.y, totalFiltered.chk2.y}, -10^9), 'useFigure', fig2);
[fig2, ~] = trendBarPlot(lotDates, scaleCellArray({SUSD.chk2.y, BAO.chk2.y, KA.chk2.y, MI.chk2.y, INTRAF.chk2.y}, -10^9), 'useFigure', fig2);

% Return the figure handles
figs = [fig1, fig2];

end