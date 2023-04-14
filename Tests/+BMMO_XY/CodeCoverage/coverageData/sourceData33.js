var sourceData33 = {"FileContents":["function corr_out = bmmo_add_missing_corr(corr_in, depth, options)\r","% function corr_out = bmmo_add_missing_corr(corr_in, depth, options)\r","%\r","% Given a bmmo correction structure with some corrections missing,\r","% completes the structure by adding zero corrections\r","%\r","% Input\r","%   corr_in: bmmo correction structure with some corrections (as defined in\r","%            bmmo_default_output structure) missing\r","%   depth:   depth of subfields to add to the input structure (default = 2)\r","%   options: bmmo or bl3 options structure (default = bmmo)\r","%\r","% Output\r","%   corr_out: bmmo correction structure as defined in\r","%             bmmo_default_output_structure\r","\r","if nargin < 3\r","    if isfield(corr_in, 'KA') && isfield(corr_in.KA, 'grid_2de')\r","        BL3_KA_MEAS_LENGTH = 90601;\r","        \r","        if length(corr_in.KA.grid_2de(1).x) >= BL3_KA_MEAS_LENGTH\r","            options = bl3_default_options_structure;\r","        else\r","            options = bmmo_default_options_structure;\r","        end\r","    else\r","        options = bmmo_default_options_structure;\r","    end\r","end\r","\r","if nargin < 2\r","    depth = 2;\r","end\r","\r","empty_corr = bmmo_default_output_structure(options);\r","\r","corr_out = bmmo_add_missing_fields(corr_in, empty_corr.corr, depth);\r","\r","end\r","\r",""],"CoverageData":{"CoveredLineNumbers":[17,18,19,21,22,23,24,31,32,35,37],"UnhitLineNumbers":[26,27],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,206,197,197,0,197,1,196,196,0,0,0,0,0,0,206,18,0,0,206,0,206,0,0,0,0]}}