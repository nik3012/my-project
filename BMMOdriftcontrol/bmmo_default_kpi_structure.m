function KPI = bmmo_default_kpi_structure
% function KPI = bmmo_default_kpi_structure
%
% This function generates the default KPI structure for BMMO/BL3 NXE drift
% control model. 
%
% Input: None
% 
% Output:
% KPI: Generated KPI structure. 
% 
% For details of the model and definitions of in/out interfaces, refer to
% D000810611 EDS BMMO NXE drift control model

%% High level structures

KPI.uncontrolled = [];
KPI.input        = [];
KPI.correction   = [];
KPI.residue      = [];

%% Mid level structures

KPI.uncontrolled.overlay      = [];
KPI.uncontrolled.intrafield   = [];
KPI.uncontrolled.waferheating = [];
KPI.input.valid               = [];
KPI.input.w2w                 = [];
KPI.input.overlay             = [];
KPI.correction.waferheating   = [];
KPI.correction.mirror         = [];
KPI.correction.grid           = [];
KPI.correction.bao            = [];
KPI.correction.susd           = [];
KPI.correction.k_factors      = [];
KPI.residue.interfield        = [];
KPI.residue.intrafield        = [];

%% Low level structures uncontrolled

KPI.uncontrolled.overlay.ovl_exp_grid_chk1_max_x_uncontrolled  = [];
KPI.uncontrolled.overlay.ovl_exp_grid_chk1_max_y_uncontrolled  = [];
KPI.uncontrolled.overlay.ovl_exp_grid_chk1_997_x_uncontrolled  = [];
KPI.uncontrolled.overlay.ovl_exp_grid_chk1_997_y_uncontrolled  = [];
KPI.uncontrolled.overlay.ovl_exp_grid_chk1_m3s_x_uncontrolled  = [];
KPI.uncontrolled.overlay.ovl_exp_grid_chk1_m3s_y_uncontrolled  = [];
KPI.uncontrolled.overlay.ovl_exp_grid_chk1_3std_x_uncontrolled = [];
KPI.uncontrolled.overlay.ovl_exp_grid_chk1_3std_y_uncontrolled = [];
KPI.uncontrolled.overlay.ovl_exp_grid_chk2_max_x_uncontrolled  = [];
KPI.uncontrolled.overlay.ovl_exp_grid_chk2_max_y_uncontrolled  = [];
KPI.uncontrolled.overlay.ovl_exp_grid_chk2_997_x_uncontrolled  = [];
KPI.uncontrolled.overlay.ovl_exp_grid_chk2_997_y_uncontrolled  = [];
KPI.uncontrolled.overlay.ovl_exp_grid_chk2_m3s_x_uncontrolled  = [];
KPI.uncontrolled.overlay.ovl_exp_grid_chk2_m3s_y_uncontrolled  = [];
KPI.uncontrolled.overlay.ovl_exp_grid_chk2_3std_x_uncontrolled = [];
KPI.uncontrolled.overlay.ovl_exp_grid_chk2_3std_y_uncontrolled = [];

