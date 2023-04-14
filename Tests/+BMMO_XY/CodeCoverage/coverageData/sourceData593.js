var sourceData593 = {"FileContents":["classdef bmmo_ConfigurationParameterHocModel < bmmo_ConfigurationParameter\r","    %% bmmo_ConfigurationParameterHocModel Configures the HOC model used by inline SDM\r","    % This parameter configures the HOC model used by inline SDM. \r","    % Possible Values: Default.\r","    % This class should not be called directly, but used by\r","    % defining a bmmo_Configuration object.\r","    % See also: bmmo_Configuration, bmmo_3400B_model_configuration, \r","    % bmmo_3400C_model_configuration, bmmo_3600D_model_configuration\r","    \r","    properties (Constant, Hidden)\r","       DEFAULT = {'Default'}\r","    end\r","          \r","    methods\r","        function obj = bmmo_ConfigurationParameterHocModel(type)\r","            obj.options = [obj.DEFAULT];\r","            assert(ismember(type, obj.options), obj.invalidMessage(type));\r","            obj.value = type;\r","            obj.name = 'HocModel';\r","        end\r","    end\r","    \r","    methods \r","        function config_object = getConfigurationObject(obj, configuration)\r","            switch obj.value\r","                case obj.DEFAULT\r","                    config_object = bmmo_HocModelDefault(configuration);\r","                otherwise\r","                    error(obj.invalidMessage(obj.value));\r","            end\r","        end\r","    end\r","end"],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[16,17,18,19,25,26,27,28,29],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}