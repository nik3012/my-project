var sourceData203 = {"FileContents":["function figs = interFieldRadial(simOutputs, lotDates, machineName)\r","% figs = interFieldRadial(simOutputs, lotDates, machineName)\r","%\r","% Function that extracts the mean radial, mean radial_inward and 99.7% outer\r","% clamp ovl kpis and plots them for chuck 1 and chuck 2 respectively.\r","%\r","% Input arguments:\r","% - simOutputs      [ array of structs ]               Structs containing the outputs \r","%                                                        as defined by the rerun/selfcorrection scripts\r","% - lotDates        [ cell array of datetimes ]        Dates of the jobs\r","% - machineName     [ char array ]                     Name of the machine\r","%\r","% Output arguments:\r","% - figs            [ array of figures ]               The two figures containing the \r","%                                                        trend plots\r","%\r","\r","import BMMO_XY.populationTooling.plots.*\r","import BMMO_XY.populationTooling.tools.*\r","\r","% Extract the KPIs\r","radial       = extractKAOvlKpis(simOutputs, 'radial', 'mean', true);\r","radialInward = extractKAOvlKpis(simOutputs, 'radial_inward', 'mean', true);\r","outer        = extractKAOvlKpis(simOutputs, 'outer', '997');\r","\r","% Plot the values for Chuck 1\r","resetColors;\r","[fig1, ~] = trendLinePlot(lotDates, scaleCellArray({radial.chk1.mean, radialInward.chk1.mean}, 10^9), ...\r","                          'valuesDescription', {'Radial Mean', 'Radial Inward Mean'}, ...\r","                          'figureUnit', 'Uncontrolled KPIs [nm]', ...\r","                          'figureTitle', ['Interfield KA: ' machineName '. Chuck 1']);\r","\r","[fig1, ~] = trendBarPlot(lotDates, scaleCellArray({outer.chk1.x}, 10^9), ...\r","                          'valuesDescription', {'Outer 997'}, ...\r","                          'figureUnit', 'Input KPIs [nm]', ...\r","                          'useFigure', fig1);\r","resetColors;\r","[fig1, ~] = trendBarPlot(lotDates, scaleCellArray({outer.chk1.y}, -10^9), 'useFigure', fig1);\r","\r","% Plot the values for Chuck 2\r","resetColors;\r","[fig2, ~] = trendLinePlot(lotDates, scaleCellArray({radial.chk2.mean, radialInward.chk2.mean}, 10^9), ...\r","                          'valuesDescription', {'Radial Mean', 'Radial Inward Mean'}, ...\r","                          'figureUnit', 'Uncontrolled KPIs [nm]', ...\r","                          'figureTitle', ['Interfield KA: ' machineName '. Chuck 2']);\r","\r","[fig2, ~] = trendBarPlot(lotDates, scaleCellArray({outer.chk2.x}, 10^9), ...\r","                          'valuesDescription', {'Outer 997'}, ...\r","                          'figureUnit', 'Input KPIs [nm]', ...\r","                          'useFigure', fig2);\r","resetColors;\r","[fig2, ~] = trendBarPlot(lotDates, scaleCellArray({outer.chk2.y}, -10^9), 'useFigure', fig2);\r","\r","% Return the figure handles\r","figs = [fig1, fig2];\r","\r","end"],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[22,23,24,27,28,31,33,36,37,38,41,42,45,47,50,51,52,55],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}