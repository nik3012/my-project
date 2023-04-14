classdef bmmo_InlineSdmModel < handle
%% bmmo_InlineSdmModel Abstract definition of BMMO & BL3 NXE inline SDM model.
    %
    % This class should not be called directly
    %
    % This class defines the (abstract) properties & methods that each
    % inline SDM model sub-class should contain
    %
    % See also:
    %   bmmo_InlineSdmModelDefault
    
    properties(SetObservable)
        lensModel % bmmo_LensModel object
        hocModel  % bmmo_HocModel  object
    end
    
    methods(Abstract)
        run(obj)
        calcActuation(obj)
        calcReport(obj)
    end
    methods
        function obj = bmmo_InlineSdmModel(configuration)
            %bmmo_InlineSdmModel This class is abstract and cannot be
            %instantiated. This method is used by its subclasses
            if nargin < 1
                configuration = bmmo_3400C_model_configuration;
            end
            obj.lensModel = configuration.getConfigurationObject('LensModel');
            obj.hocModel  = configuration.getConfigurationObject('HocModel');
        end
    end
end

