function [fig, plt] = trendLinePlot(lotDates, values, varargin)
% varargin = {'valuesDescription' = [cell array] Labels describing the data
%             'figureTitle'       = [char array] Title of the figure
%             'figureUnit'        = [char array] Label of the Y axis
%             'useFigure'         = [figure]     Figure to insert the plots in
%             'convertDatetimes'  = [boolean]    Convert the dates to integers (default = true)}

[fig, plt] = trendPlot(@linePlot, lotDates, values, varargin);

end