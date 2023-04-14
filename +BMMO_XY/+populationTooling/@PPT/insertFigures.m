function insertFigures(obj, slideTitle, slideSubtitle, figures, useRows)
% Generate a slide and insert one or multiple figures. If the variable
% useRows is given together with multiple figures, the figures will be
% plotted in two rows instead of two columns.
if exist('useRows', 'var') && useRows
    toppt(slideTitle, slideSubtitle, figures, length(figures), 'phandle', obj.filehandle, 'rows', 2);
else
    toppt(slideTitle, slideSubtitle, figures, length(figures), 'phandle', obj.filehandle);
end
