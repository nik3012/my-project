function inline_sdm_config = bmmo_get_inline_sdm_configuration(mli)
% function inline_sdm_config = bmmo_get_inline_sdm_configuarion(mli)
%
% This function determines the inlineSDM configuration data based on machine
% type(e.g.'NXE:3400C') and inline SDM model type
% (e.g. 'BMMO NXE' or 'BaseLiner 3')
%
% Input:
%  mli: input structure to the drift control model with following
%  fields:
%     info.report_data.inline_sdm_model (optional field)
%     mli.info.F.machine_type
%
% Output :
% inline_sdm_config: fnhandle for inline_SDM configuration


inline_sdm_config.machine_type = mli.info.F.machine_type;

if endsWith(inline_sdm_config.machine_type, {'3300B', '3350B'})
    inline_sdm_config.fnhandle = @bmmo_3350B_model_configuration;
    
elseif endsWith(inline_sdm_config.machine_type, {'3400B', '3400B_OFP', '3400C'})
    inline_sdm_config.fnhandle = @bmmo_3400C_model_configuration;
    
elseif endsWith(inline_sdm_config.machine_type, '3600D_ES')
    inline_sdm_config.fnhandle = @bmmo_3600D_ES_model_configuration;
    
elseif endsWith(inline_sdm_config.machine_type, '3600D')
    if isfield(mli.info.report_data, 'inline_sdm_model')
        inline_sdm_config.sdm_model = mli.info.report_data.inline_sdm_model;
        if strcmp(inline_sdm_config.sdm_model, 'BMMO NXE')
            inline_sdm_config.fnhandle = @bmmo_3600D_model_configuration;
        elseif strcmp(inline_sdm_config.sdm_model, 'BaseLiner 3')
            inline_sdm_config.fnhandle = @bl3_3600D_model_configuration;
        end
    else
        inline_sdm_config.fnhandle = @bmmo_3600D_SP19_model_configuration;
    end
end


end

