classdef bmmo_Configuration < handle   
    %% bmmo_Configuration
    % A configuration is a list of configuration parameters
    % It can be used to configure an object on which those parameters
    % are defined. 
    % A bmmo_Configuration object can be created by passing a
    % name value pair in the constructor for all parameters defined in
    % bmmo_ConfigurationParameterFactory. Alternatively one of the predefined
    % configurations can be used e.g.: bmmo_3600D_model_configuration
    
    % See also: bmmo_ConfigurationParameter,
    % bmmo_ConfigurationParametFactory
    
    properties (SetAccess = protected, GetAccess = ?bmmoConfiguration)
        parameter_list  % bmmoConfigurationParameter objects
        evaluation_order
    end
    
    methods  % Constructor
        % A configuration is constructed by providing a list of (name,value)
        % pairs which describe the parameters
        % 
        % Input: names: 1xn cell array of char arrays
        %           These are keys to the lookup table defined in
        %           bmmoConfigurationParameterFactory
        %        values: 1xn cell array of parameter values
        %           These are input to the constructor for each 
        %           bmmoConfigurationParameter   
        %
        function obj = bmmo_Configuration(names, values)
            
            [names, values] = sub_validate_names(names, values);
            
            numpar = length(names);
            obj.parameter_list = containers.Map;
            obj.evaluation_order = containers.Map; 
            
            factory = bmmo_ConfigurationParameterFactory.getInstance();
            
            for ipar = 1:numpar 
                [obj.parameter_list(names{ipar}), ...
                    obj.evaluation_order(names{ipar})] = ...
                    factory.getParameter(names{ipar}, values{ipar});
            end
           
            
        end
    end
    
    methods 
        % Configure an object according to the list of parameters
        %   This function modifies the object in-place
        function configure(obj, sim)
           parameter_names = obj.parameter_list.keys();           
           [~, raw_evaluation_order] = sort(cell2num(obj.evaluation_order.values()));
           parameter_names = parameter_names(raw_evaluation_order);          
           for i_name = 1:length(parameter_names)               
              par = obj.parameter_list(parameter_names{i_name});
              par.updateParameterValue(sim, obj.chuck_id);
           end
           
        end
        
        function names = getNames(obj)
           names = obj.parameter_list.keys(); 
        end
            
        function config_object = getConfigurationObject(obj, name)
            config_object = obj.parameter_list(name).getConfigurationObject(obj);
        end        
        
        % identify common names and values
        % return results in same sort order as input names
        function [common_values, common_names] = getValue(obj, name)
            singleoutput = false;
            if ischar(name)
                name = {name};
                singleoutput = true;
            end
            
            common_names = name(obj.parameter_list.isKey(name));
            common_values = cell(0, length(common_names));
            for i_name = 1:length(common_names)
                common_values{i_name} = obj.parameter_list(common_names{i_name}).getValue();
            end
            
            if singleoutput && ~isempty(common_values)
                common_values = common_values{1};
            end
        end
        
        function parameter = getParameter(obj, name)
            assert(ischar(name));
            if obj.parameter_list.isKey(name)
                parameter = obj.parameter_list(name);
            else
                parameter = [];
            end                      
        end
            
        function disp(obj)
           for i_obj = 1:length(obj)
               all_names = obj(i_obj).parameter_list.keys();
               for ipar = 1:length(all_names)
                  disp(obj(i_obj).parameter_list(all_names{ipar})); 
               end
               fprintf('\n');
           end
        end
        
        function setValue(obj, names, values)
           
            [names, values] = sub_validate_names(names, values);
            factory = bmmo_ConfigurationParameterFactory.getInstance();             
            
            for i_name = 1:length(names)
                [obj.parameter_list(names{i_name}), ...
                    obj.evaluation_order(names{i_name})] = ...
                        factory.getParameter(names{i_name}, values{i_name});
            end
           
        end
            
        function options = getOptions(obj, name)
            singleoutput = false;
            if ischar(name)
                name = {name};
                singleoutput = true;
            end
            
            options = cell(0, length(name));
            available_names = find(obj.parameter_list.isKey(name));

            for i_name = available_names
                options{i_name} = obj.parameter_list(name{i_name}).getOptions();
            end
            
            if singleoutput && ~isempty(options)
                options = options{1};
            end
        end  
        
        function remove(obj, name)
           if ischar(name)
               name = {name};
           end
          
           obj.parameter_list.remove(name);
           obj.evaluation_order.remove(name);
        end
    end
end

function [names, values] = sub_validate_names(names, values)
if ischar(names)
    names = {names};
    values = {values};
else
    numpar = length(names);
    assert(numpar == length(values));
end
end
