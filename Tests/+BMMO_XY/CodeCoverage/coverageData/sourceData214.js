var sourceData214 = {"FileContents":["function [fig, plt] = trendLinePlot(lotDates, values, varargin)\r","% varargin = {'valuesDescription' = [cell array] Labels describing the data\r","%             'figureTitle'       = [char array] Title of the figure\r","%             'figureUnit'        = [char array] Label of the Y axis\r","%             'useFigure'         = [figure]     Figure to insert the plots in\r","%             'convertDatetimes'  = [boolean]    Convert the dates to integers (default = true)}\r","\r","[fig, plt] = trendPlot(@linePlot, lotDates, values, varargin);\r","\r","end"],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":8,"HitCount":[0,0,0,0,0,0,0,0,0,0]}}