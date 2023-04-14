function figs = generateFieldFingerPrintGif(ffps, lotDates, figureTitle, filename, filelocation, scale)
% figs = generateFieldFingerPrintGif(ffps, lotDates, figureTitle, filename, filelocation, scale)
%
% This function generates a GIF of a series of fieldfingerprints,
% by creating figures of the ffps and placing them in a Gif. This function
% is particularly useful for observing the changes of the ffps over time.
%
% Input arguments:
% - ffps        [ array of struct ]           Structs containing the ffps of
%                                             the different jobs
% - lotDates    [ array of datetimes ]        Dates of the jobs
% - figureTitle [ char array ]                Title of the figures and thereby the Gif
% - filename    [ char array ]                Name under which the Gif will
%                                             be saved
% - filelocation[ char array ]                Directory where the Gif will be
%                                             saved
% - scale       [ double ]                    Relative size of the Gif image
%
% Output arguments:
% - figs        [ array of figures ]           Array containing the generated ffps that make up the the Gif
%

import BMMO_XY.populationTooling.plots.fieldFingerPrintPlot
import BMMO_XY.populationTooling.animations.figsToGif


% Generate figs of the fingerprints
if exist('scale', 'var')
    figs = fieldFingerPrintPlot(ffps, figureTitle, scale);
else
    figs = fieldFingerPrintPlot(ffps, figureTitle);
end

% Add the dates to the figure titles
for index = 1 : length(figs)
    figs(index).CurrentAxes.Subtitle.Visible = 'on';
    figs(index).CurrentAxes.Subtitle.String  = datestr(lotDates(index));
end

% Generate the GIF
figsToGif(figs, filename, filelocation);

end
