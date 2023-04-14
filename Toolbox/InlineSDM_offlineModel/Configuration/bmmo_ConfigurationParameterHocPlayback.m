classdef bmmo_ConfigurationParameterHocPlayback < bmmo_ConfigurationParameter
    %% bmmo_ConfigurationParameterHocPlayback
    % This parameter configures 'PLAYBACK' setting of the CET model when
    % when used in the inline SDM HOC model. 
    % Possible Values: Enabled, Disabled.
    % This class should not be called directly, but used by
    % defining a bmmo_Configuration object.
    % See also: bmmo_Configuration, bmmo_3400B_model_configuration, 
    % bmmo_3400C_model_configuration, bmmo_3600D_model_configuration
    
    properties (Constant, Hidden)
        ENABLED = {'Enabled'}
        DISABLED = {'Disabled'}
    end
    
    methods
        function obj = bmmo_ConfigurationParameterHocPlayback(type)
            obj.options = [obj.ENABLED, obj.DISABLED];
            assert(ismember(type, obj.options), obj.invalidMessage(type));
            obj.value = type;
            obj.name = 'HocPlayback';
        end
    end
    
    methods        
        function config_object = getConfigurationObject(obj, configuration)
            switch obj.value
                case obj.ENABLED
                    config_object = bmmo_HocPlaybackEnabled();
                case obj.DISABLED
                    config_object = bmmo_HocPlaybackDisabled(configuration);
                otherwise
                    error(obj.invalidMessage(obj.value));
            end
        end
    end
    
end