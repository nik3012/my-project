function [found, reticle_layout, x_shift, y_shift] = bmmo_guess_reticle_layout(mli)
% function [found, reticle_layout, x_shift, y_shift] = bmmo_guess_reticle_layout(mli)
%
% Guess the reticle layout of the input overlay structure by comparing with
% supported layouts in ovl_create_dummy
%
% The supported layouts are
% '13X19', '13X7', '25', '5X7', '7X7', '14X21', '12X18', '7X19', 'S-5', '25-SMALL', ...
% '83', '5-SMALL', 'S-4X4', '13X10', ...
% 'BA-XY-SGV'                'BA-XY-SGV-FF'            'BA-XY-SGV-FF-ALL', ...
%    'BA-XY-SGV-4'              'BA-XY-STAT-13X1'         'BA-XY-STAT-13X3', ...
%    'BA-XY-STAT-13X3_WIDE'     'BA-XY-STAT-13X7'         'BA-XY-STAT-46', ...
%    'XY49-SLT-5X5'             'BA-XY-NARROW-7X19'       'BA-SUSD-FULL'
%
% If the layout is not found, a layout based on the xf.yf values of the
% input will be used.
%
% Input: 
%   mli: overlay structure
%
% Output
%   found: boolean flag to indicate if supported layout is found
%   reticle_layout: reticle_layout value compatible with ovl_create_dummy
%       input
%   x_shift: x field shift from origin, assuming symmetric layout, in
%       metres
%   y_shift: y field shift from origin, assuming symmetric layout, in
%       metres
%
% 20170519 SBPR Added documentation
    

ml_field = ovl_get_fields(ovl_get_wafers(ovl_get_layers(mli, 1),1),1);

% layouts taken from ovl_create_dummy_definition
supported_layouts = {'13X19', '13X7', '25', '5X7', '7X7', '14X21', '12X18', '7X19', 'S-5', '25-SMALL', ...
'83', '5-SMALL', 'S-4X4', '13X10', ...
'BA-XY-SGV'                'BA-XY-SGV-FF'            'BA-XY-SGV-FF-ALL', ...
   'BA-XY-SGV-4'              'BA-XY-STAT-13X1'         'BA-XY-STAT-13X3', ...
   'BA-XY-STAT-13X3_WIDE'     'BA-XY-STAT-13X7'         'BA-XY-STAT-46', ...
   'XY49-SLT-5X5'             'BA-XY-NARROW-7X19'       'BA-SUSD-FULL' };  


reticle_layout = '';
found = 0;
i_layout = 1;
mlo = mli;

[x_shift, y_shift] = sub_find_shift_layout(ml_field);

while(~found && i_layout <= length(supported_layouts)) 
    dummy_field = ovl_get_fields(ovl_create_dummy('marklayout', supported_layouts{i_layout}, 'nwafer', 1, 'nlayer', 1),1);
    
    found = sub_map_field_layouts(ml_field, dummy_field, x_shift, y_shift);
    
    if(found)
        reticle_layout = supported_layouts{i_layout};        
    end
    i_layout = i_layout + 1;
end

if ~found
    warning('layout not found in supported layouts within tolerance level 12: using basic layout');
    reticle_layout = [ml_field.wd.xf ml_field.wd.yf] * 1e3; % convert to mm for ovl_create_dummy
    x_shift = 0;
    y_shift = 0;
    found = 1;
end


function [x_shift, y_shift] = sub_find_shift_layout(ml_field)

x_shift = mean(ml_field.wd.xf);
y_shift = mean(ml_field.wd.yf);

function [found, sortid] = sub_map_field_layouts(ml_field, dummy_field, x_shift, y_shift)

TOL = 12;

xf_shifted = ml_field.wd.xf - x_shift;
yf_shifted = ml_field.wd.yf - y_shift;

xfyf = [xf_shifted yf_shifted];

xfdyfd = [dummy_field.wd.xf, dummy_field.wd.yf];

[test_membership, sortid] = ismember(round(xfyf,TOL), round(xfdyfd, TOL), 'rows');
test_reverse = ismember(round(xfdyfd,TOL), round(xfyf, TOL), 'rows');

found = all(test_membership) & all(test_reverse);


