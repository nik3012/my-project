classdef bmmo_ConfigurationParameterLens < bmmo_ConfigurationParameter & bmmo_SimpleParameter
    %% bmmo_ConfigurationParameterLens Configures Lens type used in the Lens model
    % This parameter configures the Lens model used by inline SDM. 
    % Possible Values: 3400_34, 3300_33.
    % This class should not be called directly, but used by
    % defining a bmmo_Configuration object.
    % See also: bmmo_Configuration, bmmo_3400B_model_configuration, 
    % bmmo_3400C_model_configuration, bmmo_3600D_model_configuration
          
    methods
        function obj = bmmo_ConfigurationParameterLens(value)
            obj.value = value;
            obj.name = 'Lens';
        end
    end
end