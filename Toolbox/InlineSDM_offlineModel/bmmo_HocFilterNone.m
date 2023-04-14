classdef bmmo_HocFilterNone < bmmo_HocFilter
 % <help_update_needed>
%  for the class and for the function
%
% 
   
    properties
    end
    
    methods  (Static)    % Pattern for singleton object in Matlab
        function obj = getInstance()
            persistent singletonObj;
            if isempty(singletonObj)
                singletonObj = bmmo_HocFilterNone();
            end
            obj = singletonObj;
        end
        
        function mlDistoFiltered = filterDistortion(mlDisto)
            mlDistoFiltered = mlDisto;
        end
    end % methods
    
end % classdef