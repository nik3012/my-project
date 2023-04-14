function figs = uncontrolledIntraField(simOutputs, lotDates, Kfactors, machineName)
%figs = uncontrolledIntraField(simOutputs, lotDates, Kfactors, machineName)
%
% This function generates 2 figures (1 per chuck), both containing a trend bar plot of 
% the 99.7 percentile of the uncontrolled intrafield overlay values and multiple trend
% line plots showing the k factors.
%
% Input arguments:
% - simOutputs      [array of struct]               Structs containing the outputs 
%                                                      as defined by the rerun/selfcorrection scripts
% - lotDates        [cell array of datetime]        Dates of the jobs
% - Kfactors        [cell array of char array]      K factors that are plotted
% - machineName     [char array]                    Name of the machine
%
% Output arguments:
% - figs            [array of figure]               The two figures containing the 
%                                                       trend plots


import BMMO_XY.populationTooling.plots.*
import BMMO_XY.populationTooling.tools.*

% Extract the KPIs
uncontrolled = extractOvlKpis(extractArrayFromStruct(simOutputs, 'kpis.uncontrolled.intrafield'), '997');

for index = 1 : length(Kfactors)
    kFactor = Kfactors{index};
    kFactors.(kFactor).chk1 = extractArrayFromStruct(simOutputs, ['kpis.uncontrolled.intrafield.ovl_' kFactor '_chk1']);
    kFactors.(kFactor).chk2 = extractArrayFromStruct(simOutputs, ['kpis.uncontrolled.intrafield.ovl_' kFactor '_chk2']);
end

% Plot the values for Chuck 1
resetColors;
[fig1, ~] = trendBarPlot(lotDates, scaleCellArray({uncontrolled.chk1.x}, 10^9), ...
                         'valuesDescription', {'Uncontrolled'}, ...
                         'figureUnit', 'Uncontrolled 99.7 [nm]', ...
                         'figureTitle', ['Intrafield K factors: ' machineName '. Chuck 1']);
resetColors;
[fig1, ~] = trendBarPlot(lotDates, scaleCellArray({uncontrolled.chk1.y}, -10^9), 'useFigure', fig1);

resetColors;
for index = 1 : length(Kfactors)
    kFactor = Kfactors{index};
    [fig1, ~] = trendLinePlot(lotDates, {kFactors.(kFactor).chk1}, ...
                              'valuesDescription', {kFactor}, ...
                              'figureUnit', 'K factors', ...
                              'useFigure', fig1);
end

% Plot the values for Chuck 2
resetColors;
[fig2, ~] = trendBarPlot(lotDates, scaleCellArray({uncontrolled.chk2.x}, 10^9), ...
                         'valuesDescription', {'Uncontrolled'}, ...
                         'figureUnit', 'Uncontrolled 99.7 [nm]', ...
                         'figureTitle', ['Intrafield K factors: ' machineName '. Chuck 2']);
resetColors;
[fig2, ~] = trendBarPlot(lotDates, scaleCellArray({uncontrolled.chk2.y}, -10^9), 'useFigure', fig2);

resetColors;
for index = 1 : length(Kfactors)
    kFactor = Kfactors{index};
    [fig2, ~] = trendLinePlot(lotDates, {kFactors.(kFactor).chk2}, ...
                              'valuesDescription', {kFactor}, ...
                              'figureUnit', 'K factors', ...
                              'useFigure', fig2);
end

% Return the figure handles
figs = [fig1, fig2];

end