KPI.uncontrolled.intrafield.ovl_k7_chk1_mean_uncontrolled      = [];
KPI.uncontrolled.intrafield.ovl_k8_chk1_mean_uncontrolled      = [];
KPI.uncontrolled.intrafield.ovl_k9_chk1_mean_uncontrolled      = [];
KPI.uncontrolled.intrafield.ovl_k10_chk1_mean_uncontrolled     = [];
KPI.uncontrolled.intrafield.ovl_k11_chk1_mean_uncontrolled     = [];
KPI.uncontrolled.intrafield.ovl_k12_chk1_mean_uncontrolled     = [];
KPI.uncontrolled.intrafield.ovl_k13_chk1_mean_uncontrolled     = [];
KPI.uncontrolled.intrafield.ovl_k14_chk1_mean_uncontrolled     = [];
KPI.uncontrolled.intrafield.ovl_k15_chk1_mean_uncontrolled     = [];
KPI.uncontrolled.intrafield.ovl_k16_chk1_mean_uncontrolled     = [];
KPI.uncontrolled.intrafield.ovl_k17_chk1_mean_uncontrolled     = [];
KPI.uncontrolled.intrafield.ovl_k18_chk1_mean_uncontrolled     = [];
KPI.uncontrolled.intrafield.ovl_k19_chk1_mean_uncontrolled     = [];
KPI.uncontrolled.intrafield.ovl_k20_chk1_mean_uncontrolled     = [];
KPI.uncontrolled.intrafield.ovl_k7_chk2_mean_uncontrolled      = [];
KPI.uncontrolled.intrafield.ovl_k8_chk2_mean_uncontrolled      = [];
KPI.uncontrolled.intrafield.ovl_k9_chk2_mean_uncontrolled      = [];
KPI.uncontrolled.intrafield.ovl_k10_chk2_mean_uncontrolled     = [];
KPI.uncontrolled.intrafield.ovl_k11_chk2_mean_uncontrolled     = [];
KPI.uncontrolled.intrafield.ovl_k12_chk2_mean_uncontrolled     = [];
KPI.uncontrolled.intrafield.ovl_k13_chk2_mean_uncontrolled     = [];
KPI.uncontrolled.intrafield.ovl_k14_chk2_mean_uncontrolled     = [];
KPI.uncontrolled.intrafield.ovl_k15_chk2_mean_uncontrolled     = [];
KPI.uncontrolled.intrafield.ovl_k16_chk2_mean_uncontrolled     = [];
KPI.uncontrolled.intrafield.ovl_k17_chk2_mean_uncontrolled     = [];
KPI.uncontrolled.intrafield.ovl_k18_chk2_mean_uncontrolled     = [];
KPI.uncontrolled.intrafield.ovl_k19_chk2_mean_uncontrolled     = [];
KPI.uncontrolled.intrafield.ovl_k20_chk2_mean_uncontrolled     = [];
KPI.uncontrolled.intrafield.ovl_k20_chk2_mean_uncontrolled     = [];

KPI.uncontrolled.intrafield.Ovl_ripple_3s_chk1                 = [];
KPI.uncontrolled.intrafield.Ovl_ripple_3s_chk2                 = [];

KPI.uncontrolled.waferheating.ovl_exp_grid_dx_whc_uncontrolled = [];
KPI.uncontrolled.waferheating.ovl_exp_grid_dy_whc_uncontrolled = [];

%% Low level structures input

KPI.input.valid.ovl_exp_grid_chk1_nr_valids           = [];
KPI.input.valid.ovl_exp_grid_chk1_nr_readout_nans     = [];
KPI.input.valid.ovl_exp_grid_chk1_nr_outliers         = [];
KPI.input.valid.ovl_exp_grid_chk1_nr_invalids         = [];
KPI.input.valid.ovl_exp_grid_chk2_nr_valids           = [];
KPI.input.valid.ovl_exp_grid_chk2_nr_readout_nans     = [];
KPI.input.valid.ovl_exp_grid_chk2_nr_outliers         = [];
KPI.input.valid.ovl_exp_grid_chk2_nr_invalids         = [];

KPI.input.w2w.ovl_exp_grid_chk1_max_w2w_var           = [];
KPI.input.w2w.ovl_exp_grid_chk2_max_w2w_var           = [];

KPI.input.overlay.ovl_exp_grid_chk1_max_x_controlled  = [];
KPI.input.overlay.ovl_exp_grid_chk1_max_x_controlled  = [];
KPI.input.overlay.ovl_exp_grid_chk1_max_y_controlled  = [];
KPI.input.overlay.ovl_exp_grid_chk1_997_x_controlled  = [];
KPI.input.overlay.ovl_exp_grid_chk1_997_y_controlled  = [];
KPI.input.overlay.ovl_exp_grid_chk1_m3s_x_controlled  = [];
KPI.input.overlay.ovl_exp_grid_chk1_m3s_y_controlled  = [];
KPI.input.overlay.ovl_exp_grid_chk1_3std_x_controlled = [];
KPI.input.overlay.ovl_exp_grid_chk1_3std_y_controlled = [];
KPI.input.overlay.ovl_exp_grid_chk2_max_x_controlled  = [];
KPI.input.overlay.ovl_exp_grid_chk2_max_x_controlled  = [];
KPI.input.overlay.ovl_exp_grid_chk2_max_y_controlled  = [];
KPI.input.overlay.ovl_exp_grid_chk2_997_x_controlled  = [];
KPI.input.overlay.ovl_exp_grid_chk2_997_y_controlled  = [];
KPI.input.overlay.ovl_exp_grid_chk2_m3s_x_controlled  = [];
KPI.input.overlay.ovl_exp_grid_chk2_m3s_y_controlled  = [];
KPI.input.overlay.ovl_exp_grid_chk2_3std_x_controlled = [];
KPI.input.overlay.ovl_exp_grid_chk2_3std_y_controlled = [];

