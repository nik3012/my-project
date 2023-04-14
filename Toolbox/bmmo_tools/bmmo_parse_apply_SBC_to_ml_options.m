function options = bmmo_parse_apply_SBC_to_ml_options(ml_template, options)
% function options = bmmo_parse_apply_SBC_to_ml(ml_template, options)
%
% This function updates the options structure with the info needed for
% bmmo_apply_SBC_to_ml, found in ml_template.
% The expected data is:
% ml_template.info.F.chuck_id: {'CHUCK_ID_1', 'CHUCK_ID_2'} (1 x nwafer)
% ml_template.info.report_data.Scan_direction: [1 -1 1 -1 1 1] (nfield x 1)
% ml_template.expinfo.field_size: [x, y]
% WH data from ADELwaferHeatingCorrectionsReport imported using bmmo_kt_process_adelwhc_input
%
% For missing fields, it will fallback to bmmo default values.
%
% Input:
% ml_template: input ml structure
% options: bmmo/bl3 options structure
% 
% Output:
% options: updated bmmo/bl3 options structure

try
    options.chuck_usage = bmmo_determine_chuck_usage(ml_template);
catch
    options.chuck_usage.chuck_id = options.chuck_usage.chuck_id(1:ml_template.nwafer);
    options.chuck_usage = bmmo_get_chuck_id_used(options.chuck_usage);
    options.chuck_usage.nr_chuck_used = length(unique(options.chuck_usage.chuck_id));
    warning('No chuck usage available in ml_template, unsing chuck order in (default) BMMO options');     
end

try
    options.Scan_direction = ml_template.info.report_data.Scan_direction;
catch
    options.Scan_direction = options.Scan_direction(1:ml_template.nfield);
    options.Scan_direction = repmat(options.Scan_direction, [1, ml_template.nlayer]);
    warning('No Scan direction available in ml_template, using scan direction in (default) BMMO options');
end

try
    options.fieldsize = [ml_template.info.F.image_size.x ml_template.info.F.image_size.y];
catch
    warning('No field size available in ml_template, using BMMO field size');
end

try
    options = bmmo_ml_options_wh(ml_template, options);
    options = bmmo_wh_options(ml_template, options);
catch
    warning('No WH info available in ml, using 0 WH fingerprint');
    if isfield(options.WH, 'input_fp_per_chuck')
        options.WH = rmfield(options.WH, 'input_fp_per_chuck');
    end
    options.WH.fp = ovl_create_dummy(ml_template);
    for ichuck = 1 : length(options.chuck_usage.chuck_id_used)
        options.WH.input_fp_per_chuck(options.chuck_usage.chuck_id_used(ichuck)) = ovl_get_wafers(options.WH.fp, 1);
    end
    options.previous_correction.IR2EUV = 0;
    options.IR2EUVsensitivity = 1;
end