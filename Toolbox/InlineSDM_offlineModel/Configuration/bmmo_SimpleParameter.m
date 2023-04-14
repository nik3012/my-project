classdef (Abstract) bmmo_SimpleParameter < bmmo_ConfigurationParameter
    %% bmmo_SimpleParameter definition of a simple parameter
    % A simple parameter has no associated object, but simply returns a
    % value.
    % See also: bmmo_Configuration, bmmo_ConfigurationParameter,
    % bmmo_ConfigurationParameterFactory
    methods
        function obj = bmmo_SimpleParameter()
           obj.options = {}; 
        end
    end
    
    methods
        function value = getConfigurationObject(obj, configuration)
            value = obj.value;
        end
        
        function setValue(obj, value)
           obj.value = value; 
        end
    end
end