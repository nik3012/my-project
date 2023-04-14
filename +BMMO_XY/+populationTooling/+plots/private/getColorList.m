function colors = getColorList(rgbOffset, indexOffset)

% Allow offsetting the colors using a provided color triplet
if ~exist('rgbOffset', 'var')
    rgbOffset = [0 0 0];
end

% Allow reshuffling the colors with a provided index offset
if ~exist('indexOffset', 'var')
    indexOffset = -1;
end

% Capture the matlab default colors
C = colororder;

% Apply the offsets
colors = arrayfun(@(x) (min(C(mod(x + indexOffset, length(C)) + 1, :) + rgbOffset, 1)), ...
                  (1 : length(C)), 'UniformOutput', false);

end