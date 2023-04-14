function figs = interFieldRadial(simOutputs, lotDates, machineName)
% figs = interFieldRadial(simOutputs, lotDates, machineName)
%
% Function that extracts the mean radial, mean radial_inward and 99.7% outer
% clamp ovl kpis and plots them for chuck 1 and chuck 2 respectively.
%
% Input arguments:
% - simOutputs      [ array of structs ]               Structs containing the outputs 
%                                                        as defined by the rerun/selfcorrection scripts
% - lotDates        [ cell array of datetimes ]        Dates of the jobs
% - machineName     [ char array ]                     Name of the machine
%
% Output arguments:
% - figs            [ array of figures ]               The two figures containing the 
%                                                        trend plots
%

import BMMO_XY.populationTooling.plots.*
import BMMO_XY.populationTooling.tools.*

% Extract the KPIs
radial       = extractKAOvlKpis(simOutputs, 'radial', 'mean', true);
radialInward = extractKAOvlKpis(simOutputs, 'radial_inward', 'mean', true);
outer        = extractKAOvlKpis(simOutputs, 'outer', '997');

% Plot the values for Chuck 1
resetColors;
[fig1, ~] = trendLinePlot(lotDates, scaleCellArray({radial.chk1.mean, radialInward.chk1.mean}, 10^9), ...
                          'valuesDescription', {'Radial Mean', 'Radial Inward Mean'}, ...
                          'figureUnit', 'Uncontrolled KPIs [nm]', ...
                          'figureTitle', ['Interfield KA: ' machineName '. Chuck 1']);

[fig1, ~] = trendBarPlot(lotDates, scaleCellArray({outer.chk1.x}, 10^9), ...
                          'valuesDescription', {'Outer 997'}, ...
                          'figureUnit', 'Input KPIs [nm]', ...
                          'useFigure', fig1);
resetColors;
[fig1, ~] = trendBarPlot(lotDates, scaleCellArray({outer.chk1.y}, -10^9), 'useFigure', fig1);

% Plot the values for Chuck 2
resetColors;
[fig2, ~] = trendLinePlot(lotDates, scaleCellArray({radial.chk2.mean, radialInward.chk2.mean}, 10^9), ...
                          'valuesDescription', {'Radial Mean', 'Radial Inward Mean'}, ...
                          'figureUnit', 'Uncontrolled KPIs [nm]', ...
                          'figureTitle', ['Interfield KA: ' machineName '. Chuck 2']);

[fig2, ~] = trendBarPlot(lotDates, scaleCellArray({outer.chk2.x}, 10^9), ...
                          'valuesDescription', {'Outer 997'}, ...
                          'figureUnit', 'Input KPIs [nm]', ...
                          'useFigure', fig2);
resetColors;
[fig2, ~] = trendBarPlot(lotDates, scaleCellArray({outer.chk2.y}, -10^9), 'useFigure', fig2);

% Return the figure handles
figs = [fig1, fig2];

end