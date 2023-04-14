classdef bmmo_HocModel < handle
%% bmmo_HocModel Abstract definition of BMMO & BL3 NXE HOC model.
    %
    % This class should not be called directly
    %
    % This class defines the (abstract) properties & methods that each
    % HOC model sub-class should contain
    %
    % See also:
    %   bmmo_HocModelDefault
    
    methods(Abstract)
        run(obj)
        calcActuation(obj)
        calcReport(obj)
    end
    
end
