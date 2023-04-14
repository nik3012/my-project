var sourceData343 = {"FileContents":["classdef bmmo_HocActuation <  handle\r","% <help_update_needed>\r","%  for the class and for the function\r","%\r","% \r","\r","    properties\r","        cetModel\r","    end % properties\r","    \r","    properties (Constant, Hidden)\r","        validCetModel = {'THIRD_ORDER', 'FIFTH_ORDER', 'VERSION_3', 'VERSION_5'}\r","        name = 'Hoc Actuation'\r","    end % properties (Constant)\r","    \r","    \r","    methods\r","        function obj  = bmmo_HocActuation(value)\r","            assert(ismember(value, obj.validCetModel), obj.invalidMessage(value))\r","            obj.cetModel = value;\r","        end\r","        \r","        function [mlHocRes, cs] = actuationResidue(obj, mlDistoFiltered)\r","            [mlHocRes, cs] = bmmo_cet_model(mlDistoFiltered, obj.cetModel);\r","        end\r","        \r","        function error_string = invalidMessage(obj, invalid_type)\r","            error_string = sprintf('Unknown %s input %s', obj.name, invalid_type);\r","        end\r","    end % methods\r","    \r","    \r","end % classdef\r",""],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[19,20,24,28],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}