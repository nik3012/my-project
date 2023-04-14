function figs = plotSystemAndLensResidualKpis(ffps, lotDates, machineName, configuration)
% figs = plotSystemAndLensResidualKpis(ffps, lotDates, machineName, configuration)
%
% Function to extract and plot the lens-, system- and total-kpis for
% the residuals of inlineSdm for chuck 1 and chuck 2 respectively for the given field fingerprints.
%
% Input arguments:
% - ffps             [ array of structs ]      Structs containing the ffps of the jobs
% - lotDates         [ array of datetimes ]    Dates of the jobs
% - machineName      [ char array ]            The name of the machine
% - configuration    [ function handle ]       Configuration of the machine
%                                                for calculating inlineSdm (fe. bmmo_3600D_model_configuration)
%
% Output arguments:
% - figs              [ Array of figures ]     Array containing the figures
%                                                with the plotted kpis
%

import BMMO_XY.populationTooling.plots.*
import BMMO_XY.populationTooling.tools.*
import BMMO_XY.populationStudy.intraField.getInlineSdmReportsFromMls


% Calculate the overlay values of the ffps
overlayValues = arrayfun(@(x) ovl_calc_overlay(ffps(x), 'perwafer'), 1 : length(ffps));
ffpKpi.chk1.x = extractArrayFromStruct(overlayValues, 'ox100(1)');
ffpKpi.chk1.y = extractArrayFromStruct(overlayValues, 'oy100(1)');
ffpKpi.chk2.x = extractArrayFromStruct(overlayValues, 'ox100(2)');
ffpKpi.chk2.y = extractArrayFromStruct(overlayValues, 'oy100(2)');

% Remove the outliers
[~, outlierIndexChk1X] = rmoutliers(ffpKpi.chk1.x); ffpKpi.chk1.x(outlierIndexChk1X) = NaN;
[~, outlierIndexChk1Y] = rmoutliers(ffpKpi.chk1.y); ffpKpi.chk1.y(outlierIndexChk1Y) = NaN;
[~, outlierIndexChk2X] = rmoutliers(ffpKpi.chk2.x); ffpKpi.chk2.x(outlierIndexChk2X) = NaN;
[~, outlierIndexChk2Y] = rmoutliers(ffpKpi.chk2.y); ffpKpi.chk2.y(outlierIndexChk2Y) = NaN;

% Apply inlineSDM
inlineSdmReports = getInlineSdmReportsFromMls(ffps, configuration);

% Extract the KPIs
lensKpi   = extractInlineSdmLensOvlKpis(inlineSdmReports);
systemKpi = extractInlineSdmSystemOvlKpis(inlineSdmReports);
totalKpi  = extractInlineSdmTotalOvlKpis(inlineSdmReports);

% Plot the values for Chuck 1
resetColors;
[fig1, ~] = trendLinePlot(lotDates, scaleCellArray({totalKpi.chk1.x, systemKpi.chk1.x, lensKpi.x, ffpKpi.chk1.x}, 10^9), ...
                          'valuesDescription', {'Total', 'System', 'Lens', 'Input'}, ...
                          'figureUnit', 'inlineSDM residuals max [nm]', ...
                          'figureTitle', ['Intrafield inlineSDM: ' machineName '. Chuck 1']);
resetColors;
[fig1, ~] = trendLinePlot(lotDates, scaleCellArray({totalKpi.chk1.y, systemKpi.chk1.y, lensKpi.y, ffpKpi.chk1.y}, -10^9), 'useFigure', fig1);
fig1.CurrentAxes.YAxis(1).Visible = 'off';

% Plot the values for Chuck 2
resetColors;
[fig2, ~] = trendLinePlot(lotDates, scaleCellArray({totalKpi.chk2.x, systemKpi.chk2.x, lensKpi.x, ffpKpi.chk2.x}, 10^9), ...
                          'valuesDescription', {'Total', 'System', 'Lens', 'Input'}, ...
                          'figureUnit', 'inlineSDM residuals max [nm]', ...
                          'figureTitle', ['Intrafield inlineSDM: ' machineName '. Chuck 2']);
resetColors;
[fig2, ~] = trendLinePlot(lotDates, scaleCellArray({totalKpi.chk2.y, systemKpi.chk2.y, lensKpi.y, ffpKpi.chk2.y}, -10^9), 'useFigure', fig2);
fig2.CurrentAxes.YAxis(1).Visible = 'off';

% Return the figure handles
figs = [fig1, fig2];

end