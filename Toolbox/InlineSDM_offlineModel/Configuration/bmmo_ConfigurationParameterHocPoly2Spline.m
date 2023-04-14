classdef bmmo_ConfigurationParameterHocPoly2Spline < bmmo_ConfigurationParameter
    %% bmmo_ConfigurationParameterHocPoly2Spline
    % This parameter configures the Poly2Spline setting of the CET model
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
        function obj = bmmo_ConfigurationParameterHocPoly2Spline(type)
            obj.options = [obj.ENABLED, obj.DISABLED];
            assert(ismember(type, obj.options), obj.invalidMessage(type));
            obj.value = type;
            obj.name = 'HocPoly2Spline';
        end
    end
    
    methods        
        function config_object = getConfigurationObject(obj, configuration)
            switch obj.value
                case obj.ENABLED
                    config_object = bmmo_HocPoly2SplineEnabled.getInstance();
                case obj.DISABLED
                    config_object = bmmo_HocPoly2SplineDisabled.getInstance();
                otherwise
                    error(obj.invalidMessage(obj.value));
            end
        end
    end
    
end