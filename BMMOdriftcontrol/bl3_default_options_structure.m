function options = bl3_default_options_structure
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
% D000810611 EDS BMMO NXE_drift control model functional

options = bmmo_default_options_structure;

options.submodel_sequence                =  {'WH_SUSD', 'MIKA_EDGE', 'BAO', 'INTRAF'};

options = bmmo_get_submodel_options(options);
options.no_layer_to_use = 2;

options.wafersize = 0.300;

%% KA MODEL OPTIONS
options.KA_control                       = 1;

options.KA_pitch                         =  0.001;
options.KA_start                         = -0.200; %-0.190;
options.KA_meas_start                    = -0.150;
options.KA_radius                        = 0.200; %0.190;
options.KA_bound                         = 0.200; %0.190;
options.KA_length                        = 401; %381;
options.KA_interp_type                   = 'linear';
options.KA_interp_pitch                  = 0.030;
options.KA_poly_order                    = 5;
options.KA.fit_poly                      = 1;
options.KA.extrap_max_bound              = 0.188;
options.KA.BAO_edge_removal              = 0.150;
options.KA_HOC_options = options.KA_resample_options;
options.KA_HOC_options.wafersize = 0.400; % in case EFO workaround implemented on LCP
options.KA_actuation.type = '33par';
options.KA_actuation.fnhandle = @bmmo_KA_33par_fingerprint;

%% Gaussian Edge Model OPTIONS
options.GaussianEdge_nodes                      = [0.143:0.002:0.149];
% options.GaussianEdge_nodes                      = [0.1435:0.0015:0.1465];
options.GaussianEdge_const                      = 0.020;

%% INTRAF combined model & intraf model for KA
options.CET33par.name = {'tx','ty','mx','my','rx','ry','d2','k8','k9','k10',...
    'bowxf','bowyf','mag3y','accx','accy','cshpx','cshpy','flw3x','k22',...
    'k24','k25','k26','k27','k29','k32','k34','k36','k37','k39','k41','k46','k48','k51'};
options.CET33par.scaling = [ 1e1*ones(1,6) 1e3*ones(1,6) 1e5*ones(1,6) 1e7*ones(1,6) ...
    1e9*ones(1,6) 1e11*ones(1,3)];  % FP Scaling to make the matrix elements to be O(10^(-1))~O(1) 

options.INTRAF.name = {'mx','my','rx','ry','d2','k8','k9','k10','bowxf','bowyf',...
    'd3','mag3y','accx','accy','cshpx','cshpy','flw3x','flw3y',...
    'k22','k24','k25','k26','k27','k29','k32','k34','k36','k37','k39','k41',...
    'k46','k48','k51'};   % 33 intrafield parameters (35par minus k1, k2)
options.INTRAF.scaling = [ 1e1*ones(1,4) 1e3*ones(1,6) 1e5*ones(1,8) 1e7*ones(1,6) ...
    1e9*ones(1,6) 1e11*ones(1,3)];  % FP Scaling to make the matrix elements to be O(10^(-1))~O(1) 

%% intrafield model options and reporting
options.intraf_actuation_order = 5;
options = bmmo_options_intraf(options, options.intraf_actuation_order);

options.platform = 'LIS';
options.bl3_model = 1;

%% INLINE SDM CONFIGURATION
options.inline_sdm_config.fnhandle = @bl3_3600D_model_configuration;
options.inline_sdm_config.machine_type = 'NXE3600D';
options.inline_sdm_config.sdm_model = 'BaseLiner 3';
%% RINT target
dummy_field = ovl_get_fields(ovl_create_dummy('marklayout', options.intrafield_reticle_layout), 1);
options.RINT_target.xf = dummy_field.wd.xf - 2.6000e-04;
options.RINT_target.yf = dummy_field.wd.yf - 4.0000e-05 ;

