var sourceData788 = {"FileContents":["function colors = getColorList(rgbOffset, indexOffset)\r","\r","% Allow offsetting the colors using a provided color triplet\r","if ~exist('rgbOffset', 'var')\r","    rgbOffset = [0 0 0];\r","end\r","\r","% Allow reshuffling the colors with a provided index offset\r","if ~exist('indexOffset', 'var')\r","    indexOffset = -1;\r","end\r","\r","% Capture the matlab default colors\r","C = colororder;\r","\r","% Apply the offsets\r","colors = arrayfun(@(x) (min(C(mod(x + indexOffset, length(C)) + 1, :) + rgbOffset, 1)), ...\r","                  (1 : length(C)), 'UniformOutput', false);\r","\r","end"],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[4,5,9,10,14,17,18],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}