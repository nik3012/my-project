var sourceData163 = {"FileContents":["function [mlo, options] = bmmo_process_input(input_struct)\r","% function [mlo, options] = bmmo_process_input(input_struct);\r","%\r","% Perform field reconstruction on the input structure and generate \r","% the model options including data from its 'info' field\r","%\r","% Input:\r","% input_struct: Input structure as generated by bmmo_read_lcp_zip,\r","%               containing YieldStar measurements and all information that \r","%               is needed during modeling\r","%\r","% Output:\r","% mlo:          model structure after field reconstruction\r","% options:      options structure\r","\r","mlo = input_struct;\r","\r","bmmo_validate_input(mlo);\r","\r","if isfield(input_struct.info,'configuration_data') && isfield(input_struct.info.configuration_data,'bl3_model') && input_struct.info.configuration_data.bl3_model\r","    options = bl3_default_options_structure; \r","\r","    options = bl3_ml_options(mlo, options);\r","else\r","    options = bmmo_default_options_structure; \r","    \r","    options = bmmo_ml_options(mlo, options);\r","end\r","\r","mlo.info = rmfield(mlo.info, 'report_data'); \r","mlo.info = rmfield(mlo.info, 'previous_correction');\r","\r","% reconstruct to fields of 13x19 in exposure order\r","[mlo, options] = bmmo_field_reconstruction(mlo, options);\r","if strcmp(options.platform, 'LIS')\r","    options.model_shift.x = options.x_shift;\r","    options.model_shift.y = options.y_shift;\r","    mlo = bmmo_shift_fields(mlo, options.model_shift.x, options.model_shift.y);\r","end\r","\r","% Initialise the wafer heating fingerprint (needs reconstructed input)\r","options = bmmo_wh_options(mlo, options);\r",""],"CoverageData":{"CoveredLineNumbers":[16,18,20,21,23,24,25,27,30,31,34,35,36,37,38,42],"UnhitLineNumbers":[],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,168,0,168,0,168,7,0,7,161,161,0,161,0,0,166,166,0,0,166,166,12,12,12,0,0,0,166,0]}}