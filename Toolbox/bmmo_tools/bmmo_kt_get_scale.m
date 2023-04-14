function scale = bmmo_kt_get_scale(ml1, ml2, options)
% function scale = bmmo_kt_get_scale(ml1, ml2, options)
%
% Given two ml structures, find a useful upper bound for the plotting scale
%
% 20160503 SBPR Creation

for ic = options.chuck_usage.chuck_id_used
   ovr1 = ovl_calc_overlay(ml1(ic));
   ovr2 = ovl_calc_overlay(ml2(ic));
   
   highx = 1e9 * max(abs([ovr1.ox997, ovr2.ox997]));
   highy = 1e9 * max(abs([ovr1.oy997, ovr2.oy997]));
   
   highd = sqrt(highx^2 + highy^2);
   
   scale(ic) = floor(highd);
   
end

scale = max(scale);

if scale == 0
    scale = 0.5;
end