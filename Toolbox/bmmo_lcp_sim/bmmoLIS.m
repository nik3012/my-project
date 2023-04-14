classdef  bmmoLIS < handle
%% <help_update_needed>
%  for the class and for the function
%
%      
    properties
       ip_address;
       platform;
    end    
    
    methods
        function obj = bmmoLIS(ip_address, platform)
           obj.ip_address = ip_address;
           obj.platform = platform;
        end
    end    
end