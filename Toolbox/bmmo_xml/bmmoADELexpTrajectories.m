classdef bmmoADELexpTrajectories < bmmoADELfile
%% <help_update_needed>
%  for the class and for the function
%
%   

    %%
    properties (GetAccess = public, SetAccess = protected)
       % these properties are mutually dependent
       ml_residual
       cet_residual
    end
    
    properties (Constant, Hidden)
       MM = 1e3;
       NM = 1e9;
       NUMBER_CHUCKS = 2;
    end    
    
    %%
    methods
        function obj = bmmoADELexpTrajectories(config)
            obj.xml_data = [];
            obj.ml_residual = [];
            obj.cet_residual = [];
        end
    end
    
    %%
    methods        
        % read ADELexposureTrajectoriesReportProtected file
        function read(obj, filename)
          [obj.cet_residual, obj.ml_residual, obj.xml_data] = bmmo_read_adelexposetrajectories(filename);
        end
        
        % set machine name
        function setMachineId(obj, machine_name)
            obj.xml_data.Header.MachineID = machine_name;
        end
        
        function setVersion(obj, version)
           obj.xml_data.Header.DocumentTypeVersion = version;
        end 
        
        function create(obj, adel_version)
            if nargin < 2
                adel_version = 'v1.2';
            end
            adel_if = bmmoGenericAdelInterface([]);
            SINGLE_REPETITION = 1;
            obj.xml_data = adel_if.getAdelInstance('ADELexposureTrajectoriesReport', adel_version, SINGLE_REPETITION);          
            [obj.cet_residual, obj.ml_residual] = bmmo_parse_adelexposetrajectories(obj.xml_data);
        end
        
        function setXmlData(obj, xml_data)
           obj.xml_data = xml_data;
           [obj.cet_residual, obj.ml_residual] = bmmo_parse_adelexposetrajectories(obj.xml_data);
        end
        
        function write(obj, filename)
            docversion = obj.xml_data.Header.DocumentTypeVersion;
            schema_info = sprintf('xsi:schemaLocation="http://www.asml.com/XMLSchema/MT/Generic/ADELexposureTrajectoriesReport/%s ADELexposureTrajectoriesReport.xsd" xmlns:ADELexposureTrajectoriesReport="http://www.asml.com/XMLSchema/MT/Generic/ADELexposureTrajectoriesReport/%s" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"', docversion, docversion);
            bmmo_xml_save(filename, obj.xml_data, 'ADELexposureTrajectoriesReport:Report', schema_info);            
        end

        function writeNew(obj, filename)
           obj.update_header();
           obj.write(filename);
        end
        
        function setMl(obj, ml)
           if isempty(obj.xml_data)
              obj.create(); 
           end
           obj.ml_residual = ml;
           obj.updateXMLFromMl();
           obj.cet_residual = bmmo_parse_adelexposetrajectories(obj.xml_data);
        end
        
        function fixCETGrid(obj)
           obj.setCETgrid();
           [obj.cet_residual, obj.ml_residual] = bmmo_parse_adelexposetrajectories(obj.xml_data);
        end
        
        function updateFromAdeller(obj, adeller)
           if isempty(obj.xml_data)
               obj.create();
           end
           obj.updateXMLDataFromAdeller(adeller);
        end
    end
     
    %%
    methods (Access = private)
        function doctime = update_header(obj)

            machine_id = obj.xml_data.Header.MachineID;
            doctime = now;
      
            doc_timestr = datestr(doctime, obj.DOCID_DATEFORMAT);        
            obj.xml_data.Header.DocumentId = sprintf('ADELexp2-%s-%s', machine_id, doc_timestr);

        end
        
        function setCETgrid(obj)
             [xg, yg] = bmmo_cet_grid();
             
             obj.xml_data.Input.GridList = [];
             obj.xml_data.Input.GridList(1).elt.GridId = '1'; % single grid
             for ii = 1:numel(xg)
                 obj.xml_data.Input.GridList(1).elt.GridDefinition(ii).elt.X = sprintf('%.9f', xg(ii) * obj.MM);
                 obj.xml_data.Input.GridList(1).elt.GridDefinition(ii).elt.Y = sprintf('%.9f', yg(ii) * obj.MM);
             end
             
             for iw = 1:numel(obj.xml_data.Results.WaferResultList)
                for ifield = 1:numel(obj.xml_data.Results.WaferResultList(iw).elt.ImageResultList(1).elt.ExposureResultList)
                   
                    field_data = ovl_get_fields(ovl_get_wafers(obj.ml_residual, iw), ifield);
                    [xgm, ygm, gridmap_index] = bmmo_fix_nd_grid(field_data.wd.xf, field_data.wd.yf);
                    dxvec = field_data.layer.wr.dx(gridmap_index);
                    dyvec = field_data.layer.wr.dy(gridmap_index);
                    
                    interp_fn_dx = griddedInterpolant(xgm, ygm, dxvec, 'linear');
                    interp_fn_dy = griddedInterpolant(xgm, ygm, dyvec, 'linear');
                    dx_new = interp_fn_dx(xg, yg);
                    dy_new = interp_fn_dy(xg, yg);
                    
                    dx_new(isnan(dx_new)) = 0;
                    dy_new(isnan(dy_new)) = 0;
                    for imark = 1:obj.ml_residual.nmark
                       
                       obj.xml_data.Results.WaferResultList(iw).elt.ImageResultList(1).elt.ExposureResultList(ifield).elt.Residuals(imark).elt.Dx = sprintf('%.3f', dx_new(imark) * obj.NM);
                       obj.xml_data.Results.WaferResultList(iw).elt.ImageResultList(1).elt.ExposureResultList(ifield).elt.Residuals(imark).elt.Dy = sprintf('%.3f', dy_new(imark) * obj.NM);
                    end
                    
                end
             end
        end
         
        function updateXMLFromMl(obj)
             
             % update grid
             field_data = ovl_get_fields(ovl_get_wafers(obj.ml_residual, 1), 1);
             [xg, yg, gridmap_index] = bmmo_fix_nd_grid(field_data.wd.xf, field_data.wd.yf);
             
             obj.xml_data.Input.GridList = [];
             obj.xml_data.Input.GridList(1).elt.GridId = '1'; % single grid
             for ii = 1:numel(xg)
                 obj.xml_data.Input.GridList(1).elt.GridDefinition(ii).elt.X = sprintf('%.9f', xg(ii) * obj.MM);
                 obj.xml_data.Input.GridList(1).elt.GridDefinition(ii).elt.Y = sprintf('%.9f', yg(ii) * obj.MM);
             end
             
             obj.xml_data.Results.WaferResultList = repmat(obj.xml_data.Results.WaferResultList(1), 1, obj.ml_residual.nwafer);
             
             % write residuals per wafer
             for iw = 1:obj.ml_residual.nwafer
                % write residuals per field
                obj.xml_data.Results.WaferResultList(iw).elt.ImageResultList(1).elt.ExposureResultList = ...
                  repmat(obj.xml_data.Results.WaferResultList(1).elt.ImageResultList(1).elt.ExposureResultList(1), 1, obj.ml_residual.nfield);
                
                for ifield = 1:obj.ml_residual.nfield
                   field_data = ovl_get_fields(ovl_get_wafers(obj.ml_residual, iw), ifield);
                   obj.xml_data.Results.WaferResultList(iw).elt.ImageResultList(1).elt.ExposureResultList(ifield).elt.FieldPosition.X = sprintf('%.7f', mean(field_data.wd.xc) * obj.MM);
                   obj.xml_data.Results.WaferResultList(iw).elt.ImageResultList(1).elt.ExposureResultList(ifield).elt.FieldPosition.Y = sprintf('%.7f', mean(field_data.wd.yc) * obj.MM);
                   obj.xml_data.Results.WaferResultList(iw).elt.ImageResultList(1).elt.ExposureResultList(ifield).elt.GridId = '1';
                   residual_data = repmat(obj.xml_data.Results.WaferResultList(iw).elt.ImageResultList(1).elt.ExposureResultList(ifield).elt.Residuals(1), 1, obj.ml_residual.nmark);
                   dxvec = field_data.layer.wr.dx(gridmap_index);
                   dyvec = field_data.layer.wr.dy(gridmap_index);
                   dxvec(isnan(dxvec)) = 0;
                   dyvec(isnan(dyvec)) = 0;
                   for imark = 1:obj.ml_residual.nmark
                       
                       residual_data(imark).elt.Dx = sprintf('%.3f', dxvec(imark) * obj.NM);
                       residual_data(imark).elt.Dy = sprintf('%.3f', dyvec(imark) * obj.NM);
                   end
                   obj.xml_data.Results.WaferResultList(iw).elt.ImageResultList(1).elt.ExposureResultList(ifield).elt.Residuals = residual_data;
                   obj.xml_data.Results.WaferResultList(iw).elt.ImageResultList(1).elt.ExposureResultList(ifield).elt.Corrections = residual_data; % in case some validation is done
                end
             end
         end
         
         
         function updateXMLDataFromAdeller(obj, adeller)
             if ischar(adeller)
                adeller = xml_load(adeller); 
             end
             
             obj.xml_data.Header.MachineID = adeller.Header.MachineID;
             obj.xml_data.Header.MachineType = adeller.Header.MachineType;
             obj.xml_data.Header.MachineCustomerName = adeller.Header.MachineCustomerName;
             obj.xml_data.Header.CreateTime = adeller.Header.CreateTime;
             obj.xml_data.Header.SoftwareRelease = adeller.Header.SoftwareRelease;
             
             obj.xml_data.DocumentMetaData.LotId = adeller.Input.LotId;
             all_reports = [adeller.Results.DataReportList.elt];
             adelexp_index = find(strcmp({all_reports.DocumentType}, 'ADELexposureTrajectoriesReportProtected'));
             if ~isempty(adelexp_index)
                 obj.xml_data.Header.DocumentId = all_reports(adelexp_index(1)).ReportUuid;
             else
                obj.xml_data.Header.DocumentId = sprintf('%s', obj.xml_data.Header.MachineID);
             end
                 
             nwafer = numel(adeller.Results.WaferResultList);
             assert(nwafer == numel(obj.xml_data.Results.WaferResultList), 'Mismatch in number of wafers');
             for iw = 1:nwafer
                obj.xml_data.Results.WaferResultList(iw).elt.WaferId = adeller.Results.WaferResultList(iw).elt.WaferId;
                obj.xml_data.Results.WaferResultList(iw).elt.WaferSeqNr = adeller.Results.WaferResultList(iw).elt.WaferSeqNr;
                obj.xml_data.Results.WaferResultList(iw).elt.ImageResultList(1).elt.ImageId = adeller.Results.WaferResultList(iw).elt.ImageResultList(1).elt.ImageId;
             end
         end
     end
end