classdef  bmmoDevbench < handle
%% <help_update_needed>
%  for the class and for the function
%
%   
    properties
       ip_address; 
       fms;
       machine_name;
    end
    
    
    methods
        function obj = bmmoDevbench(ip_address, machine_id)
           obj.ip_address = ip_address; 
           obj.machine_name = machine_id;
           obj.fms = [];
        end
    end
    
    
end