function inCell = scaleCellArray(inCell, scale)
% Function to scale a cell array with a factor 'scale'
inCell = cellfun(@(x) scale * x, inCell, 'UniformOutput', false);

end