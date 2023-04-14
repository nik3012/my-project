function mi = bmmo_kt_get_injected_MI( driftpath)
% function mi = bmmo_kt_get_injected_MI
%
% Return the injected MI parameters
%
% Input:    
%           drift_path: path of directory containing drift dd files
%
% Output: mi: mi.wse(chuck).x_mirr correction per chuck


mi_ymirr_path{1} = [driftpath filesep 'BMMO_drift_MI_c1_xty.dd'];
mi_xmirr_path{1} = [driftpath filesep 'BMMO_drift_MI_c1_ytx.dd'];
mi_ymirr_path{2} = [driftpath filesep 'BMMO_drift_MI_c2_xty.dd'];
mi_xmirr_path{2} = [driftpath filesep 'BMMO_drift_MI_c2_ytx.dd'];

for ic = 1:2
    mixmat = dd2mat(0, mi_xmirr_path{ic});

    x_mirr.y = (mixmat.deltaX * (0:(mixmat.nx-1))) + mixmat.X0;
    x_mirr.y = x_mirr.y';
    x_mirr.dx = mixmat.YTX * -1; % Mirror MCs have negative sign
    
    miymat = dd2mat(0, mi_ymirr_path{ic});
    
    y_mirr.x = (miymat.deltaX * (0:(miymat.nx-1))) + miymat.X0;
    y_mirr.x = y_mirr.x';
    y_mirr.dy = miymat.XTY * -1;


    mi.wse(ic).x_mirr = x_mirr;
    mi.wse(ic).y_mirr = y_mirr;
    mi.wsm(ic).x_mirr = x_mirr;
    mi.wsm(ic).y_mirr = y_mirr;
end


