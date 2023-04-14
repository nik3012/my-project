function pi_struct = bmmo_get_ov_pi_per_chuck_average(ml, options, pi_struct)
% function pi_struct = bmmo_get_ov_pi_per_chuck_average(ml, options, pi_struct)
%
% Create a per-chuck overlay performance indicator struct for the given input
% using chuck average
%
% Input
%   ml: overlay structure
%
% Optional input:
%   options: BMMO/BL3 options structure 
%   pi_struct: any structure (new (K)PI fields will be added)
%
% Output
%   pi_struct: overlay performance indicator structure

if nargin < 2
    options = bmmo_default_options_structure;
end


for ic = options.chuck_usage.chuck_id_used
    chuckstr = num2str(ic);
    wafers_this_chuck = find(options.chuck_usage.chuck_id == ic);
    
    ov_chuck = ovl_calc_overlay(bmmo_average(ovl_get_wafers(ml, wafers_this_chuck)));
    pi_struct.(['ovl_chk' chuckstr '_997_x']) = ov_chuck.ox997;
    pi_struct.(['ovl_chk' chuckstr '_997_y']) = ov_chuck.oy997;
    pi_struct.(['ovl_chk' chuckstr '_max_x'])  = ov_chuck.ox100;
    pi_struct.(['ovl_chk' chuckstr '_max_y'])  = ov_chuck.oy100;
    pi_struct.(['ovl_chk' chuckstr '_m3s_x'])  = ov_chuck.oxm3s;
    pi_struct.(['ovl_chk' chuckstr '_m3s_y'])  = ov_chuck.oym3s;
    pi_struct.(['ovl_chk' chuckstr '_3std_x']) = ov_chuck.ox3sd;
    pi_struct.(['ovl_chk' chuckstr '_3std_y']) = ov_chuck.oy3sd;
end