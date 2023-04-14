var sourceData770 = {"FileContents":["function [mlo, sbc] = bmmo_undo_sbc_corr_inlineSDM(mli, options, factor)\r","% function [mlo, ml_wh, sbc] = bmmo_undo_sbc_correction(mli,options, factor)\r","%\r","% This function removes the sbc correction applied during exposure of\r","% monitor lot, for calculation of uncontrolled KPI\r","%\r","% Input:\r","% mli: YieldStar measurement translated by LCP Java SW layer. mli also\r","% includes additional scanner data that is needed during modeling\r","% options: bmmo-nxe default options structure\r","%\r","% Output:\r","% mlo: Same structure as mli, with corrections during exposure reverted\r","% ml_wh: wafer heating fingerprint applied during exposure, for calculating\r","%           uncontrolled wafer heating KPI\r","% ml_intra: intrafield high order fingerprint applied during exposure, for \r","%           calculating uncontrolled intrafield HO KPI\r","% sbc:  structure containing the following fields:\r","%   ml_KA:  KA fingerprint\r","%   ml_MI:  MI fingerprint\r","%   ml_BAO: BAO fingerprint\r","%   ml_INTRAF: INTRAF fingerprint\r","%   ml_WH: WH fingerprint\r","% \r","% For details of the model and definitions of in/out interfaces, refer to\r","% D000323756 EDS BMMO NXE drift control model\r","%\r","% 20150616 MoZH&JIMI Creation\r","% 20160208 SBPR Bug fixes and refactoring\r","% 20160811 SBPR added sbc output\r","% 20201217 ANBZ updated for actuated KA correcton from ADELwfrgridNCE\r","\r","mlo = mli;\r","pc = options.previous_correction;\r","\r","if nargin < 3\r","    factor = -1; % default: undo SBC correction\r","end\r","\r","if options.bl3_model\r","    if isfield(pc.KA, 'act_corr')\r","        sbc.ml_KA =  pc.KA.act_corr; %actuated KA from ADELwfrgrid\r","    else\r","        warning('KA_act_corr field obtained from ADELwaferGridResidualReportProtected is missing, generating KA fingerprint using configured options instead')\r","        sbc.ml_KA = bmmo_KA_SBC_fingerprint(mli, pc.KA.grid_2de, options);\r","    end\r","else\r","    sbc.ml_KA = bmmo_KA_SBC_fingerprint(mli, pc.KA.grid_2de, options);\r","end\r","mlo = ovl_add(mlo, ovl_combine_linear(sbc.ml_KA, factor));\r","\r","sbc.ml_MI = bmmo_MI_SBC_fingerprint(mli, pc.MI.wse, options);\r","mlo = ovl_add(mlo, ovl_combine_linear(sbc.ml_MI, factor));\r","\r","sbc.ml_BAO = bmmo_BAO_SBC_fingerprint(mli, pc.BAO, options);\r","mlo = ovl_add(mlo, ovl_combine_linear(sbc.ml_BAO, factor));\r","\r","sbc.ml_inlineSDM = bmmo_ffp_to_ml(pc.ffp, mli, options);\r","mlo = ovl_add(mlo, ovl_combine_linear( sbc.ml_inlineSDM, factor));\r","\r","sbc.ml_WH= bmmo_WH_SBC_fingerprint(mli, options);\r","mlo = ovl_add(mlo, ovl_combine_linear(sbc.ml_WH, factor));\r","\r","if isfield(pc, 'SUSD')\r","    sbc.ml_SUSD = bmmo_SUSD_SBC_fingerprint(mli, pc.SUSD, options);\r","    mlo = ovl_add(mlo, ovl_combine_linear(sbc.ml_SUSD, factor));\r","end\r","\r","% the BAO ff par should have the opposite sign to the others\r","ff_6p = bmmo_ff_6par_fingerprint(mli, pc.MI.wsm, pc.KA.grid_2dc, options);\r","mlo = ovl_add(mlo, ovl_combine_linear(ff_6p, factor * -1));\r","\r","\r",""],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[33,34,36,37,40,41,42,43,44,45,47,48,50,52,53,55,56,58,59,61,62,64,65,66,70,71],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}