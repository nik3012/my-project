function options_out = bmmo_get_configuration_data(mli, options_in)
%function options_out = bmmo_get_configuration_data(mli, options_in)
%
% This function copies the configuration data in mli to options_out
%
% Input :     
% mli:          input structure to the drift control model
% options_in:   existing options structure
%
% Ouput :
% options_out:  options structure with configuration data from mli

options_out = options_in;

if isfield(mli.info.configuration_data, 'susd_correction_enabled')
        options_out.susd_control = mli.info.configuration_data.susd_correction_enabled;    
end

if isfield(mli.info.configuration_data, 'KA_correction_enabled')
    options_out.KA_control = mli.info.configuration_data.KA_correction_enabled;
    options_out.KA_measure_enabled = 1;
    
    if isfield(mli.info.configuration_data, 'KA_measure_enabled')
        options_out.KA_measure_enabled = mli.info.configuration_data.KA_measure_enabled;
    end
end

if isfield(mli.info.configuration_data, 'invert_MI_wsm_sign')
    options_out.invert_MI_wsm_sign = mli.info.configuration_data.invert_MI_wsm_sign;
end

if isfield(mli.info.configuration_data, 'platform')
    options_out.platform = mli.info.configuration_data.platform;
    if strcmp(options_out.platform, 'LIS')
        options_out.intraf_resample_options.interp_type = 'cubic';
    end
end

if isfield(mli.info.configuration_data,'intraf_actuation')
    options_out.intraf_actuation_order = mli.info.configuration_data.intraf_actuation;
end
options_out = bmmo_options_intraf(options_out);

if isfield(mli.info.configuration_data, 'KA_actuation') && ~isempty(mli.info.configuration_data.KA_actuation)
    if strcmp(mli.info.configuration_data.KA_actuation, 'HOC')
        options_out.KA_actuation.type = '33par';
        options_out.KA_actuation.fnhandle = @bmmo_KA_33par_fingerprint;
    elseif contains(mli.info.configuration_data.KA_actuation, {'ORDER','VERSION'})
        options_out.KA_actuation.type = mli.info.configuration_data.KA_actuation;
        options_out.KA_actuation.fnhandle = @bmmo_KA_HOC_fingerprint;
    elseif strcmp(mli.info.configuration_data.KA_actuation, 'LOC')
        options_out.KA_actuation.type = 'LOC';
        options_out.KA_actuation.fnhandle = @bl3_KA_LOC_fingerprint;
    end
end
