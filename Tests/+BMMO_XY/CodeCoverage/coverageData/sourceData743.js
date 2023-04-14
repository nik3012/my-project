var sourceData743 = {"FileContents":["function mlo = bmmo_generate_INTRAF(template_mli, options)\r","% function mlo = bmmo_generate_INTRAF(template_mli, options)\r","%\r","% Given an ml input and an options structure,\r","% generate an intrafield fingerprint\r","%\r","% Input:\r","%        template_mli: input ml structure\r","%        options: bmmo options structure\r","%\r","% Output: mlo: Intrafield fingerprint ml structure, based on template_mli\r","%\r","% 20200526 SELR Creation, refactored from bmmo_simulate_random_input\r","\r","% Get non-linear Intrafield parameters\r","pars = options.INTRAF.name(5:end);\r","n_pars = length(pars);\r","scaling = options.INTRAF.scaling(5:end);\r","\r","\r","% Set K13 & K20 to zero if present\r","ind = arrayfun(@(x) strcmp(x, 'd3') | strcmp(x, 'flw3y'), pars);\r","scaling(ind) = 0;\r","\r","intraf_rand{1} = randn(1, n_pars);\r","intraf_rand{2} = randn(1, n_pars);\r","for iw = 1:template_mli.nwafer\r","    for ipar = 1:n_pars\r","        scale = (scaling(ipar))/options.scaling_factor;\r","        INTRAF_par.wafer(iw).(pars{ipar}) = intraf_rand{2 - mod(iw,2)}(ipar)*scale;\r","    end\r","end\r","\r","mlz = ovl_combine_linear(template_mli, 0 );\r","\r","mlF = ovl_average_fields(mlz);\r","mlF = ovl_model(mlF, 'apply', INTRAF_par, 'perwafer');\r","% Simulate measurement at RINT microshift\r","if strcmp(options.platform, 'OTAS')\r","    mlo_rint = bmmo_shift_fields(mlF, options.x_shift, options.y_shift);\r","    mlF = bmmo_resample(mlF, mlo_rint, options.intraf_resample_options);\r","    mlF = bmmo_shift_fields(mlF, -options.x_shift, -options.y_shift);\r","    mlF = bmmo_fit_model_perwafer(mlF, options, 'tx', 'ty', 'ms', 'ma', 'rs', 'ra');\r","end\r","mlF = scale2one(mlF);\r","mlo = ovl_distribute_field(mlF, mlz);\r","mlo = bmmo_model_BAO(mlo, options);\r","mlo = ovl_combine_linear(template_mli, 0, mlo, 1);\r","\r","\r","function mlo = scale2one(mli)\r","\r","mlo = mli;\r","for iw=1:mli.nwafer\r","    mlo.layer.wr(iw).dx = mli.layer.wr(iw).dx *(1/max(abs(mli.layer.wr(iw).dx)))*1e-9;\r","    mlo.layer.wr(iw).dy = mli.layer.wr(iw).dy *(1/max(abs(mli.layer.wr(iw).dy)))*1e-9;\r","end\r",""],"CoverageData":{"CoveredLineNumbers":[16,17,18,22,23,25,26,27,28,29,30,34,36,37,39,40,41,42,43,45,46,47,48,53,54,55,56],"UnhitLineNumbers":[],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,1,1,0,1,1,1,6,84,84,0,0,0,1,0,1,1,0,1,1,1,1,1,0,1,1,1,1,0,0,0,0,1,1,6,6,0,0]}}