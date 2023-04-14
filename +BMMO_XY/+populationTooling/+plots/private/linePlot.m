function plt = linePlot(dates, values)
% plt = linePlot(dates, values)
%
% Function that creates a lineplot with the input data taking into account
% the plotting color of previous plots, such that no overlap occurs.
%
% Input arguments:
% - dates           [ array of datetimes ]                  array of datetimes of the plotted values
% - values          [ array of doubles ]                    Array containing the data that will be plotted
% 
% Output arguments: 
% plt               []                                      Plot of the data.
%


% Line plots have their Y axis on the right
yyaxis right;

% Specify the markers and get the colors of the line plot
markers = {'o', '*', 'x', '+', 'square', 'diamond', 'v', ...
           '^', '>', '<', 'pentagram', 'hexagram', '|', '_'};
colors  = getColorList([0.2, 0.2, 0.2]);

% Cycle through the colors
persistent colorIndexOffset;
if isempty(colorIndexOffset)
    colorIndexOffset = 0;
end    

% Create the line plots
for index = 1 : length(values)
    markerIndex = mod((index - 1), 15) + 1;
    colorIndex  = mod((index + colorIndexOffset - 1), length(colors)) + 1;
    marker      = ['-' markers{markerIndex}];
    plt(index)  = plot(dates, values{index}, marker, 'color', colors{colorIndex}, 'linewidth', 1.5);
end

% Store the last value
colorIndexOffset = colorIndex;

end