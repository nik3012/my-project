function output_struct = bl3_fix_previous_correction_KA_HOC_zeros(input_struct)
%function output_struct = bl3_fix_previous_correction_KA_HOC_zeros(input_struct)
%
% This function inserts zeros in the KA map of the previous correction.
% It is only required when running BL3 model using BMMO NXE data. The new
% (zero) grid will be of high density with 1mm pitch.
%
% Input :
%  input_struct: input data structure 
%                     
% Output:
%  output_struct: copy of input_struct with zeroed KA@E map in 401 x 401
%  and zeroed KA@M map in 301 x 301

output_struct = input_struct;

KA_HOC_options = bl3_default_options_structure;
parmc = ovl_metro_par_mc('KA_pitch', KA_HOC_options.KA_pitch, 'KA_bound', ...
    abs(KA_HOC_options.KA_start), 'KA_radius', abs(KA_HOC_options.KA_start));
parmc_meas = ovl_metro_par_mc('KA_pitch', KA_HOC_options.KA_pitch, 'KA_bound', ...
    abs(KA_HOC_options.KA_meas_start), 'KA_radius', abs(KA_HOC_options.KA_meas_start));

for ichk = 1:2
    parmc.KA.raw.grid_2de(ichk).dx = zeros(size(parmc.KA.raw.grid_2de(ichk).dx));
    parmc.KA.raw.grid_2de(ichk).dy = zeros(size(parmc.KA.raw.grid_2de(ichk).dy));
    parmc_meas.KA.raw.grid_2dc(ichk).dx = zeros(size(parmc_meas.KA.raw.grid_2dc(ichk).dx));
    parmc_meas.KA.raw.grid_2dc(ichk).dy = zeros(size(parmc_meas.KA.raw.grid_2dc(ichk).dy));
end
output_struct.info.previous_correction.KA.grid_2de =  parmc.KA.raw.grid_2de;
output_struct.info.previous_correction.KA.grid_2dc =  parmc_meas.KA.raw.grid_2dc;
