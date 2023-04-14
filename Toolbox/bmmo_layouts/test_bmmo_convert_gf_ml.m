function outlier_data = test_bmmo_convert_gf_ml
% function outlier_data = test_bmmo_convert_gf_ml
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%

dirname = 'GF';
ml_gf   = bmmo_convert_old_lcp_output(dirname);
[mlp, options] = bmmo_process_input(ml_gf);
results_in     = bmmo_default_model_result(mlp, options);
results_out    = bmmo_remove_outliers(results_in, options);
outlier_data   = results_out.outlier_stats;