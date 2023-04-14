function mlt = bmmo_generate_ADELmetrology_simple(wafers_out, adeller, name, with_noise)
% function adel_out = bmmo_generate_ADELmetrology_simple(wafers_out, adeller, name, with_noise)
%
% Generate a valid ADELmetrology for BMMO-NXE given KT_wafers_in/out and a
% valid ADELler
%
% Input (all strings)
%       wafers_out: KT_wafers_out file path from monitor lot
%       adeller: ADELler path from the same lot
%
% Optional input
%       name: unique name identifier of output file 
%       with_noise: add DCO budget noise before writing ADEL
%
% Output:
%       mlt: overlay structure in SMF format
%
% 20160331 SBPR creation; modified from tlg2ADELmetrology

% Set default YS Machine ID 
machineId = '1001';


if nargin < 3
    name = ['test_', datestr(now, 'hhMMss')];
end

if nargin < 4
    with_noise = 0; 
end

% seed the random number generator
rng(sum(clock));

% read adeller to get expinfo (containing only xc, yc field centres)
disp('reading ADELler');
[expinfo, mark_type] = bmmo_expinfo_from_adeller(adeller);

% generate the measurement ml structure(s) from wafers_out, generating a
% template structure from expinfo
disp('reading KT_wafers_out');
phase = 2;
[mlo, kt_struct] = bmmo_get_meas_data(wafers_out, expinfo, phase, mark_type);

% Generate the swid ml structure(s) from wafers_out
disp('reading WIDs from KT_wafers_out');
[ml_wid_up, ml_wid_down] = bmmo_get_swid_data(wafers_out, kt_struct);
    
% Remove edge for measurement layout & downsample
disp('removing edge and downsampling');
mlo = bmmo_get_meas_layout(mlo);
mlo = bmmo_generate_2l_dyna25_input(mlo);

if with_noise
    disp('adding DCO budget noise per wafer');
    mlo = bmmo_add_noise(mlo);
end

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

% convert to proper SMF ml
mlt.nfield = length(mlt.layer.wr(1).dx);
mlt.nmark = 1;

end