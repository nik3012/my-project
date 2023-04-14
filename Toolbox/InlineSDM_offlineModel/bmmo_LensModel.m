classdef bmmo_LensModel < handle
%% bmmo_LensModel Abstract definition of BMMO & BL3 NXE Lens model.
    %
    % This class should not be called directly
    %
    % This class defines the (abstract) properties & methods that each
    % Lens model sub-class should contain
    %
    % See also:
    %   bmmo_LensModelDefault
    
    properties
        lensType % lensType used by ovl_metro_get_lensdata
    end
    
    methods(Abstract)
        run(obj)
    end
    methods
        function obj = bmmo_LensModel(configuration)
            %bmmo_LensModel This class is abstract and cannot be
            %instantiated. This method is used by its subclasses
            obj.lensType = configuration.getConfigurationObject('Lens');
        end
    end
end

