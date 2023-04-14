classdef bmmo_HocFilter33Par < bmmo_HocFilter
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
                singletonObj = bmmo_HocFilter33Par();
            end
            obj = singletonObj;
        end
        
        function mlDistoFiltered = filterDistortion(mlDisto)
            options = bl3_default_options_structure;
            mlResfilter = ovl_model(mlDisto, options.CET33par.name, 'perwafer', 'perfield');
            mlDistoFiltered = ovl_sub(mlDisto, mlResfilter);
        end
    end % methods
    
end %classdef