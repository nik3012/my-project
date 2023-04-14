function mlo = bmmo_generate_2l_dyna25_input(mli)
% function mlo = bmmo_generate_2l_dyna25_input(mli)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%

options = bmmo_default_options_structure;

if mli.nfield > 89
    options.fid_left_right_edgefield = [17    27    28    39    50    61    62    72  125 136];
    options.dyna_25 = setdiff(88:mli.nfield, options.fid_left_right_edgefield);
end

options.f77 = setdiff(1:87, options.fid_intrafield);
options.f77 = setdiff(options.f77, options.fid_left_right_edgefield);
options.f77 = setdiff(options.f77, options.fid_top_bottom_edgefield);

% 12 inner fields: 13x19
%just leave them

% TB edge fields: 13x7
mlo = bmmo_convert_layout2_7(mli, 'y', options.fid_top_bottom_edgefield);

% LR edge fields: 7x19
mlo = bmmo_convert_layout2_7(mlo,'x', options.fid_left_right_edgefield);

% Rest of layer 1: 7x7
mlo = bmmo_convert_layout2_7(mlo,'x', options.f77);
mlo = bmmo_convert_layout2_7(mlo,'y', options.f77);

% Rest of layer 2: dyna25
if mli.nfield > 89
    mlo = bmmo_convert_dyna25(mlo, options.dyna_25);
end

