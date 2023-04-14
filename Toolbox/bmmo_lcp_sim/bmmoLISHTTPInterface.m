classdef bmmoLISHTTPInterface < handle
%% <help_update_needed>
%  for the class and for the function
%
%   

   %% 
   properties
       options; % Matlab http options structure
   end
   
   %%
   methods
       function obj = bmmoLISHTTPInterface()
          obj.options = matlab.net.http.HTTPOptions;
          obj.options.ConvertResponse = 0; % Disable autoconvert into Matlab types, to avoid Matlab's crappy builtin XML parser
          obj.options.ConnectTimeout = 1000;
       end
   end
   
   %% 
   methods
       function [adel_data, adel_char] = get_adel_from_ip(obj, adel_type, adel_name, interface_name, equipment_ip) 
           uri = sprintf('http://%s:8080/%s/%s/%s?cmd=get', equipment_ip, interface_name, adel_type, adel_name);
           request = matlab.net.http.RequestMessage;
           response = request.send(uri, obj.options);
           adel_char = response.Body.Data.char;
           adel_data = xml_parse(adel_char);           
       end
       
       function [adel_data, adel_char, adel_date] = get_last_adel_from_ip(obj, adel_type, interface_name, equipment_ip)
           [adel_list, adel_dates] = obj.get_adel_list_from_ip(adel_type, interface_name, equipment_ip);
           [~, sortid] = sort(adel_dates);
           adel_name = adel_list{sortid(end)};
           adel_date = adel_dates(sortid(end));
           [adel_data, adel_char] = obj.get_adel_from_ip(adel_type, adel_name, interface_name, equipment_ip);
       end
       
       function response = send_adel_to_ip(obj, adel_path, equipment_ip)
            uri = sprintf('http://%s:8080/documentstore/rest/document', equipment_ip);
            file_provider = matlab.net.http.io.MultipartFormProvider("FCONTENT", matlab.net.http.io.FileProvider(adel_path));
            request = matlab.net.http.RequestMessage(matlab.net.http.RequestMethod.PUT, [], file_provider);
            response = request.send(uri, obj.options);
       end
       
       function response = send_adel_control_to_ip(obj, adel_path, equipment_ip)
            uri = sprintf('http://%s:8080/automation/bmmoNxeOverlay/control', equipment_ip);
            file_provider = matlab.net.http.io.MultipartFormProvider("file", matlab.net.http.io.FileProvider(adel_path));
            request = matlab.net.http.RequestMessage(matlab.net.http.RequestMethod.POST, [], file_provider);
            response = request.send(uri, obj.options);
       end
       
       function [adel_list, adel_dates] = get_adel_list_from_ip(obj, adel_type, interface_name, equipment_ip)
           
           uri = sprintf('http://%s:8080/%s/%s?cmd=list', equipment_ip, interface_name, adel_type);
           request = matlab.net.http.RequestMessage;
           response = request.send(uri, obj.options);
           xml_data = xml_parse(response.Body.Data.char);
           
           adel_list = arrayfun(@(x) x.elt.Name, xml_data.Results.EntryList, 'UniformOutput', false);
           adel_dates = arrayfun(@(x) bmmo_parse_adel_timestamp(x.elt.LastModifiedTime), xml_data.Results.EntryList);
       end
       
   end
   
end