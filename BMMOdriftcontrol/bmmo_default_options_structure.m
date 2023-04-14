function options = bmmo_default_options_structure
% function options = bmmo_default_options_structure
%
% This function generates the default option structure for BMMO NXE drift
% control model.
%
% Input:
%
% Output: 
% options:  generated structure.
%
% For details of the model and definitions of in/out interfaces, refer to
% D000810611 EDS BMMO NXE drift control model

%% SUB-MODEL SEQUENCE
options.submodel_sequence                =  {'WH', 'SUSD_2L_monitor', 'MI', 'BAO', 'INTRAF'};
options = bmmo_get_submodel_options(options);
options.no_layer_to_use = 2;

%% Parameter list used for overlay modelling
options.parlist = bmmo_parlist;

%% Switch for undo_correction before modelling
% Off by default
options.undo_before_modelling = 0;

%% Switch for SUSD
options.susd_control = 0;

%% switch for inverting mirror sign at measure side, i.e. measure = - expose, default ON
options.invert_MI_wsm_sign = 1;

%% COMBINED MODEL CONTENTS
options.combined_model_contents = struct;

%% INPUT PROCESSING OPTIONS
% options.mark_type                        =  'rint'; % default supported input: ys, xpa, rint
options.layout_type                      =  'bmmo';  
options.wafersize                        =  0.300;

%% FIELD RECONSTRUCTION OPTIONS

% 2-layer default fields
options.layer_fields{1} = 1:87; % note that ml.expinfo must contain at least this number of fields 
options.layer_fields{2} = 88; % first field of layer 2 

% xc,xf shifts relative to expinfo field centres (cols) per layer (rows)
options.x_shift = [0 0; 0 0];
% yc,yf shifts relative to expinfo field centers (cols) per layer (rows)
options.y_shift = [0 0; 0 0];
options.model_shift.x = options.x_shift;
options.model_shift.y = options.y_shift;

% field IDS of edge fields in layer 2 (if applicable)
options.edge_fields = [125 136];

%% CHUCK OPTIONS
options.chuck_usage.chuck_id_used = [1 2];
options.chuck_usage.chuck_id = [1 2 1 2 1 2];
options.chuck_usage.nr_chuck_used = 2;


%% WH MODEL OPTIONS
options.WH.use_input_fp                  = 0;
options.WH.use_input_fp_per_wafer        = 0;  
options.WH.fp                            = [];
options.WH.use_raw                       = 0;   % set to 1 if ml.raw 2-layer data is present
options.Rir2euv = 0.625;

% WH resampling to 7x7
options.WH_resample_options.nan_interpolation  = 'false';
options.WH_resample_options.wafersize          = 1e8; % simulate ovl_interp_layout behaviour; ensure that edges won't be removed
options.WH_resample_options.bounding_box       = 'none';
options.WH_resample_options.interp_type        = 'nearest';

% relative layer shifts
options.WH.l1_shift_x = 0;
options.WH.l1_shift_y = -520e-6;
options.WH.l2_shift_x = 0;
options.WH.l2_shift_y = 520e-6;

% WH sensitivity data
options.WH.rir                 = 0.5;
options.WH.tir                 = 1;
options.WH.pdgl                = 0.03;
options.WH.slip                = 24;
options.WH.tret                = 0.04;

% Empirical constants for WH sensitivity calculation, including lookup
% table for c
options.WH.a                = 0.92;
options.WH.b                = 1.38;
options.WH.c_mapping.slip   = [10 15 20 25];
options.WH.c_mapping.c      = [0.6 0.6 0.6 0.6];

%% KA MODEL OPTIONS
options.KA_control                       = 0;
options.KA_measure_enabled               = 0;
options.KA_pitch                         =  0.005;
options.KA_bound                         = 0.150;
options.KA_meas_bound                    = options.KA_bound;
options.KA_start                         = -0.150;
options.KA_meas_start                    = options.KA_start;
options.KA_length                        =  61;
options.KA_interp_type                   = 'linear';
options.KA_interp_pitch                  = 0.030;
options.KA_poly_order                    = 5;
options.KA.fit_poly                      = 1;

options.fieldsize                        = [26 33] * 1e-3;  % field size in m, for bmmo_apply_KA
options.wafer_radius_in_mm               = 150;

