var sourceData21 = {"FileContents":["function ka_grid = bmmo_KA_grid(KA_start, KA_pitch)\r","%function ka_grid = bmmo_KA_grid(KA_start, KA_pitch)\r","%\r","% Generates a KA grid based on the starting position and pitch\r","%\r","% Input\r","%   KA_start: starting position of the KA grid\r","%   KA_pitch: pitch of the KA grid\r","%\r","% Output\r","%   ka_grid: generated KA grid\r","\r","ka_bound = abs(KA_start);\r","\r","\r","[ka_grid.x, ka_grid.y] = meshgrid(-ka_bound:KA_pitch:ka_bound, -ka_bound:KA_pitch:ka_bound);\r","ka_grid.dx = zeros(size(ka_grid.x));\r","ka_grid.dy = ka_grid.dx;\r","idx_outer  = (ka_grid.x.^2 + ka_grid.y.^2) > KA_start^2;\r","ka_grid.dx(idx_outer) = NaN;\r","ka_grid.dy(idx_outer) = NaN;\r","\r","ka_grid.interpolant_x = [];\r","ka_grid.interpolant_y = [];"],"CoverageData":{"CoveredLineNumbers":[13,16,17,18,19,20,21,23,24],"UnhitLineNumbers":[],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,270,0,0,270,270,270,270,270,270,0,270,270]}}