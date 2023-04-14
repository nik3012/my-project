function options = bmmo_ml_options_wh(mli, options)
%function options = bmmo_ml_options_wh(mli, options)
%
% This function will transfer WH data from mli.info to options structure. Data
% from mli.info is gathered from multiple ADEL files from scanner.
%
% Input :
% mli    : input ml struct
% options: existing options structure
%
% Ouput :
% options: parsed options structure
%
% For details of the model and definitions of in/out interfaces, refer to
% D000810611 EDS BMMO NXE drift control model

options.WH_K_factors        = mli.info.report_data.WH_K_factors;
options.IR2EUVsensitivity   = mli.info.report_data.IR2EUVsensitivity;
options.Rir2euv             = mli.info.report_data.Rir2euv;
options.WH.rir                 = mli.info.report_data.r;
options.WH.tir                 = mli.info.report_data.t;
options.WH.pdgl                = mli.info.report_data.Pdgl;
options.WH.slip                = mli.info.report_data.SLIP;
options.WH.tret                = mli.info.report_data.Tret;