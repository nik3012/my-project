function [ml_system_nce] = bmmo_calculate_system_nce(inline_sdm_residual, options)
%function [ml_system_nce] = bmmo_calculate_system_nce(inline_sdm_residual, options) 
%
% Calculates the system nce from the inline sdm residual
%
% input: 
%   inline_sdm_residual: 1x2 inline sdm residual from input_struct
%   options :            options structure
%   
% output: 
%   system_nce:         system_nce in ml struct interpolated to RINT

system_nce = inline_sdm_residual;

[~, ~, index_out] = bmmo_fix_nd_grid(inline_sdm_residual(1).x, inline_sdm_residual(1).y);

%average of two chucks
[~, dim] = min(size(inline_sdm_residual(1).dx));
dx_mean = mean([inline_sdm_residual(1).dx, inline_sdm_residual(2).dx], dim);
dy_mean = mean([inline_sdm_residual(1).dy, inline_sdm_residual(2).dy], dim);

% rearrange to ndgrid format 
dxg_mean = dx_mean(index_out);
dyg_mean = dy_mean(index_out);

for ic = 1:length(inline_sdm_residual)
    dxg = inline_sdm_residual(ic).dx(index_out);
    dyg = inline_sdm_residual(ic).dy(index_out);
    % system nce = total nce - lens nce, where lens nce is the average
    % column
    system_nce(ic).dx = reshape(dxg - mean(dxg_mean, 2), [], 1);
    system_nce(ic).dy = reshape(dyg - mean(dyg_mean, 2), [], 1);
    system_nce(ic).dx = system_nce(ic).dx(index_out(:));
    system_nce(ic).dy = system_nce(ic).dy(index_out(:));
end

ml_system_nce_in = bmmo_ffp_to_ml_simple(system_nce); % FFP to ml

% Intrafield NCE interpolation to RINT per chuck
for ic = 1: ml_system_nce_in.nwafer
    ml_system_nce(ic)   = bmmo_correct_intrafield_shift(ovl_get_wafers(ml_system_nce_in, ic), options);
end 

