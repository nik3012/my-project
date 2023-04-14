function outlier_data = test_bmmo_convert_intel_ml(ml)
% function outlier_data = test_bmmo_convert_intel_ml(ml)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%

% XML_DIRECTORY = 'insert path here';
% ml = ovl_read_bmmo_xml(XML_DIRECTORY);

ml_intel = bmmo_convert_intel_data(ml);
[mlp, options] = bmmo_process_input(ml_intel);
results_in   = bmmo_default_model_result(mlp, options);
results_out  = bmmo_remove_outliers(results_in, options);
outlier_data = results_out.outlier_stats;