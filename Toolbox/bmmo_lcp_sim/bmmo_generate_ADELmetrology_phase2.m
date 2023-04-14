function mlo = bmmo_generate_ADELmetrology_phase2(wafers_in, wafers_out, adeller, name, machineId, with_noise)
% function adel_out = bmmo_generate_ADELmetrology(wafers_in, wafers_out, adeller)
%
% Generate a valid ADELmetrology for BMMO-NXE given KT_wafers_in/out and a
% valid ADELler
%
% Input (all strings)
%       wafers_in: KT_wafers_in file path from a BMMO lot
%       wafers_out: KT_wafers_out file path from the same lot
%       adeller: ADELler path from the same lot
%       name: unique name identifier of output file
%
%
% 20160331 SBPR creation; modified from tlg2ADELmetrology

% Set default Machine ID if none input
if nargin < 5
    machineId = '1001';
end

if nargin < 6
    with_noise = 0;
end

% seed the random number generator
rng(sum(clock));

% Matching tolerance for mark positions
TOL = 9;

% read adeller to get expinfo (containing only xc, yc field centres)
disp('reading ADELler');
[expinfo, mark_type] = bmmo_expinfo_from_adeller(adeller);

% generate the measurement ml structure(s) from wafers_out, generating a
% template structure from expinfo
disp('reading KT_wafers_out');
phase = 2;
mlo = bmmo_get_meas_data(wafers_out, expinfo, phase, mark_type);

if with_noise
    disp('adding DCO budget noise per wafer');
    mlo = bmmo_add_noise(mlo);
end

% Generate the swid ml structure(s) from wafers_in
disp('reading KT_wafers_in');
[ml_wid_up, ml_wid_down] = bmmo_get_swid_data(wafers_in);


    
% Remove edge for measurement layout & downsample
disp('removing edge and downsampling');
mlo = bmmo_get_meas_layout(mlo);
mlo = bmmo_generate_2l_dyna25_input(mlo);

% % Remove all non-weccable marks from mlo
% disp('verifying WEC marks');
% mlo = bmmo_filter_wec(mlo, TOL);
% 
% disp('verifying REC marks');
% mlo = bmmo_filter_rec_positions(mlo, TOL);

disp('removing layout nans');
mlt = bmmo_remove_layout_nans(mlo);
ml_wid_up = bmmo_remove_layout_nans(ml_wid_up);
ml_wid_down =  bmmo_remove_layout_nans(ml_wid_down);
    
% write the ADELmetrology file
disp('writing ADELmetrology');
bmmo_write_adelmetrology_bmmo_layout(ml_wid_up, ml_wid_down, mlt, name, machineId);
