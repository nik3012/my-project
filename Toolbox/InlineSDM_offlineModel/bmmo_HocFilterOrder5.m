classdef bmmo_HocFilterOrder5 < bmmo_HocFilter
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
                singletonObj = bmmo_HocFilterOrder5();
            end
            obj = singletonObj;
        end
        
        function mlDistoFiltered = filterDistortion(mlDisto)
            mlDistoFiltered = ovl_cet_model(mlDisto, 'FIFTH_ORDER', 'return_corrections',true);
        end
    end % methods
    
end % classdef
