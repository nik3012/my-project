classdef bmmoGenericAdelInterface < handle
 %% <help_update_needed>
%  for the class and for the function
%
%      
    properties
       options %  matlab.net.http.HTTPOptions structure
    end
    
    methods
        function obj = bmmoGenericAdelInterface(config)
           obj.options = matlab.net.http.HTTPOptions;
           obj.options.ConvertResponse = 0; 
        end     
    end
     
    methods
        function adel_data = getAdelInstance(obj, adel_name, adel_version, repetitions)
            if nargin < 4
                repetitions = 2;
            end
            uri = sprintf('https://xmlschema.asml.com/DIY/Instance?publicUrl=http://xmlschema.asml.com/api/getSchema.xq?namespace=http://www.asml.com/XMLSchema/MT/Generic/%s/%s&optionals=on&repetitions=%d', adel_name, adel_version, repetitions);
            request = matlab.net.http.RequestMessage;
            response = request.send(uri, obj.options);
            adel_data = xml_parse(response.Body.Data.char);
        end
    end
    
    
end