% KA  resampling
options.KA_resample_options.nan_interpolation      = 'none';
options.KA_resample_options.bounding_box           = 'none';
options.KA_resample_options.wafersize              = options.wafersize;
options.KA_resample_options.interp_type            = options.KA_interp_type;
options.KA_resample_options.gauss_radius           = options.KA_interp_pitch;

options.KA_actuation.type = 'LOC';
options.KA_actuation.fnhandle = @bmmo_KA_LOC_fingerprint;
options.CET_marklayout = [25.44, 33, 13, 19];

%% MI MODEL OPTIONS
options.map_param.start_position         = -0.200;
options.map_param.pitch                  =  0.001;
options.map_table_length                 = 401;
options.edge_clearance                   = 0.147;
options.xty_spline_params.x_start        = -0.135;
options.xty_spline_params.x_end          =  0.135;
options.xty_spline_params.nr_segments    = 11;
options.ytx_spline_params.x_start        = -0.135;
options.ytx_spline_params.x_end          =  0.135;
options.ytx_spline_params.nr_segments    = 11;
options.lens_type                        = [];
options.scaling_factor                   = 1e9;

options.FIWA_mark_locations.mark_type                   = 'BF';
options.FIWA_mark_locations.x              = [-103.58  -103.58  -73.90...  
                                          -73.90 -44.22 -44.22...  
                                          -14.54  -14.54   15.14...
                                           15.14   44.82 44.82  74.50...
                                           74.50  104.18 104.18]*1e-3;
options.FIWA_mark_locations.x_pitch                     = 29.68*1e-3;                                       
options.FIWA_mark_locations.y              = [-19.4905 18.3515 -57.3325...
                                           56.1935 -95.1745  94.0355...
                                          -95.1745  94.0355 -95.1745...
                                          94.0355 -95.1745 94.0355 -57.3325... 
                                          56.1935 -19.4905 18.3515]*1e-3;
options.FIWA_mark_locations.y_pitch                     = 37.8420*1e-3;
options.extra_splines                    = [1 1 1 1];

% hardcoded Q_grid for 3300, 3350, 3400 machines, lens type 33
options.Q_grid.x          = [-0.0127 -0.0106 -0.0085 ...
                                    -0.0064 -0.0042 -0.0021 ...
                                    0 0.0021 0.0042 0.0064 ...
                                    0.0085 0.0106 0.0127];
options.Q_grid.y          = [ 1.0000e-03   3.6600e-04 ...
                                    -1.4600e-04  -5.3900e-04 ...
                                    -8.1800e-04  -9.8400e-04 ...
                                    -1.0390e-03  -9.8400e-04 ...
                                    -8.1800e-04  -5.3900e-04...
                                    -1.4600e-04 3.6600e-04 ...
                                    1.0000e-03];


options.fid_intrafield                   = [21 23 31 32 34 35 54 55 ...
                                            57 58 66 68];
options.fid_left_right_edgefield         = [17 27 28 39 50 61 62 72 ...
                                            88 89];
options.fid_top_bottom_edgefield         = [3 4 5 82 83 84];

%% INTRAF MODEL OPTIONS
options.intraf_resample_options.nan_interpolation = 'diagonal';
options.intraf_resample_options.bounding_box = [-0.0165 -0.0165 0.0165 ...
    0.0165; -0.0165 0.0165 -0.0165 0.0165]';
options.intraf_resample_options.interp_type = 'spline';
options.intraf_resample_options.extrap_type = 'linear';
options.intraf_resample_options.wafersize = 300;
options.intraf_resample_options.resample_function = @bmmo_resample;


%% intrafield model options and reporting
options.intraf_actuation_order = 3;
options = bmmo_options_intraf(options, options.intraf_actuation_order);
options.intraf_actuation.fnhandle = @bmmo_INTRAF_par_fingerprint;

%% OUTPUT PROCESSING OPTIONS
options.intrafield_reticle_layout        = 'BA-XY-DYNA-13X19';
options.reduced_reticle_layout           = 'BA-XY-DYNA-7X7';

%% OUTLIER REMOVAL OPTIONS
options.do_outlier_removal               = 1;
options.outlier_coverage_factor          = 4.0;
options.outlier_max_ovl                  = 1e-6;
options.outlier_check_radius             = 0.01;
options.outlier_max_fraction             = 0.25;

