function mark_layout = bmmo_get_mark_layout(layout, options)
%function mark_layout = bmmo_get_mark_layout(layout, options)
%
% This function generates the input 'mark_layout' for the function 
% bmmo_construct_layout/ovl_create_dummy 
%
% Input: 
%  layout: layout type, current cases: '13x19', '7x7' (if neither then 5x5
%          is taken as default
%  options: BMMO/BL3 option structure
%
% Output:
%   mark_layout: vector containing:
%           [Field size; Field size y; nx; ny; model shift x; model shift y] 

if contains(layout, '13x19', 'IgnoreCase', true)
    nx = 13;
    ny = 19;
elseif contains(layout, '7x7', 'IgnoreCase', true)
    nx = 7;
    ny = nx;
else
    nx = 5;
    ny = 5;
end

mark_layout = [12.72*2 16.2180*2 nx ny options.model_shift.x(1, 2)*1e3 options.model_shift.y(1, 2)*1e3];