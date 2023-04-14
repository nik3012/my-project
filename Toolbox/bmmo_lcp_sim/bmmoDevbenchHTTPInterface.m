classdef bmmoDevbenchHTTPInterface < handle
%% <help_update_needed>
%  for the class and for the function
%
%       
   properties
       options; % Matlab http options structure
   end
    
   methods
       function obj = bmmoDevbenchHTTPInterface()
          obj.options = matlab.net.http.HTTPOptions;
          obj.options.ConvertResponse = 0; % Disable autoconvert into Matlab types, to avoid Matlab's crappy builtin XML parser
          obj.options.ConnectTimeout = 1000;
       end
   end
   
    
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
       
       function send_adel_to_ip(obj, adel_path, interface_name, equipment_ip)
            xml_data = xml_load(adel_path);
            adel_type = strrep(xml_data.Header.DocumentType, '.', '');
            

            obj.send_adel_type_to_ip(adel_type, adel_path, interface_name, equipment_ip);
       end
       
       function response = send_adel_type_to_ip(obj, adel_type, adel_path, interface_name, equipment_ip)
           
%             error(sprintf('send_adel_type_to_ip is a TODO. Please manually upload the ADEL using the %s interface at http://%s:8080/%s/', ...
%                 interface_name, equipment_ip, interface_name));
           
            uri = sprintf('http://%s:8080/%s/%s?cmd=put', equipment_ip, interface_name, adel_type);
            
            file_provider = matlab.net.http.io.MultipartFormProvider("File", matlab.net.http.io.FileProvider(adel_path));
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