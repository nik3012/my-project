var sourceData198 = {"FileContents":["function figs = generateFieldFingerPrintGif(ffps, lotDates, figureTitle, filename, filelocation, scale)\r","% figs = generateFieldFingerPrintGif(ffps, lotDates, figureTitle, filename, filelocation, scale)\r","%\r","% This function generates a GIF of a series of fieldfingerprints,\r","% by creating figures of the ffps and placing them in a Gif. This function\r","% is particularly useful for observing the changes of the ffps over time.\r","%\r","% Input arguments:\r","% - ffps        [ array of struct ]           Structs containing the ffps of\r","%                                             the different jobs\r","% - lotDates    [ array of datetimes ]        Dates of the jobs\r","% - figureTitle [ char array ]                Title of the figures and thereby the Gif\r","% - filename    [ char array ]                Name under which the Gif will\r","%                                             be saved\r","% - filelocation[ char array ]                Directory where the Gif will be\r","%                                             saved\r","% - scale       [ double ]                    Relative size of the Gif image\r","%\r","% Output arguments:\r","% - figs        [ array of figures ]           Array containing the generated ffps that make up the the Gif\r","%\r","\r","import BMMO_XY.populationTooling.plots.fieldFingerPrintPlot\r","import BMMO_XY.populationTooling.animations.figsToGif\r","\r","\r","% Generate figs of the fingerprints\r","if exist('scale', 'var')\r","    figs = fieldFingerPrintPlot(ffps, figureTitle, scale);\r","else\r","    figs = fieldFingerPrintPlot(ffps, figureTitle);\r","end\r","\r","% Add the dates to the figure titles\r","for index = 1 : length(figs)\r","    figs(index).CurrentAxes.Subtitle.Visible = 'on';\r","    figs(index).CurrentAxes.Subtitle.String  = datestr(lotDates(index));\r","end\r","\r","% Generate the GIF\r","figsToGif(figs, filename, filelocation);\r","\r","end\r",""],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[28,29,30,31,35,36,37,41],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}