% w2w outlier removal options
options.ol_w2w.outlier_coverage_factor = options.outlier_coverage_factor;
options.ol_w2w.outliers_returned = 'all_outliers'; % remove all discovered outliers per iteration
options.ol_w2w.outlier_std = 'per_layer';          % calculate std across all wafers on each chuck
options.ol_w2w.max_iter = 1;
options.ol_w2w.showdetails = 0;
options.ol_w2w.absolute_threshold = 1e-12;
options.ol_w2w.min_std = 1e-12;

% combined model outlier removal options
options.ol_cm.outlier_coverage_factor = options.outlier_coverage_factor;
options.ol_cm.outlier_std = 'per_wafer';
options.ol_cm.showdetails = 0;
options.ol_cm.outliers_returned = 'per_field';
options.ol_cm.max_iter = 5;
options.ol_cm.absolute_threshold = 1e-9;
options.ol_cm.min_std = 1e-12;


%% MODEL-INPUT DEPENDENT OPTIONS
options.FIWA_translation                 = [];
options.Scan_direction                   = [-1;1;-1;1;-1;1;-1;-1;1;-1;1;...
    -1;1;-1;1;-1;-1;1;-1;1;-1;1;-1;1;-1;1;-1;-1;1;-1;1;-1;1;-1;1;-1;1;-1;...
    -1;1;-1;1;-1;1;-1;1;-1;1;-1;1;1;-1;1;-1;1;-1;1;-1;1;-1;1;-1;1;-1;1;-1;...
    1;-1;1;-1;1;-1;-1;1;-1;1;-1;1;-1;1;-1;-1;1;-1;1;-1;1;-1;1;-1;1;-1;1;1;...
    -1;1;-1;1;-1;1;-1;1;1;-1;1;-1;1;-1;1;-1;1;-1;1;-1;1;-1;1;-1;1;-1;1;-1;...
    1;-1;-1;1;-1;1;-1;1;-1;1;-1;1;-1;1;1;-1;1;-1;1;-1;1;-1;1;-1;1;1;-1;1;...
    -1;1;-1;1;-1;1;-1;1;1;-1;1;-1;1;-1;1;-1;1];
options.WH_K_factors                     = [];
options.IR2EUVsensitivity                = [];
options.Rir2euv                          = [];
options.previous_correction              = [];



%% OPTIONS FOR COMBINED MODEL
options.INTERF.name = {'rws', 'rwa', 'mws', 'mwa'};  % interfield parameters
options.INTERFMAG.name = {'mws', 'mwa'};
options.INTRAF.name = {'mx','my','rx','ry','d2','k8','k9','k10','bowxf','bowyf','d3','mag3y','accx','accy','cshpx','cshpy','flw3x','flw3y'};   % 18 intrafield parameters
options.INTRAF.scaling = [ 1e1*ones(1,4) 1e3*ones(1,6) 1e5*ones(1,8)];  % FP Scaling to make the matrix elements to be O(10^(-1))~O(1) 

% The KA polynomial orders to include in the combined model 
% If KA is in the combined model, uncomment the following line and change
% it to include the desired polynomial orders of KA
options.KA_orders = [2 3 4 5]; 

%% OPTIONS FOR TIME FILTERING
options.filter.T1 = 7;
options.filter.T2 = 20;

options.filter.coefficients = bmmo_get_empty_filter;

options.filter.function = @bmmo_apply_ewma_filter;
options.filter.T_previous_expose = 0;
options.filter.T_current_expose = 1;

%% IFO CORRECTION SCAN DIRECTIONS
% From ADEL SBC2a definition: ch1 scan down, ch1 scan up, ch2 scan down, ch2 scan up
options.IFO_scan_direction = [-1 1 -1 1];

%% PREVIOUS CORRECTION
temp_out = bmmo_default_output_structure(options);
options.previous_correction = temp_out.corr;

options.platform = 'OTAS';
options.bl3_model = 0;
%% INLINE SDM CONFIGURATION
options.inline_sdm_config.fnhandle = @bmmo_3400C_model_configuration;
options.inline_sdm_config.machine_type = 'NXE3400C';
%% ERO KPI options
options.ERO.inner_radius = 0.140;
options.ERO.edge_radius = 0.1451;
options.ERO.outer_radius_input = 0.150;
options.ERO.outer_radius_KA = 0.1470001;

