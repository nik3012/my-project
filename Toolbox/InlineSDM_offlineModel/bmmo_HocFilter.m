classdef (Abstract) bmmo_HocFilter < handle
% <help_update_needed>
%  for the class and for the function
%
% 
    
    properties
    end
    
    methods (Static, Abstract)
        mlDistoFiltered = filterDistortion(mlDisto)
    end
    
end