function [fig, plt] = trendPlot(plotType, dates, values, varargin)
% [fig, plt] = trendPlot(plotType, dates, values, varargin)
%
% Function that creates a trendplot with the input data taking into account
% the plotting color of previous plots, such that no overlap occurs.
%
% Input arguments:
% - plotType        []                                                  
% - dates           [ array of datetimes ]     Array of datetimes of the plotted values
% - values          [ array of doubles ]       Array containing the data that will be plotted.
% 
% Optional arguments:
% - varargin                                                
%
% Output arguments: 
% - fig               []                       Figure containing the trendplot
% - plt               []                       Plot of the data.
%
%NOTE: Add information on the varargin and plotType.

% Process input arguments
[inputArguments, usingDefaults] = processInputArguments(values, varargin{:});

% Make the provided figure the current figure
fig = inputArguments.useFigure;
figure(fig);

% Manipulate the dates to show a linear plot
if inputArguments.convertDatetimes
    convertedDates = 1 : length(dates);
else
    convertedDates = dates;
end

% Create the elements in the figure object       
hold on;
plt = feval(plotType, convertedDates, inputArguments.values);
hold off;

% Only set these values if no previous figure was provided
if any(ismember(usingDefaults, 'useFigure'))
    % Modify the X axis
    fig.CurrentAxes.XAxis.TickValues   = convertedDates;    
    fig.CurrentAxes.XAxis.TickLabels   = datestr(dates, 'dd-mmm-yyyy');
    fig.CurrentAxes.XTickLabelRotation = 45;
    
    % Remove the surplus of X labels
    numberOfXLabels = length(convertedDates);
    if (numberOfXLabels / 20) > 2
        blankXLabelIndex = not(ismember(1 : numberOfXLabels, round(linspace(1, numberOfXLabels, 20))));
        fig.CurrentAxes.XAxis.TickLabels(blankXLabelIndex, :) = repmat(' ', sum(blankXLabelIndex), 11);        
    end
    
    % Modify the figure size
    fig.Position = [50 50 1850 450];
    
    % Enable the grid
    fig.CurrentAxes.YGrid = 'on';
    fig.CurrentAxes.XGrid = 'on';
end

% Set the title if it has been provided
if ~any(ismember(usingDefaults, 'figureTitle'))
    title(inputArguments.figureTitle);
end

% Set the Y axis label if it has been provided
if ~any(ismember(usingDefaults, 'figureUnit'))
    ylabel(inputArguments.figureUnit);
end

% Set the color of the Y Axis
fig.CurrentAxes.YColor = [0 0 0];

% Prepare legend manipulation
legend;
legend('hide');

% Only set these values if lables for the legend were provided
if ~any(ismember(usingDefaults, 'valuesDescription'))
    % Set the posistion of the legend
    fig.CurrentAxes.Legend.Location = 'eastoutside';
    
    % Find the empty labels of the legend
    firstMatch = find(ismember(fig.CurrentAxes.Legend.String,'data1'));
    index      = firstMatch : (firstMatch + length(inputArguments.valuesDescription) - 1);
    
    % Set the empty labels of the legend
    fig.CurrentAxes.Legend.String(index) = inputArguments.valuesDescription;
else
    for index = 1 : length(plt)
        plt(index).Annotation.LegendInformation.IconDisplayStyle = 'off';
    end
end
legend('show');

end


function [inputArguments, usingDefaults] = processInputArguments(values, inargs)

% Create an inputParser object
p = inputParser;

% Define validation functions
validationFunctionText         = @(x) (isstring(x) || ischar(x));
validationFunctionCellText     = @(x) (all(cellfun(validationFunctionText, x)));
validationFunctionFigureHandle = @(x) (string(class(x)) == "matlab.ui.Figure");
validationFunctionBoolean      = @(x) (length(x) == 1 || islogical(x));

% Define the default values
defaultTitle       = 'Title';
defaultUnit        = 'Unit';
defaultDescription = cell(size(values));
defaultFigure      = figure;
defaultConvert     = true;

% Fill defaultDescription
for index = 1 : length(defaultDescription)
    defaultDescription{index} = 'Description';
end

% Specify input parameters
p.addParameter('valuesDescription', defaultDescription, validationFunctionCellText);
p.addParameter('figureTitle', defaultTitle, validationFunctionText);
p.addParameter('figureUnit', defaultUnit, validationFunctionText);
p.addParameter('useFigure', defaultFigure, validationFunctionFigureHandle);
p.addParameter('convertDatetimes', defaultConvert, validationFunctionBoolean);

% Check the provided parameters
p.parse(inargs{:});

% Store the results
inputArguments        = p.Results;
inputArguments.values = values;
usingDefaults         = p.UsingDefaults;

% Check if defaultFigure needs to be closed
if inputArguments.useFigure ~= defaultFigure
    close(defaultFigure);
end

end