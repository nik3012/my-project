function ka = bmmo_kt_get_injected_KA( drift_path)
% function ka = bmmo_kt_get_injected_KA
%
% Return the injected KA parameters
%
% Input:    
%           drift_path: path of directory containing drift dd files
%
% Output: ka: ka.grid_2de correction per chuck


kapath = [drift_path filesep 'BMMO_drift_KA.dd'];

kamat = dd2mat(0, kapath);

parmc = ovl_metro_par_mc('KA_pitch',kamat.pitch);

for ic = 1:2
    grid                = parmc.KA.raw.grid_2de(1);
    matrix = kamat.matrix{ic};
    
    grid.dx = reshape(grid.dx, 61, 61);
    grid.dy = reshape(grid.dy, 61, 61);
    
    for ix = 1:length(matrix)
       cols = length(matrix{ix});
       for iy = 1:cols
           if strcmp(matrix{ix}(iy).valid, 'TRUE')              
               grid.dx(ix,iy) = matrix{ix}(iy).offset.x;
               grid.dy(ix,iy) = matrix{ix}(iy).offset.y;
           end
       end
    end
    
    grid.dx = grid.dx(:);
    grid.dy = grid.dy(:);
    ka(ic) = grid;
end