%% Low level structures correction

KPI.correction.waferheating.ovl_exp_grid_whc_delta = [];

KPI.correction.mirror.ovl_exp_ytx_max_full_chk1    = [];
KPI.correction.mirror.ovl_exp_xty_max_full_chk1    = [];
KPI.correction.mirror.ovl_exp_ytx_max_wafer_chk1   = [];
KPI.correction.mirror.ovl_exp_xty_max_wafer_chk1   = [];
KPI.correction.mirror.ovl_exp_ytx_997_full_chk1    = [];
KPI.correction.mirror.ovl_exp_xty_997_full_chk1    = [];
KPI.correction.mirror.ovl_exp_ytx_997_wafer_chk1   = [];
KPI.correction.mirror.ovl_exp_xty_997_wafer_chk1   = [];
KPI.correction.mirror.ovl_exp_ytx_max_full_chk2    = [];
KPI.correction.mirror.ovl_exp_xty_max_full_chk2    = [];
KPI.correction.mirror.ovl_exp_ytx_max_wafer_chk2   = [];
KPI.correction.mirror.ovl_exp_xty_max_wafer_chk2   = [];
KPI.correction.mirror.ovl_exp_ytx_997_full_chk2    = [];
KPI.correction.mirror.ovl_exp_xty_997_full_chk2    = [];
KPI.correction.mirror.ovl_exp_ytx_997_wafer_chk2   = [];
KPI.correction.mirror.ovl_exp_xty_997_wafer_chk2   = [];

KPI.correction.grid.ovl_exp_grid_chk1_max_x        = [];
KPI.correction.grid.ovl_exp_grid_chk1_max_y        = [];
KPI.correction.grid.ovl_exp_grid_chk1_997_x        = [];
KPI.correction.grid.ovl_exp_grid_chk1_997_y        = [];
KPI.correction.grid.ovl_exp_grid_chk1_m3s_x        = [];
KPI.correction.grid.ovl_exp_grid_chk1_m3s_y        = [];
KPI.correction.grid.ovl_exp_grid_chk1_3std_x       = [];
KPI.correction.grid.ovl_exp_grid_chk1_3std_y       = [];
KPI.correction.grid.ovl_exp_grid_chk2_max_x        = [];
KPI.correction.grid.ovl_exp_grid_chk2_max_y        = [];
KPI.correction.grid.ovl_exp_grid_chk2_997_x        = [];
KPI.correction.grid.ovl_exp_grid_chk2_997_y        = [];
KPI.correction.grid.ovl_exp_grid_chk2_m3s_x        = [];
KPI.correction.grid.ovl_exp_grid_chk2_m3s_y        = [];
KPI.correction.grid.ovl_exp_grid_chk2_3std_x       = [];
KPI.correction.grid.ovl_exp_grid_chk2_3std_y       = [];

KPI.correction.bao.ovl_translation_x_chk1_delta    = [];
KPI.correction.bao.ovl_translation_y_chk1_delta    = [];
KPI.correction.bao.ovl_sym_intra_mag_chk1_delta    = [];
KPI.correction.bao.ovl_sym_intra_rot_chk1_delta    = [];
KPI.correction.bao.ovl_asym_intra_mag_chk1_delta   = [];
KPI.correction.bao.ovl_asym_intra_rot_chk1_delta   = [];
KPI.correction.bao.ovl_sym_wafer_rot_chk1_delta    = [];
KPI.correction.bao.ovl_asym_wafer_rot_chk1_delta   = [];
KPI.correction.bao.ovl_sym_wafer_mag_x_chk1_delta  = [];
KPI.correction.bao.ovl_asym_wafer_mag_y_chk1_delta = [];
KPI.correction.bao.ovl_translation_x_chk2_delta    = [];
KPI.correction.bao.ovl_translation_y_chk2_delta    = [];
KPI.correction.bao.ovl_sym_intra_mag_chk2_delta    = [];
KPI.correction.bao.ovl_sym_intra_rot_chk2_delta    = [];
KPI.correction.bao.ovl_asym_intra_mag_chk2_delta   = [];
KPI.correction.bao.ovl_asym_intra_rot_chk2_delta   = [];
KPI.correction.bao.ovl_sym_wafer_rot_chk2_delta    = [];
KPI.correction.bao.ovl_asym_wafer_rot_chk2_delta   = [];
KPI.correction.bao.ovl_sym_wafer_mag_x_chk2_delta  = [];
KPI.correction.bao.ovl_asym_wafer_mag_y_chk2_delta = [];

