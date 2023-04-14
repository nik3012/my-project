function [input_out, prev_corr] = bmmo_undo_corr_from_input(input_struct)
% function input_out = bmmo_undo_corr_from_input(input_struct)
%
% Undo previous correction from BMMO-NXE input, preserving the smf layout
%
% Input:
%   input_struct: valid BMMO-NXE input structure
%
% Output:
%   input_out: input with previous SBC correction removed, same layout
% 2020-07-10 SELR update to add neutralization of previous correction and
%            add previous correction as second output
N_GRID_POINTS_BMMO = 3721;

prev_corr = input_struct.info.previous_correction;

if length(prev_corr.KA.grid_2de(1).x) > N_GRID_POINTS_BMMO
    options = bl3_default_options_structure;
else
    options = bmmo_default_options_structure;
end

mlc = bmmo_undo_prev_sbc(input_struct);
input_out = bmmo_map_to_smf(mlc, input_struct);

dummy = bmmo_default_output_structure(options);

if isfield(dummy.corr, 'Configurations')
    corr = rmfield(dummy.corr, 'Configurations');
else
    corr = dummy.corr;
end
input_out.info.previous_correction = corr;