function figs = waferDataMapPlot(mls, figureTitle, varargin)
% figs = WaferDataMapPlot(mls, figureTitle, varargin)
%
% Function to plot the wafer data map given an array of mls.
%
% Input arguments:
% - mls              [array of structs]      Array of structs containing the MLs of
%                                              the jobs.
% - figureTitle      [char array]            Title of the wdms figures
% 
% Optional arguments:  
% - scale            [double]                Scaling factor 
% - subTitle         [char array]            Subtitle of the wdms figures
% - dates            [cell of datetimes]     Dates associated with the MLs
%
%  Output arguments:           
% - figs             [array of figures]      Array containing figures of the wafer data maps

% Process input arguments
inputArguments = processInputArguments(varargin);

% Determine scale
if inputArguments.scale == 0
    inputArguments.scale = min(round(1.2 * 10^9 * max(arrayfun(@determineMaxOvlValue, mls)), 2), 4);
end

% Check dates
if length(inputArguments.dates) == 1 && string(inputArguments.dates{1}) == ""
    printDates = false;
else
    printDates = true;
end
if printDates && (length(inputArguments.dates) ~= length(mls))
    error('The amount of dates and amount of MLs do not match');
end

% Set the font size
fontSize = 18;

% Loop over all the wafers in all the MLs
index = 0;
for mlIndex = 1 : length(mls)
    for waferIndex = 1 : mls(mlIndex).nwafer
        index = index + 1;
        
        % Create the figure handle
        figs(index) = figure;
        
        % Create the wafer data map plot
        ovl_plot(mls(mlIndex), 'wafer', waferIndex, 'scale', inputArguments.scale, 'vcolor', 'prc', 3, 'fontsize', fontSize, 'legend', 'none');
        ax = gca;
        
        % Move the wafer data map to the left
        subplot(1, 6, 1 : 5, ax);
        
        % Calculate the overlay values and convert to char arrays
        ovlValues = ovl_calc_overlay(ovl_combine_wafers(mls(mlIndex), waferIndex));
        ovlCell   = createOvlCell(ovlValues);
        
        % Insert the overlay values to the bottom right
        anovl = annotation(figs(index), 'textbox', [0 0 1 1], 'String', ovlCell, 'FitBoxToText', 'off');
        anovl.LineStyle           = 'none';
        anovl.FontSize            = fontSize;
        anovl.VerticalAlignment   = 'bottom';
        anovl.HorizontalAlignment = 'right';
        
        % Insert the dates to the top right
        if printDates
            datesCell = createDatesCell(inputArguments.dates{mlIndex});
            andate    = annotation(figs(index), 'textbox', [0 0 1 1], 'String', datesCell, 'FitBoxToText', 'off');
            andate.LineStyle           = 'none';
            andate.FontSize            = fontSize;
            andate.VerticalAlignment   = 'top';
            andate.HorizontalAlignment = 'right';
        end
        
        % Set the title and subtitle
        subTitle = inputArguments.subTitle;
        if length(mls) > 1
            if string(subTitle) ~= ""
                subTitle = [subTitle ' ' num2str(mlIndex)];
            else
                subTitle = ['ml ' num2str(waferIndex)];
            end
        end
        if mls(mlIndex).nwafer > 1
            if string(subTitle) ~= ""
                subTitle = [subTitle ', wafer ' num2str(waferIndex)];
            else
                subTitle = ['Wafer ' num2str(waferIndex)];
            end
        end
        title(figureTitle);
        subtitle(subTitle);
        ax.Subtitle.Visible = 'on';
        
        % Set the properties of the window and font
        figs(index).Position = [50 50 1050 850];
        figs(index).Children(1).FontSize = fontSize;
    end
end

end


function inputArguments = processInputArguments(inargs)

% Create an inputParser object
p = inputParser;

% Define validation functions
validationFunctionText   = @(x) (isstring(x) || ischar(x));
validationFunctionNumber = @(x) isa(x,'double');

% Define the default values
defaultSubTitle = '';
defaultDates    = {''};
defaultScale    = 0;

% Specify input parameters
p.addParameter('subTitle', defaultSubTitle, validationFunctionText);
p.addParameter('dates', defaultDates);
p.addParameter('scale', defaultScale, validationFunctionNumber);

% Check the provided parameters
p.parse(inargs{:});

% Store the results
inputArguments = p.Results;

end


function maxOvl = determineMaxOvlValue(ml)

ovlValues = ovl_calc_overlay(ml);
maxOvl    = max(ovlValues.ox100, ovlValues.oy100);

end


function ovlCell = createOvlCell(ovlValues)

ovlCell = {['   ' '    ' ' ovX ' '    ' ' ovY ' '   '], ...
           '', ...
           ['997' '    ' num2chars(ovlValues.ox997 * 1e9) '   ' num2chars(ovlValues.oy997 * 1e9) '   '], ...
           '', ...
           ['max' '    ' num2chars(ovlValues.ox100 * 1e9) '   ' num2chars(ovlValues.oy100 * 1e9) '   '], ...
           '', ...
           ['m3s' '    ' num2chars(ovlValues.oxm3s * 1e9) '   ' num2chars(ovlValues.oym3s * 1e9) '   '], ...
           '', ...
           ['3sd' '    ' num2chars(ovlValues.ox3sd * 1e9) '   ' num2chars(ovlValues.oy3sd * 1e9) '   '], ...
           '', ...
           '', ...
           ''};

end


function chars = num2chars(num)

chars = num2str(num, '%.3f');
chars = chars(1:5);

end


function datesCell = createDatesCell(date)

datesCell = {'', [datestr(date, 'dd-mmm-yyyy') '   ']};

end