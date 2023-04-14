classdef (Abstract) bmmoADELfile < handle
%% <help_update_needed>
%  for the class and for the function
%
%   
    %%
    properties (GetAccess = public, SetAccess = protected)
       % these properties are mutually dependent
       xml_data
    end
    
    properties (Constant, Hidden)
       DATEFORMAT = 'YYYY-mm-DDTHH:MM:SS';
       DOCID_DATEFORMAT = 'YYYYmmDD_HHMM';
    end
    
    %%
    methods     (Abstract)   
        % read in xml_data and possibly other properties
        read(obj, filename);

        % write xml_data
        write(obj, filename);
        
        setXmlData(obj, xml_in);
        
        setVersion(obj, version_id);
        
        create(obj, adel_version);
    end
     
    %%
    methods % common to all ADELs

    end
end