var sourceData512 = {"FileContents":["function mlo = bmmo_kt_preprocess_input( mli, adeller, adelwhc, adelsbc, filter_enabled, widmapping)\r","% function mlo = bmmo_kt_preprocess_input( mli, adeller, adelwhc, adelsbc, filter_enabled, widmapping )\r","%\r","% Given a standard ml input structure mli and the paths of three ADEL files\r","% (ADELler, ADELwaferHeatingCorrectionsReport and ADELsbcOverlayDriftControlNxerep,\r","% return an ml structure that is valid input for the BMMO-NXE drift control\r","% model\r","%\r","% Input\r","%   mli: standard input structure with wd, layer, raw and tlgname fields\r","%   adeller: full path of ADELler xml file\r","%   adelwhc: full path of ADELwaferHeatingCorrectionsReport xml file\r","%\r","%\r","% Optional Input\r","%   adelsbc: full path of ADELsbcOverlayDriftControlNxerep xml file\r","%   filter_enabled: 1 if time filtering enabled; 0 otherwise\r","%   widmapping: [1xn double array) subset of wafers to map (default:\r","%       1:nwafer)\r","%\r","% Output\r","%   mlo: ml structure validated for input to BMMO-NXE drift control model\r","\r","% fill in redundant info.M fields\r","if ~isfield(mli, 'tlgname')\r","    mli.tlgname = '';\r","end\r","\r","if nargin < 5\r","    filter_enabled = 0;\r","end\r","\r","if nargin < 6\r","    widmapping = 1:mli.nwafer;\r","end\r","\r","mli.info.M.nwafer = mli.nwafer;\r","mli.info.M.nfield = mli.nfield;\r","\r","ml_1 = bmmo_kt_process_adeller_input(mli, adeller);\r","\r","ml_2 = bmmo_kt_process_adelwhc_input(ml_1, adelwhc, widmapping);\r","\r","ml_2 = sub_get_wafer_info(ml_2, widmapping);\r","\r","if nargin > 4\r","    % get previous correction\r","    [ml_2.info.previous_correction, inline_sdm] = bmmo_kt_process_SBC2rep(adelsbc);\r","    \r","    % get SDM residual\r","    ml_2.info.report_data.inline_sdm_residual = inline_sdm.sdm_res;\r","    if isfield(inline_sdm, 'sdm_model')\r","        ml_2.info.report_data.inline_sdm_model = inline_sdm.sdm_model;\r","    end\r","    \r","    % get time filter factor\r","    ml_2.info.report_data.inline_sdm_time_filter = inline_sdm.time_filter;\r","    \r","    \r","    % get SDM CET NCE\r","    if isfield(inline_sdm, 'sdm_cet_res')\r","        ml_2.info.report_data.inline_sdm_cet_residual = inline_sdm.sdm_cet_res;\r","    end\r","else\r","    % fill in a zero previous correction\r","    disp('No SBC report provided: filling in zero previous correction');\r","    options = bmmo_default_options_structure;\r","    pc = bmmo_default_output_structure(options);\r","    ml_2.info.previous_correction = pc.corr;\r","\r","    ml_2.info.report_data.inline_sdm_residual = pc.corr.ffp; \r","end\r","  \r","mlo = ml_2;\r","if nargin < 5\r","    filter_enabled = 0;\r","end\r","\r","mlo.info.report_data.time_filtering_enabled = filter_enabled;\r","\r","bmmo_validate_input(mlo);\r","\r","\r","\r","function mlo = sub_get_wafer_info(mli, wafer_list)\r","\r","mlo = mli;\r","mlo.info.report_data.FIWA_translation.x = mlo.info.report_data.FIWA_translation.x(wafer_list);\r","mlo.info.report_data.FIWA_translation.y = mlo.info.report_data.FIWA_translation.y(wafer_list);\r","mlo = sub_fix_chuck_info(mlo, wafer_list);\r","\r","\r","function mlo = sub_fix_chuck_info(mli, wafer_list)\r","    mlo = mli;\r","    \r","    mlo.info.F.chuck_id = mlo.info.F.chuck_id(wafer_list);\r","    mlo.info.F.wafer_accepted = mlo.info.F.wafer_accepted(wafer_list);\r","\r","    % now count the number of chucks used\r","    chucks_used = length(unique(mlo.info.F.chuck_id));\r","    if chucks_used < 2\r","        mlo.info.F.chuck_operation = 'ONE_CHUCK';\r","    end\r",""],"CoverageData":{"CoveredLineNumbers":[25,26,29,33,37,38,40,42,44,46,48,51,52,57,61,74,75,79,81,87,88,89,90,94,96,97,100,101],"UnhitLineNumbers":[30,34,53,62,64,66,67,68,69,71,76,102],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,0,0,4,0,0,0,4,0,0,0,4,4,0,4,0,4,0,4,0,4,0,4,0,0,4,4,0,0,0,0,4,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,4,4,0,0,0,4,0,4,0,0,0,0,0,4,4,4,4,0,0,0,4,0,4,4,0,0,4,4,0,0,0]}}