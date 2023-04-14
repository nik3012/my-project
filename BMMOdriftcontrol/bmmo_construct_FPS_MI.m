function FP_MI = bmmo_construct_FPS_MI(ml, params, options)
% function FP_MI = bmmo_construct_FPS_MI(ml, params, options)
%
% The function generates the raw MI fingerprint for the combined model
%
% Input:
%  ml: input ml structure
%  params: structure containing the following fields:
%           pitch =  interpolation pitch (m)
%           min =    beginning of interpolation range (m);
%           max =    end of interpolation range (m);
%           nr_seg = number of splines generated;
%           vq =     name of field in which to copy interpolated values
%                       ('dx' or 'dy');
%           xq =     name of field that provides query values ('yw' or
%                       'xc')
%           name =   'MIX' or 'MIY'
%  options: BMMO/BL3 option structure
%
% Output:
%  FP_MI: MI fingerprint (1xN cell array of ml structs}

if isempty(options.Q_grid.x) || isempty(options.Q_grid.y) || (numel(options.Q_grid.x) ~= numel(options.Q_grid.y))
    error('options.Q_grid incomplete or size of x and y mismatch');
end

FP_MI = cell(options.chuck_usage.nr_chuck_used, 12);
for chuck = 1:options.chuck_usage.nr_chuck_used
    dummy = ml;
    this_wafer = find(options.chuck_usage.chuck_id == options.chuck_usage.chuck_id_used(chuck));   
    if params.name == 'MIX'
        dummy = bmmo_apply_curved_slit_correction(dummy, options);
        dummy.wd.yw = dummy.wd.yw + mean(options.FIWA_translation.y(this_wafer));     
    elseif params.name == 'MIY'
        dummy.wd.xc= dummy.wd.xc+ mean(options.FIWA_translation.x(this_wafer));
    end
    
    % x/y mirror, generate splines
    base = bmmo_base_spline([params.min:params.pitch:params.max],params.min,params.max,params.nr_seg, options);
    base = full(base);
    
    for ii = 1:size(base,2)
        ml_tmp = dummy;
        ml_tmp.layer.wr.(params.vq) =  interp1([params.min:params.pitch:params.max],base(:,ii),ml_tmp.wd.(params.xq), 'linear', 'extrap');
        ml_tmp.what = [params.name,num2str(ii)];
        FP_MI{chuck,ii} = ovl_combine_linear(ml_tmp, 1/options.scaling_factor);
    end
end