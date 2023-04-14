function field_struct = bmmo_expected_fields
% function field_struct = bmmo_expected_fields
%
% The function returns the expected field names of the input ml structure, 
% as defined in D000323756-05-EDS-001 (OTAS EDS). This function is used
% by bmmo_validate_input to retrieve the list of defined field names
%
% Output:
%  field_struct: structure with expected fieldnames


%% Define the field_struct.expected fieldnames
field_struct.expected_ml_fieldnames  =  sort({'wd'    'layer'    'nwafer'    'nlayer'    'nfield'    'nmark'    'tlgname'    'expinfo'    'info'});

% define the field_struct.expected fielnames in the wd substructure
field_struct.expected_wd_fieldnames =  sort({'xc' 'yc' 'xf' 'yf' 'xw' 'yw'});

% define the field_struct.expected fieldnames in the layer substructure
field_struct.expected_layer_fieldnames = {'wr'};

% define the field_struct.expected fieldnames in the info substructure
field_struct.expected_info_fieldnames =  sort({'report_data' 'previous_correction' 'F' 'M'});

field_struct.expected_report_data_fieldnames =  sort({'FIWA_translation' 'Scan_direction' 'WH_K_factors' 'Rir2euv'}); 

field_struct.expected_pc_fieldnames =  sort({'KA' 'MI' 'IR2EUV' 'BAO' 'ffp' 'SUSD'});

field_struct.expected_SUSD_fieldnames = sort({'TranslationX', 'TranslationY', 'Magnification', 'AsymMagnification',...
                        'Rotation', 'AsymRotation'});

field_struct.expected_KA_E_fieldnames = sort({'grid_2de'});
field_struct.expected_KA_fieldnames = sort({'grid_2de' 'grid_2dc'});
field_struct.expected_ffp_fieldnames = sort({'x' 'y' 'dx' 'dy'}); % same for KA.grid.2de

field_struct.expected_MI_fieldnames = sort({'wse' 'wsm'});
field_struct.expected_MI_wse_fieldnames = sort({'x_mirr' 'y_mirr'});
field_struct.expected_MI_x_mirr_fieldnames = sort({'y' 'dx'});
field_struct.expected_MI_y_mirr_fieldnames = sort({'x' 'dy'});

field_struct.expected_BAO_fieldnames = sort({'TranslationX', 'TranslationY', 'Magnification', 'AsymMagnification',...
                        'Rotation', 'AsymRotation', 'ExpansionX', 'ExpansionY', 'InterfieldRotation', 'NonOrtho'});

field_struct.expected_F_fieldnames =  sort({'machine_type' 'machine_id' 'chuck_id' 'wafer_accepted' 'exp_energy' 'layer_id' 'chuck_operation' 'recipe' 'image_size'});
field_struct.expected_F_image_shift_fieldnames =  sort({'machine_type' 'machine_id' 'chuck_id' 'wafer_accepted' 'exp_energy' 'layer_id' 'chuck_operation' 'recipe' 'image_size' 'image_shift'});
field_struct.expected_M_fieldnames =  sort({'machine_type' 'machine_id' 'nwafer' 'nfield'});

% define the field_struct.expected fieldnames in the expinfo substructure
field_struct.expected_expinfo_fieldnames =  sort({'xc' 'yc' 'map_fieldtoexp'});

% K-factor names must be in the correct order
field_struct.expected_parlist =  { 'k1','k2','ms','ma','rs','ra','k7','k8','k9','k10','k11','k12','k14','k15','k16','k17','k18','k19'};

