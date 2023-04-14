function figs = fieldFingerPrintPlot(mls, figureTitle, scale)
% figs = fieldFingerPrintPlot(mls, figureTitle, scale)
%
% Function to plot the fieldfingerprints given an array of mls.
%
% Input arguments:
% - mls              [array of structs]      Array of structs containing the mls of
%                                              the jobs.
% - figureTitle      [char array]            Title of the ffps figures
% 
% Optional arguments:  
% - scale            [double]                Scaling factor (in [m] if smaller than 0.001,
%                                              in [nm] otherwise; 10nm is default);             
%
%  Output arguments:           
% - figs             [ array of figures ]    Array containing figures of the field fingerprints

% Determine scale
if ~exist('scale', 'var')
    scale = round(1.2 * 10^9 * max(arrayfun(@determineMaxOvlValue, mls)), 2);
end

index = 0;
for mlIndex = 1 : length(mls)
    for waferIndex = 1 : mls(mlIndex).nwafer
        index = index + 1;
        figs(index) = figure;
        ovl_plot(mls(mlIndex), 'field', 'wafer', waferIndex, 'scale', scale, 'pcolor', 'prc', 3, 'fontsize', 12);
        title([figureTitle ' : wafer ' num2str(waferIndex)]);
        figs(index).Position = [50 50 1050 950];
        figs(index).Children(1).FontSize = 12;
        figs(index).Children(2).FontSize = 14;
    end    
end

end


function maxOvl = determineMaxOvlValue(ml)

ovlValues = ovl_calc_overlay(ml);
maxOvl    = max(ovlValues.ox100, ovlValues.oy100);

end
