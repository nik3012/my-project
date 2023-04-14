classdef bmmo_ConfigurationParameterHocFilter < bmmo_ConfigurationParameter
    %% bmmo_ConfigurationParameterHocFilter Configures Filter used in HOC model
    % This parameter configures the model used to filter the inline SDM 
    % HOC model input before sending it to CET.
    % Possible Values:
    %                   33Par  : 33 par limiter
    %                   Order5 : 5th order filter
    %                   Spline : spline filter
    %                   None   : no filtering
    % This class should not be called directly, but used by
    % defining a bmmo_Configuration object.
    % See also: bmmo_Configuration, bmmo_3400B_model_configuration, 
    % bmmo_3400C_model_configuration, bmmo_3600D_model_configuration
    
    properties (Constant, Hidden)
       THIRTY_THREE_PAR = {'33Par'};
       FIFTH_ORDER = {'Order5'}
       SPLINE = {'Spline'}  
       NONE = {'None'}
    end
          
    methods
        function obj = bmmo_ConfigurationParameterHocFilter(type)
            obj.options = [obj.THIRTY_THREE_PAR, obj.FIFTH_ORDER, ...
                obj.SPLINE, obj.NONE];
            assert(ismember(type, obj.options), obj.invalidMessage(type));
            obj.value = type;
            obj.name = 'HocFilter';
        end
    end
    
    methods        
        function config_object = getConfigurationObject(obj, configuration)
            switch obj.value
                case obj.THIRTY_THREE_PAR
                    config_object = bmmo_HocFilter33Par.getInstance();
                case obj.FIFTH_ORDER
                    config_object = bmmo_HocFilterOrder5.getInstance();
                case obj.SPLINE
                    config_object = bmmo_HocFilterSpline.getInstance();
                case obj.NONE
                    config_object = bmmo_HocFilterNone.getInstance();
                otherwise
                    error(obj.invalidMessage(obj.value));
            end
        end
    end
end