function options = bmmo_ml_options(mli, options)
%function options = bmmo_ml_options(mli, options)
%
% This function will transfer data from mli.info to options structure. Data
% from mli.info is gathered from multiple ADEL files from scanner.
%
% Input :
% mli    : input ml struct
% options: existing options structure
%
% Ouput :
% options: parsed options structure
%
% For details of the model and definitions of in/out interfaces, refer to
% D000810611 EDS BMMO NXE drift control model

% options from ml.info structure
options.Scan_direction      = mli.info.report_data.Scan_direction;
options.FIWA_translation    = mli.info.report_data.FIWA_translation;
options.fieldsize = [mli.info.F.image_size.x mli.info.F.image_size.y];
if isfield(mli.info.F, 'image_shift')
    options.image_shift =  [mli.info.F.image_shift.x mli.info.F.image_shift.y];
end

% Previous correction: including inline SDM residual
options.previous_correction = bmmo_add_missing_corr(mli.info.previous_correction, 2);
if isfield(mli.info.report_data, 'inline_sdm_residual')
    for ic = 1:length(options.previous_correction.ffp)
        options.previous_correction.ffp(ic).dx = options.previous_correction.ffp(ic).dx - mli.info.report_data.inline_sdm_residual(ic).dx;
        options.previous_correction.ffp(ic).dy = options.previous_correction.ffp(ic).dy - mli.info.report_data.inline_sdm_residual(ic).dy;
    end
end

options = bmmo_ml_options_wh(mli, options);

% Handle options introduced since test data finalised
if(length(mli.expinfo.xc) == 89)
    options.no_layer_to_use = 1;
elseif (length(mli.expinfo.xc) == 167)
    options.no_layer_to_use = 2;
else
    options.no_layer_to_use = 1;
    options.layer_fields{1} = 1:length(mli.expinfo.xc);
    options.layer_fields = options.layer_fields(1);
end

%Enable SUSD and/or KA correction
if isfield(mli.info, 'configuration_data')
    options = bmmo_get_configuration_data(mli, options);
end
options.inline_sdm_config = bmmo_get_inline_sdm_configuration(mli);
options = bmmo_set_model_configuration(options);

options = bmmo_get_xy_shift(mli, options);

options.chuck_usage  = bmmo_determine_chuck_usage(mli);

options = bmmo_get_submodel_options(options);

% parse combined model options; this must only be called after the number of
% chucks is known
options.cm = bmmo_get_cm_options(options);

% enable time filtering if present
if isfield(mli.info.report_data, 'time_filtering_enabled')
    if mli.info.report_data.time_filtering_enabled
        % SOURCE: MIAT mail to SBPR 20160624
        coeff.WH = 0.4;
        coeff.MI = 0.3;
        coeff.BAO = 0.5;
        coeff.KA = 0.3;
        coeff.INTRAF = 0.4;
        coeff.SUSD = 0.4;
        
        options.filter.coefficients = coeff;
        
        % in case overruling parameters are provided by customer: overrule
        % what can be overruled: weight factor for adaptive filter, and T1/T2
        % for adaptive filter
        if isfield(mli.info, 'configuration_data')
            if isfield(mli.info.configuration_data, 'filter')
                options.filter.coefficients = sub_replace_filter_coeff_defaults(options.filter.coefficients, mli.info.configuration_data.filter);
                options.filter = sub_replace_filter_config_defaults(options.filter, mli.info.configuration_data.filter);
            end
        end
        
        if isfield(mli.info.report_data, 'adaptive_time_filter_enabled')
            if mli.info.report_data.adaptive_time_filter_enabled
                
                if isfield(mli.info.report_data, 'T_current_expose')
                    if isfield(mli.info.report_data, 'T_previous_expose')
                        options.filter = sub_replace_filter_expose_defaults(options.filter, mli.info.report_data);
                    end
                end
                
                % get max wafers per chuck
                wafers_per_chuck = max([numel(find(options.chuck_usage.chuck_id == 1)), numel(find(options.chuck_usage.chuck_id == 2))]);
                
                % validate T1, T2,
                if options.filter.T2 <= options.filter.T1
                    error('Incorrect dynamic filter definition: T1 > T2');
                end
                if options.filter.T_current_expose <= options.filter.T_previous_expose
                    error('Incorrect dynamic filter definition: previous exposure later than current');
                end
                
                % set dynamic time filter coefficients
                options.filter.coefficients = bmmo_get_dynamic_filter_coefficients(options.filter.coefficients, ...
                    options.filter.T_current_expose - options.filter.T_previous_expose, ...
                    wafers_per_chuck, options.filter.T1, options.filter.T2, options.platform);
            end
        end
        
    end
end

% parse ml.configurable_options
if isfield(mli, 'configurable_options')
    options = bmmo_parse_configurable_options(options, mli.configurable_options);
    options = bmmo_get_submodel_options(options);
    options.cm = bmmo_get_cm_options(options);
end

%% End of main function, subfunctions below


function filter = sub_replace_filter_coeff_defaults(filter, configuration_data)

% map from input struct field names to options.filter field names
filter_fieldnames = {'coeff_MI', 'coeff_KA', 'coeff_WH', 'coeff_BAO', 'coeff_ffp', 'coeff_SUSD'};
options_fieldnames = {'MI', 'KA', 'WH', 'BAO', 'INTRAF', 'SUSD'};

filter = sub_update_fields(filter, configuration_data, options_fieldnames, filter_fieldnames);

function filter = sub_replace_filter_config_defaults(filter, configuration_data)

% map from input struct field names to options.filter field names
filter_fieldnames = {'T1', 'T2'};

filter = sub_update_fields(filter, configuration_data, filter_fieldnames, filter_fieldnames);

function filter = sub_replace_filter_expose_defaults(filter, report_data)

% map from input struct field names to options.filter field names
filter_fieldnames = {'T_previous_expose', 'T_current_expose'};

filter = sub_update_fields(filter, report_data, filter_fieldnames, filter_fieldnames);

function s_out = sub_update_fields(s_out, s_in, fields_out, fields_in)

for ii = 1:length(fields_out)
    if isfield(s_in, fields_in{ii})
        s_out.(fields_out{ii}) = s_in.(fields_in{ii});
    end
end
