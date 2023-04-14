classdef bmmo_ConfigurationParameterCetModel < bmmo_ConfigurationParameter
    %% bmmo_ConfigurationParameterCetModel Configures CET model setting
    % This parameter configures the CET model version used during actuation
    % simulation. 
    % Possible Values: THIRD_ORDER, FIFTH_ORDER, VERSION_3, VERSION_5. 
    % This class should not be called directly, but used by
    % defining a bmmo_Configuration object.
    % See also: bmmo_Configuration, bmmo_3400B_model_configuration, 
    % bmmo_3400C_model_configuration, bmmo_3600D_model_configuration
    
    properties (Constant, Hidden)
        THIRD_ORDER = {'THIRD_ORDER'}
        FIFTH_ORDER = {'FIFTH_ORDER'}
        VERSION_3   = {'VERSION_3'}
        VERSION_5   = {'VERSION_5'}
    end
    
    methods
        function obj = bmmo_ConfigurationParameterCetModel(type)
            obj.options = [obj.THIRD_ORDER, obj.FIFTH_ORDER, ...
                obj.VERSION_3, obj.VERSION_5];
            assert(ismember(type, obj.options), obj.invalidMessage(type));
            obj.value = type;
            obj.name = 'CetModel';
        end
    end
    
    methods
        function config_object = getConfigurationObject(obj, configuration)
            switch obj.value
                case obj.THIRD_ORDER
                    config_object = bmmo_HocActuation('THIRD_ORDER') ;
                case obj.FIFTH_ORDER
                    config_object = bmmo_HocActuation('FIFTH_ORDER') ;
                case obj.VERSION_5
                    config_object = bmmo_HocActuation('VERSION_5') ;
                case obj.VERSION_3
                    config_object = bmmo_HocActuation('VERSION_3') ;
                otherwise
                    error(obj.invalidMessage(obj.value));
            end
        end
    end
    
end