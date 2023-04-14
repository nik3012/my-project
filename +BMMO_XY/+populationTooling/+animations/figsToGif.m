function M = figsToGif(figs, filename, filelocation, timeBetweenFigs)
% M = figsToGif(figs, filename, filelocation, timeBetweenFigs)
% 
% Function that takes a series of figs, creates a Gif from these figs and saves
% the Gif in a specified location. The cycletime of the Gif may be altered. 
%
% Input Arguments:
% - figs            [ array of figures ]    Array containing the figs that
%                                             will be placed in the Gif
% - filename        [ char array ]          Name under which the Gif will
%                                             be saved
% Optional:
% - filelocation       [ char array ]      Directory where the Gif will be
%                                            saved. If no input is given the current directory is used.
% - timeBetweenFigs    [double]            Time between frames in the Gif
%                                            in seconds. If no input is given the value is set to 1.
%
% Output:
% - M                   [ ]                Array containing the movie frames of the Gif
%
%

import BMMO_XY.populationTooling.tools.files.stripFileExt

% Input arguments processing
if ~exist('filelocation', 'var')
    filelocation = pwd;
end

if ~exist('timeBetweenFigs', 'var')
    timeBetweenFigs = 1;
end

% Define the file
file = [strip(filelocation, 'right', filesep) ...
        filesep ...
        stripFileExt(filename) ...
        '.gif'];

% See if the file already exists
if exist(file, 'file') == 2
    append = true;
else
    append = false;
end

% Create the GIF file
nImages = length(figs);
for index = 1 : nImages
    M(index) = getframe(figs(index));
    im       = frame2im(M(index));
    [A, map] = rgb2ind(im, 256);
    if index == 1 && ~append
        imwrite(A, map, file, 'gif', 'LoopCount', Inf, 'DelayTime', timeBetweenFigs);
    else
        imwrite(A, map, file, 'gif', 'WriteMode', 'append', 'DelayTime', timeBetweenFigs);
    end
end
    
end