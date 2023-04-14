function plt = barPlot(dates, values)
% plt = barPlot(dates, values)
%
% Function that creates a barplot with the input data taking into account
% the plotting color of previous plots, such that no overlap occurs.
%
% Input arguments:
% - dates           [ array of datetimes ]                  array of datetimes of the plotted values
% - values          [ array of doubles ]                    Array containing the data that will be plotted
% 
% Output arguments: 
% plt               []                                      Plot of the data.
%


% Bar plots have their Y axis on the left
yyaxis left;

% Bar plots require a matrix to plot multiple bars per X axis element
numberOfNumericValues = length(values{1});
numberOfValueElements = length(values);
valuesStacked         = reshape([values{:}],[numberOfNumericValues, numberOfValueElements]);

% Create the bar plot
plt = bar(dates, valuesStacked);

% Get a list of colors
colors = getColorList;

% Cycle through the colors
persistent colorIndexOffset;
if isempty(colorIndexOffset)
    colorIndexOffset = 0;
end    

% Apply the colors to the bars
for index = 1 : numberOfValueElements
    colorIndex           = mod((index + colorIndexOffset - 1), length(colors)) + 1;
    plt(index).FaceColor = colors{colorIndex};
end

% Store the last value
colorIndexOffset = colorIndex;

end