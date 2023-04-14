classdef bmmo_HocPoly2SplineDisabled < bmmo_HocPoly2Spline
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
                singletonObj = bmmo_HocPoly2SplineDisabled();
            end
            obj = singletonObj;
        end
        
        function cs = getOptions(CetSetpoint)
            cs = CetSetpoint;
        end
    end % methods (Singleton)
    
end %classdef