classdef  bmmo_HocPlayback < handle
% <help_update_needed>
%  for the class and for the function
%
% 
    
    properties (Abstract)
        CetConfig
    end % properties
    
    
    methods
        function  [mlHocRes, mlHocCorr, mlHocFad] = ...
                playbackTrajectories(obj, mlDisto, CetSetpoint)
            [mlHocCorr, ~, mlHocFad] = bmmo_cet_model(mlDisto, CetSetpoint, ...
                obj.CetConfig, 'return_corrections', true);
            mlHocRes = ovl_sub(mlDisto, mlHocCorr);
        end % methods
    end
    
end % classdef