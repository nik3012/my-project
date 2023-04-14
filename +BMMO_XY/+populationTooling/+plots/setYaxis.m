function setYaxis(figs, side, lowerLimit, upperLimit)
% setYaxis(figs, side, lowerLimit, upperLimit)
% 
% Function to set either the left or right Y-axis and the upper and lower limit of the axis. 
%
% Input arguments:
% - figs        []                Array of the figures
% - side        [char array]      Indicates the location of the verical axes
%                                   ("left", "right", 1 or 2)
% - lowerLimit  [double]          minimum y-axis value
% - upperLimit  [double]          maximum y-axis value
%

if string(side) == "left"
    yAxisIndex = 1;
elseif string(side) == "right"
    yAxisIndex = 2;
elseif (side == 1) || (side == 2)
    yAxisIndex = side;
else
    error('The provided "side" input argument is not correct. Only "left", "right", 1 or 2 is allowed, but %s was provided', string(side));
end

for index = 1 : length(figs)
    if length(figs(index).CurrentAxes.YAxis) < yAxisIndex
        warning('The Y axis selected with "side" does not exist, will not set the limits');
    else
        figs(index).CurrentAxes.YAxis(yAxisIndex).Limits = [lowerLimit, upperLimit];
    end
end

end