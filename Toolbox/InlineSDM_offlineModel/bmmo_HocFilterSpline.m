classdef bmmo_HocFilterSpline < bmmo_HocFilter
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
                singletonObj = bmmo_HocFilterSpline();
            end
            obj = singletonObj;
        end
        
        function mlDistoFiltered = filterDistortion(mlDisto)
            mlDistoFiltered = bmmo_cet_model(mlDisto, 'VERSION_4', 'return_corrections',...
                true, 'actuation_model', 'spline(4,4)', 'intra_constr_max_order',2,...
                'bnd_constr_order',[]);
        end
    end % methods
    
end % classdef
