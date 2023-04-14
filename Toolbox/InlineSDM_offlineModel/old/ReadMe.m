addpath('\\asml.com\eu\shared\nl011052\BMMO_NXE_TS\01-Functional\102-Study_items\BMMO_inlineSDM\MatlabCode_July17_2015');
test_inlineSDM
%%---------------------------------
%% Output
%     par_mc.scan
%     par_mc.lens
%     extra_data.corr.lens 
%     extra_data.corr.scan 
%     extra_data.corr.lens_static
%     extra_data.input.lens
%     extra_data.input.scan
%     KPI (1~8) as defined on page 23 in D000347979
%     RES (1~3) as defined on page 23 in D000347979


%% The ppt is generated based on 10 machine data. Each data is used on both chucks.
% Example : [par_mc, extra_data, par, KPI, RES]=BMMO_model_inlineSDM(ml_field_chk1, ml_field_chk1);
%% In order not to use LFP, use 'LFP',0 in the function argument like 
%[par_mc, extra_data, par, KPI, RES]=BMMO_model_inlineSDM(ml_field_chk1, ml_field_chk1, 'LFP',0)
% by default, the data will use LFP.
% 
% KPI mapping
% 
% KPI1 : Max of total correctables / chuck - KPI.maxTotalCorr(chuck_num).dx/dy [m]
% KPI2 : Max of lens correctables			 - KPI.maxLensCorr.dx/dy             [m]
% KPI3 : Max of total residuals/ chuck     - KPI.maxTotalRes(chuck_num).dx/dy  [m]
% KPI4 : Max of lens residuals             - KPI.maxLensRes.dx/dy              [m]
% KPI5 : Fading MSD (x/y) /chuck           - KPI.FadingMSD(chuck_num).x/y      [m]
% KPI6 : Z2_2, Z3_2                        - KPI.Z2_2, KPI.Z3_2                [nm/cm^2]
% KPI7 : Max HOC correctables / chuck      - KPI.maxHOCCorr(chuck_num).dx/dy   [m]
% KPI8 : Max HOC residuals / chuck         - KPI.maxHOCRes(chuck_num).dx/dy    [m]
% 
% 
% %% Reamrk
% No Rx 3rd is used. HOC performance is the same as that of sdmhoc.
% Fading calculation is done as defined on EDS(D000347979). 