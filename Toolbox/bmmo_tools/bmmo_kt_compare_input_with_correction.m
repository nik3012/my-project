function bmmo_kt_compare_input_with_correction(ml, fps)
% function bmmo_kt_compare_input_with_correction(ml, fps)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%
[~, options] = bmmo_process_input(ml);

mlc = bmmo_average_chuck(ml, options);
fpsc = bmmo_average_chuck(fps.TotalSBCcorrection, options);

options.sum = 1;
bmmo_kt_plot_6_fps(mlc, fpsc, 'Input', 'Total Correction', options);