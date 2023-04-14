classdef bmmo_ConfigurationParameter < handle
    %% bmmo_ConfigurationParameter Abstract definition of a configuration parameter
    % See also: bmmo_Configuration, bmmo_ConfigurationParameter,
    % bmmo_ConfigurationParameterFactory
    
    properties (SetAccess = protected)
        name
        value
        options
    end
    
    
    methods (Abstract)
        config_object = getConfigurationObject(obj, configuration);
    end
    
    methods
        function error_string = invalidMessage(obj, invalid_type)
            error_string = sprintf('Unknown %s type %s', obj.name, invalid_type);
        end
        
        function value = getValue(obj)
            value = obj.value;
        end
        
        function options = getOptions(obj)
            options = obj.options;
        end
        
        function disp(obj)
           if ~ischar(obj.value)
               valuestring = num2str(obj.value);
           else
               valuestring = obj.value;
           end
           fprintf('%s:  %s\n', obj.name, valuestring);
        end
    end   
end