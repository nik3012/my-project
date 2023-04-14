function [resinter, resbao, resintra] = bmmo_get_res_breakdown(model_residual, options)
% function [resinter, resbao, resintra] = bmmo_get_res_breakdown(model_residual, options)
%
% Get the interfield, intrafield and BAO KPI breakdown of input residual
%
% Input:
%   model_residual: ml structure
%   options: BMMO/BL3 options structure
%
% Output:
%   resinter: interfield residual KPI
%   resbao: BAO residual KPI
%   resintra: interfield residual KPI

for chuck_id = options.chuck_usage.chuck_id_used
    
    wafers_chuck = find(options.chuck_usage.chuck_id == chuck_id);
    chuck_string = num2str(chuck_id);
    
    res_chuck(chuck_id) = ovl_get_wafers(model_residual, wafers_chuck);
    
    [~, pars] = ovl_model(bmmo_get_layout(res_chuck(chuck_id), options.reduced_reticle_layout, options));
    
    bao_res(chuck_id) = ovl_model(res_chuck(chuck_id), 'apply', pars, -1);
    
    intraf_total(chuck_id) = ovl_average_fields(ovl_average(ovl_get_fields(bao_res(chuck_id), options.fid_intrafield)));
    intraf_res(chuck_id) = ovl_sub_field(bao_res(chuck_id), intraf_total(chuck_id));
    
    [grid_res(chuck_id), xmirror_res(chuck_id), ymirror_res(chuck_id)] = ovl_model_mirrors(intraf_res(chuck_id),'scanner');
    overlay_this_chuck = ovl_calc_overlay(grid_res(chuck_id));
    
    resinter.(['ovl_grid_chk' chuck_string '_res_997_x'])      = overlay_this_chuck.ox997;
    resinter.(['ovl_grid_chk' chuck_string '_res_997_y'])      = overlay_this_chuck.oy997;
    resinter.(['ovl_exp_ytx_max_wafer_chk' chuck_string])  = max(abs(xmirror_res(chuck_id).dx));
    resinter.(['ovl_exp_xty_max_wafer_chk' chuck_string])  = max(abs(ymirror_res(chuck_id).dy));
end

resbao = [];
resintra = []; % to be added in KPI3/4 update
