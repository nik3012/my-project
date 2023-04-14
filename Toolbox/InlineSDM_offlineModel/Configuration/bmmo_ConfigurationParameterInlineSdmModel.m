classdef bmmo_ConfigurationParameterInlineSdmModel < bmmo_ConfigurationParameter
    %% bmmo_ConfigurationParameterInlineSdmModel Chooses inline SDM model
    % This parameter chooses which inline SDM model to use.
    % Possible Values: Default
    % This class should not be called directly, but used by
    % defining a bmmo_Configuration object.
    % See also: bmmo_Configuration, bmmo_3400B_model_configuration, 
    % bmmo_3400C_model_configuration, bmmo_3600D_model_configuration
    
    properties (Constant, Hidden)
       DEFAULT = {'Default'}
    end
          
    methods
        function obj = bmmo_ConfigurationParameterInlineSdmModel(type)
            obj.options = [obj.DEFAULT];
            assert(ismember(type, obj.options), obj.invalidMessage(type));
            obj.value = type;
            obj.name = 'InlineSdmModel';
        end
    end
    
    methods 
        function config_object = getConfigurationObject(obj, configuration)
            switch obj.value
                case obj.DEFAULT
                    config_object = bmmo_InlineSdmModelDefault(configuration);
                otherwise
                    error(obj.invalidMessage(obj.value));
            end
        end
    end
end