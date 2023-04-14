function mlo = bmmo_generate_ADELmetrology(wafers_in, wafers_out, adeller, name, machineId, with_noise)
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
expinfo = bmmo_expinfo_from_adeller(adeller);

% generate the measurement ml structure(s) from wafers_out, generating a
% template structure from expinfo
disp('reading KT_wafers_out');
mlo = bmmo_get_meas_data(wafers_out, expinfo);

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

% if mlo.nfield is greater than 89, split into two (second element will
% have LS_OV_RINT_NOWEC targets
if mlo.nfield > 89
    l1_fields = [1:87 125 136];
    l2_fields = [88:124 126:135 137:174]; 
    
    mltemp(1) = ovl_get_fields(mlo, l1_fields);
    mltemp(2) = ovl_get_fields(mlo, l2_fields);
    mlo = mltemp;
end
    
% write the ADELmetrology file
disp('writing ADELmetrology');
bmmo_write_adelmetrology(ml_wid_up, ml_wid_down, mlo, name, machineId);
