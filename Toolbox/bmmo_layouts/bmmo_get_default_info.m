function info = bmmo_get_default_info(mli, reticle_layout)
% function info = bmmo_get_default_info(mli)
%
% Return a default info structure for BMMO-NXE, with alternating chucks
%   per wafer, beginning with chuck 1
%
% Input 
%   mli: any valid ovl ml structure
%   reticle_layout: one of the supported layouts from ovl_create_dummy
%
% Output:
%   info: info structure as defined in EDS D000323756
%
% 20160602 SBPR Creation

info.report_data = sub_get_report_data(mli);

info.previous_correction = sub_get_previous_correction(reticle_layout);

info.F = sub_get_info_f(mli);

info.M = sub_get_info_m(mli);


function report_data = sub_get_report_data(mli)

report_data.FIWA_translation.x = zeros(1, mli.nwafer);
report_data.FIWA_translation.y = zeros(1, mli.nwafer);

report_data.FIWA_mark_type = 'XPA';
report_data.IR2EUVsensitivity = 1;
report_data.Rir2euv = 0.625;
report_data.time_filtering_enabled = 0;
report_data.Scan_direction = ones(mli.nfield, 1);
report_data.Scan_direction(2:2:end) = -1;

kfield = struct('K1', 0, 'K2', 0, 'ms', 0, 'ma', 0, 'rs', 0, 'ra', 0, 'K7', 0, ...
    'K8', 0, 'K9', 0, 'K10', 0, 'K11', 0, 'K12', 0, 'K14', 0, 'K15', 0, 'K16', 0, ...
    'K17', 0, 'K18', 0, 'K19', 0);

kwafer.field = repmat(kfield, mli.nfield, 1);
report_data.WH_K_factors.wafer = repmat(kwafer, mli.nwafer, 1);

report_data.r = 0.5;
report_data.t = 1;
report_data.Pdgl = 1;
report_data.SLIP = 1;
report_data.Tret = 0.04;

report_data.T_previous_expose = 0;
report_data.T_current_expose = 1;

function prev = sub_get_previous_correction(reticle_layout)

options = bmmo_default_options_structure;
options.intrafield_reticle_layout = reticle_layout;
options.KA_pitch = 0.0050;

prev = bmmo_default_output_structure(options);
prev = prev.corr;

function f = sub_get_info_f(mli)

f.machine_type = 'NXE3400C';
f.machine_id = '1234';
f.chuck_id = {'CHUCK_ID_1', 'CHUCK_ID_2', 'CHUCK_ID_1', 'CHUCK_ID_2', 'CHUCK_ID_1', 'CHUCK_ID_2', 'CHUCK_ID_1', 'CHUCK_ID_2'};
f.chuck_id = f.chuck_id(1:mli.nwafer);
f.wafer_accepted = ones(1, mli.nwafer);
f.exp_energy = 8;
f.layer_id = 'expose';
f.chuck_operation = 'USE_BOTH_CHUCK';
f.recipe = 'recipe_id';
f.image_size.x = 0.026;
f.image_size.y = 0.033;


function m = sub_get_info_m(mli)

m.machine_type = 'Yieldstar';
m.machine_id = '1234';
m.nwafer = mli.nwafer;
m.nfield = mli.nfield;



