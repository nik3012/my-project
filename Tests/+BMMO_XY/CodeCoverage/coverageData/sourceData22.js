var sourceData22 = {"FileContents":["function ka_grid_meas = bmmo_KA_grid_expose_to_meas(ka_grid_exp, options)\r","%function ka_grid_meas = bmmo_KA_grid_expose_to_meas(ka_grid_exp, options)\r","%\r","% This function generates KA@M correction using KA@E correction of a chuck.\r","% BMMO or BL3 KA@M corrections are generated based on the provided BMMO or BL3\r","% option structures, respectively.\r","%\r","% Input:\r","%  ka_grid_exp: KA@E grid correction (one chuck only)\r","%  options: BMMO/BL3 option structure\r","% \r","% Output:\r","% ka_grid_meas: KA@M grid correction (one chuck only)\r","\r","ka_grid_meas = bmmo_KA_grid_subset(ka_grid_exp, options.KA_meas_start);\r","\r","ka_grid_meas.dx = -1*ka_grid_meas.dx;\r","ka_grid_meas.dy = -1*ka_grid_meas.dy;\r","\r","ka_grid_meas = bmmo_KA_fix_interpolant(ka_grid_meas);"],"CoverageData":{"CoveredLineNumbers":[15,17,18,20],"UnhitLineNumbers":[],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,12,0,12,12,0,12]}}