function mlo = bmmo_undo_prev_sbc(mli)
% function mlo = bmmo_undo_prev_sbc(mli)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%

[mlp, options] = bmmo_process_input(mli);

% use WH fp per wafer for de-correction
options.WH.use_input_fp_per_wafer = 1;

% use ADELwafergrid KA for de-correction (BL3)
if options.bl3_model && isfield(options, 'KA_act_corr')
    options.previous_correction.KA = rmfield(options.previous_correction.KA, 'grid_2de');
    options.previous_correction.KA.act_corr = options.KA_act_corr;
end

mlo = bmmo_undo_sbc_corr_inlineSDM(mlp, options);