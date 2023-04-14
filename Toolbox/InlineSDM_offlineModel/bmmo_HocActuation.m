classdef bmmo_HocActuation <  handle
% <help_update_needed>
%  for the class and for the function
%
% 

    properties
        cetModel
    end % properties
    
    properties (Constant, Hidden)
        validCetModel = {'THIRD_ORDER', 'FIFTH_ORDER', 'VERSION_3', 'VERSION_5'}
        name = 'Hoc Actuation'
    end % properties (Constant)
    
    
    methods
        function obj  = bmmo_HocActuation(value)
            assert(ismember(value, obj.validCetModel), obj.invalidMessage(value))
            obj.cetModel = value;
        end
        
        function [mlHocRes, cs] = actuationResidue(obj, mlDistoFiltered)
            [mlHocRes, cs] = bmmo_cet_model(mlDistoFiltered, obj.cetModel);
        end
        
        function error_string = invalidMessage(obj, invalid_type)
            error_string = sprintf('Unknown %s input %s', obj.name, invalid_type);
        end
    end % methods
    
    
end % classdef
