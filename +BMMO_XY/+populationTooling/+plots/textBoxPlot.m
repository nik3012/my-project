function [fig, an] = textBoxPlot(varargin)
%  Function to create a legend for plots.
fig = figure;
fig.Position = [50 50 1050 950];

an = annotation(fig, 'textbox', [0 0 1 1], 'String', varargin, 'FitBoxToText', 'off');
an.LineStyle = 'none';
an.FontSize = 26;
an.VerticalAlignment = 'middle';
end