KPI.correction.susd.ovl_exp_grid_chk1_ty_susd      = [];
KPI.correction.susd.ovl_exp_grid_chk2_ty_susd      = [];

KPI.correction.k_factors.ovl_k7_chk1               = [];
KPI.correction.k_factors.ovl_k8_chk1               = [];
KPI.correction.k_factors.ovl_k9_chk1               = [];
KPI.correction.k_factors.ovl_k10_chk1              = [];
KPI.correction.k_factors.ovl_k11_chk1              = [];
KPI.correction.k_factors.ovl_k12_chk1              = [];
KPI.correction.k_factors.ovl_k13_chk1              = [];
KPI.correction.k_factors.ovl_k14_chk1	           = [];
KPI.correction.k_factors.ovl_k15_chk1	           = [];
KPI.correction.k_factors.ovl_k16_chk1	           = [];
KPI.correction.k_factors.ovl_k17_chk1	           = [];
KPI.correction.k_factors.ovl_k18_chk1	           = [];
KPI.correction.k_factors.ovl_k19_chk1	           = [];
KPI.correction.k_factors.ovl_k20_chk1	           = [];
KPI.correction.k_factors.ovl_k7_chk2               = [];
KPI.correction.k_factors.ovl_k8_chk2               = [];
KPI.correction.k_factors.ovl_k9_chk2               = [];
KPI.correction.k_factors.ovl_k10_chk2              = [];
KPI.correction.k_factors.ovl_k11_chk2              = [];
KPI.correction.k_factors.ovl_k12_chk2              = [];
KPI.correction.k_factors.ovl_k13_chk2              = [];
KPI.correction.k_factors.ovl_k14_chk2	           = [];
KPI.correction.k_factors.ovl_k15_chk2	           = [];
KPI.correction.k_factors.ovl_k16_chk2	           = [];
KPI.correction.k_factors.ovl_k17_chk2	           = [];
KPI.correction.k_factors.ovl_k18_chk2	           = [];
KPI.correction.k_factors.ovl_k19_chk2	           = [];
KPI.correction.k_factors.ovl_k20_chk2	           = [];

%% Low level structures residue

KPI.residue.interfield.ovl_grid_chk1_res_997              = [];
KPI.residue.interfield.ovl_grid_chk2_res_997              = [];
KPI.residue.interfield.ovl_exp_ytx_max_wafer_chk1         = [];
KPI.residue.interfield.ovl_exp_xty_max_wafer_chk1         = [];
KPI.residue.interfield.ovl_exp_ytx_max_wafer_chk2         = [];
KPI.residue.interfield.ovl_exp_xty_max_wafer_chk2         = [];

KPI.residue.intrafield.ovl_exp_field_HO_res_x_before_chk1 = [];
KPI.residue.intrafield.ovl_exp_field_HO_res_y_before_chk1 = [];
KPI.residue.intrafield.ovl_exp_field_HO_res_x_res_chk1    = [];
KPI.residue.intrafield.ovl_exp_field_HO_res_y_res_chk1    = [];
KPI.residue.intrafield.ovl_exp_field_HO_res_x_delta_chk1  = [];
KPI.residue.intrafield.ovl_exp_field_HO_res_y_delta_chk1  = [];
KPI.residue.intrafield.ovl_exp_field_HO_res_x_before_chk2 = [];
KPI.residue.intrafield.ovl_exp_field_HO_res_y_before_chk2 = [];
KPI.residue.intrafield.ovl_exp_field_HO_res_x_res_chk2    = [];
KPI.residue.intrafield.ovl_exp_field_HO_res_y_res_chk2    = [];
KPI.residue.intrafield.ovl_exp_field_HO_res_x_delta_chk2  = [];
KPI.residue.intrafield.ovl_exp_field_HO_res_y_delta_chk2  = [];
