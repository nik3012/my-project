var sourceData418 = {"FileContents":["function outlier_data = test_bmmo_convert_gf_ml\r","% function outlier_data = test_bmmo_convert_gf_ml\r","% <help_update_needed>\r","%\r","% <short description>\r","% input:\r","% output:\r","%\r","%\r","\r","dirname = 'GF';\r","ml_gf   = bmmo_convert_old_lcp_output(dirname);\r","[mlp, options] = bmmo_process_input(ml_gf);\r","results_in     = bmmo_default_model_result(mlp, options);\r","results_out    = bmmo_remove_outliers(results_in, options);\r","outlier_data   = results_out.outlier_stats;"],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[11,12,13,14,15,16],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}