classdef bmmo_HocPoly2SplineEnabled < bmmo_HocPoly2Spline
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
                singletonObj = bmmo_HocPoly2SplineEnabled();
            end
            obj = singletonObj;
        end
    end
    
    methods (Static)
        function cs = getOptions(CetSetpoint)
            cs = arrayfun(@(x) x.poly2spline(), CetSetpoint);
        end
    end
    
end