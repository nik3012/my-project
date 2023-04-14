var sourceData68 = {"FileContents":["function fps = bmmo_construct_wh_dd_FPS (mli, options)\r","% function fps = bmmo_construct_wh_dd_FPS (mli, options)\r","%\r","% This function generates the fingerprints needed for WH or SUSD combined\r","% model\r","%\r","% Input:\r","%  mli: BMMO/Bl3 processed input, contains WH fingerprints during exposure\r","%   in mli.info\r","%\r","% Output:\r","%  fps: Generated fingerprints (cell array of ml structures)\r","%   fps{1} : WHFP on chuck(1)\r","%   fps{2} : WHFP on chuck(2)\r","%   Remining are fingerprints specified in options.combined_model_contents\r","%\r","% For details of the model and definitions of in/out interfaces, refer to\r","% D000810611 EDS BMMO NXE drift control model\r","\r","% get all-zero single layer ml struct as basis\r","ml = ovl_get_layers(ovl_get_wafers(mli(1),1),1);\r","ml_zero = ovl_create_dummy(ml);\r","\r","% The WH fingerprint is always in the combined model as the first element\r","fps = bmmo_construct_FPS_WH(ml_zero, options);\r","\r","% Loop over the rest of the combined model contents\r","fp_types_length = length(options.combined_model_contents);\r","for ifp = 1:fp_types_length\r","    % get the function handle from the model name\r","    cm_fn = options.cm.(options.combined_model_contents{ifp}).fnhandle;\r","    \r","    % execute the model\r","    fp_cell = feval(cm_fn, ml_zero, options);\r","    \r","    fps = [fps, fp_cell];\r","end\r","\r","\r","\r",""],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[21,22,25,28,29,31,34,36],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}