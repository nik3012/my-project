function mlo = bmmo_distribute_wafer_results(mli, ldx, results)
% function mlo = bmmo_distribute_wafer_results(mli, ldx, results)
%
% Distribute the results of bmmo_apply_parms across a wafer
%
% Input:
%  mli: overlay structure to copy results
%  ldx: length of dx and dy 
%  results: overlay results, [dx; dy]
% 
% Output:
%  mlo: mli with overaly from results

mlo = mli;

dxout = results(1:ldx, :);
dyout = results(ldx+1:end, :);
    
mlo.layer.wr.dx = dxout(:);
mlo.layer.wr.dy = dyout(:);