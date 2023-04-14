function ka_grid = bmmo_KA_grid(KA_start, KA_pitch)
%function ka_grid = bmmo_KA_grid(KA_start, KA_pitch)
%
% Generates a KA grid based on the starting position and pitch
%
% Input
%   KA_start: starting position of the KA grid
%   KA_pitch: pitch of the KA grid
%
% Output
%   ka_grid: generated KA grid

ka_bound = abs(KA_start);


[ka_grid.x, ka_grid.y] = meshgrid(-ka_bound:KA_pitch:ka_bound, -ka_bound:KA_pitch:ka_bound);
ka_grid.dx = zeros(size(ka_grid.x));
ka_grid.dy = ka_grid.dx;
idx_outer  = (ka_grid.x.^2 + ka_grid.y.^2) > KA_start^2;
ka_grid.dx(idx_outer) = NaN;
ka_grid.dy(idx_outer) = NaN;

ka_grid.interpolant_x = [];
ka_grid.interpolant_y = [];