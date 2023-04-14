classdef bmmo_HocPlaybackDisabled < bmmo_HocPlayback
% <help_update_needed>
%  for the class and for the function
%
% 
    
    properties
        CetConfig
    end  % properties
    
    methods % constructor
        function obj = bmmo_HocPlaybackDisabled(value)
            obj.CetConfig = value.getConfigurationObject('CetModel').cetModel;
        end % methods (constructor)
    end
    
end %classdef