classdef bmmoADELSBC < bmmoADELfile
%% <help_update_needed>
%  for the class and for the function
%
%   
    %%
    properties (GetAccess = public, SetAccess = protected)
       % these properties are mutually dependent
       sbc_struct
       inline_sdm_struct
    end
    
    properties (Constant, Hidden)
       DEFAULT_KA_START = -0.15;
       DEFAULT_KA_PITCH = 5e-3;
       DEFAULT_KA_SIZE = 61;
       DEFAULT_INTRAF_X = 13;
       DEFAULT_INTRAF_Y = 19;
       DEFAULT_MI_START = -0.2;
       DEFAULT_MI_PITCH = 1e-3;
       DEFAULT_MI_SIZE = 401;
       MIRROR_SIDES = {'MiMirrorOffsetMapMeasure', 'MiMirrorOffsetMapExpose'};
       MIRROR_MAPS = {'XTYMirrorMap', 'YTXMirrorMap'};
       NUMBER_CHUCKS = 2;
    end
    
    %%
    methods
        function obj = bmmoADELSBC(config)
            obj.xml_data = [];
            obj.sbc_struct = [];
            obj.inline_sdm_struct = [];
        end
    end
    
    %%
    methods        
        % read file
        function read(obj, filename)
            obj.xml_data = xml_load(filename);
           [obj.sbc_struct, obj.inline_sdm_struct] = bmmo_kt_process_SBC2(obj.xml_data);
        end
        
        function setVersion(obj, version)
           obj.xml_data.Header.DocumentTypeVersion = version;
           obj.xml_data.Header.VersionId = version;
        end 
        
        function setRecipeName(obj, recipe_name)
           obj.xml_data.Header.RecipeName = sprintf('ADELsbcOverlayDriftControlNxe/%s', recipe_name); 
        end
        
        function writeNew(obj, filename)
            obj.update_header();
            obj.write(filename);
        end
        
        % write to file
        function write(obj, filename)
            docversion = obj.xml_data.Header.DocumentTypeVersion;
            schema_info = sprintf('xsi:schemaLocation="http://www.asml.com/XMLSchema/MT/Generic/ADELsbcOverlayDriftControlNxe/%s ADELsbcOverlayDriftControlNxe.xsd" xmlns:ns0="http://www.asml.com/XMLSchema/MT/Generic/ADELsbcOverlayDriftControlNxe/%s" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"', docversion, docversion);
            bmmo_xml_save(filename, obj.xml_data, 'ns0:Recipe', schema_info);            
        end
               
        % get sbc struct
        function sbc_struct = get_SBC(obj)
            sbc_struct = obj.sbc_struct;
        end
        
        function bmmo_inject_inline_sdm_into_ADEL_xml(obj)
            sbc_chuck_order = arrayfun(@(x) str2double(x.elt.ApplicationRange.Exposure.Wafer.WaferStageChuckId(end)), obj.xml_data.CorrectionSets);
            for ic = 1:obj.NUMBER_CHUCKS
                chuck_id = sbc_chuck_order(ic);
                if isfield(inline_sdm, 'time_filter')
                    obj.xml_data.CorrectionSets(chuck_id).elt.Parameters.SdmDistortionMap.Header.TimeFilter = sprintf('%.4f', inline_sdm.time_filter);
                end
                if isfield(inline_sdm, 'sdm_model')
                    obj.xml_data.CorrectionSets(chuck_id).elt.Parameters.SdmDistortionMap.Header.SdmModel = inline_sdm.sdm_model;
                end
            end
            
        end
        
        % create empty (default)
        function create_empty_SBC(obj, adel_version)
            if nargin < 2
                adel_version = 'v1.5';
            end
            obj.create(adel_version);
        end
        
        function create(obj, adel_version)
            if nargin < 2
                adel_version = 'v1.5';
            end
            adel_if = bmmoGenericAdelInterface([]);
            obj.xml_data = adel_if.getAdelInstance('ADELsbcOverlayDriftControlNxe', adel_version);
            obj.fix_xml_data();
            [obj.sbc_struct, obj.inline_sdm_struct] = bmmo_kt_process_SBC2(obj.xml_data);
        end
        
        % create empty (with sbc template)
        function create_empty_SBC_from_corr(obj, sbc_in, adel_version)
            if nargin < 3
                adel_version = 'v1.5';
            end
            obj.create_empty_SBC(adel_version);
            obj.define_MI_from_corr(sbc_in);
            obj.define_KA_from_corr(sbc_in);
        end
        
        % create empty (with options template)
        function create_empty_SBC_from_options(obj, options, adel_version)
            if nargin < 3
                adel_version = 'v1.5';
            end
            obj.create_empty_SBC(adel_version);
            obj.define_MI_from_options(options);
            obj.define_KA_from_options(options);
        end
        
        % create filled SBC from corr
        function create_SBC_from_corr(obj, sbc_in, adel_version)
            if nargin < 3
                adel_version = 'v1.5';
            end
            obj.create_empty_SBC(adel_version);
            obj.define_MI_from_corr(sbc_in);
            obj.define_KA_from_corr(sbc_in);
            obj.set_corr(sbc_in);
        end
        
        % add ADEL file
        function add_ADEL_file(obj, filename)
           tmp_adel_obj =  bmmoADELSBC();
           tmp_adel_obj.read(filename);
           obj.add(tmp_adel_obj);
        end
        
        % add ADEL SBC
        function add(obj, adel_obj)  
            obj.sbc_struct = bmmo_add_output_corr(obj.sbc_struct, adel_obj.get_SBC());
            obj.xml_data = bmmo_inject_sbc_into_ADEL_xml(obj.xml_data, obj.sbc_struct);
            %bmmo_assert_equal(obj.sbc_struct, bmmo_kt_process_SBC2(obj.sbc_struct));
        end
        
        % add bmmo sbc correction
        function add_corr(obj, sbc_in)  
            obj.sbc_struct = bmmo_add_output_corr(obj.sbc_struct, sbc_in);
            obj.xml_data = bmmo_inject_sbc_into_ADEL_xml(obj.xml_data, obj.sbc_struct);
            %bmmo_assert_equal(obj.sbc_struct, bmmo_kt_process_SBC2(obj.sbc_struct));
        end
        
        % set bmmo sbc correction
        function set_corr(obj, sbc_in)
            if isempty(obj.xml_data)
                obj.create();
            end
            obj.define_KA_from_corr(sbc_in);
            obj.xml_data = bmmo_inject_sbc_into_ADEL_xml(obj.xml_data, sbc_in);
            [obj.sbc_struct, obj.inline_sdm_struct] = bmmo_kt_process_SBC2(obj.xml_data);
            %bmmo_assert_equal(obj.sbc_struct, sbc_in);
        end
        
        % set inline_sdm header info (both or either fields: sdm_model, time_filter)
        function set_inline_sdm(obj, inline_sdm_in)
            if isempty(obj.xml_data)
                obj.create();
            end
            sbc_chuck_order = arrayfun(@(x) str2double(x.elt.ApplicationRange.Exposure.Wafer.WaferStageChuckId(end)), obj.xml_data.CorrectionSets);
            for ic = 1:obj.NUMBER_CHUCKS
                chuck_id = sbc_chuck_order(ic);
                if isfield(inline_sdm_in, 'time_filter')
                    obj.xml_data.CorrectionSets(chuck_id).elt.Parameters.SdmDistortionMap.Header.TimeFilter = sprintf('%.4f', inline_sdm_in.time_filter);
                end
                if isfield(inline_sdm_in, 'sdm_model')
                    obj.xml_data.CorrectionSets(chuck_id).elt.Parameters.SdmDistortionMap.Header.SdmModel = inline_sdm_in.sdm_model;
                end
            end
            [obj.sbc_struct, obj.inline_sdm_struct] = bmmo_kt_process_SBC2(obj.xml_data);
        end
        
        % set xml_data
        function setXmlData(obj, xml_in)
            if ischar(xml_in)
                obj.xml_data = xml_load(xml_in);
            else
                obj.xml_data = xml_in;
            end
            [obj.sbc_struct, obj.inline_sdm_struct] = bmmo_kt_process_SBC2(obj.xml_data);
        end
        
        % set machine name
        function set_machine_name(obj, machine_name)
            obj.xml_data.Header.MachineName = machine_name;
            for ic = 1:numel(obj.xml_data.CorrectionSets)
                obj.xml_data.CorrectionSets(ic).elt.ApplicationRange.Equipment.AsmlMachineId = machine_name;
            end
        end
        
        % set fms
        function set_fms(obj, fms)
            obj.xml_data.FineMetrologyOverlayState = fms.Value;
        end
        
        % set SDM map size from BMMO options structure
        function define_SDM_from_options(obj, options)
            % TODO not clearly defined in options
            warning('TODO: using 13x19 SDM map as default');
            for ic = 1:obj.NUMBER_CHUCKS
                obj.fix_sdm_distomap(13, 19, ic);
            end
            [obj.sbc_struct, obj.inline_sdm_struct] = bmmo_kt_process_SBC2(obj.xml_data);
        end
        
        % set KA grid size from BMMO options structure
        function define_KA_from_options(obj, options)
            for ic = 1:obj.NUMBER_CHUCKS
                obj.fix_ka_grid(options.KA_start, options.KA_pitch, options.KA_length, ic);
                if (isfield(options, 'KA_measure_enabled') && (options.KA_measure_enabled > 0))
                    ka_measure_length = ceil((options.KA_meas_bound - options.KA_meas_start) / options.KA_pitch);
                    obj.fix_ka_measure_grid(options.KA_meas_start, options.KA_pitch, ka_measure_length, ic);
                end
            end
            [obj.sbc_struct, obj.inline_sdm_struct] = bmmo_kt_process_SBC2(obj.xml_data);
        end
            
        % set MI map size from BMMO options structure
        function define_MI_from_options(obj, options)
            for ic = 1:obj.NUMBER_CHUCKS
               for is = 1:length(obj.MIRROR_SIDES)
                   for im = 1:length(obj.MIRROR_MAPS)
                       obj.fix_mi_map(obj.MIRROR_SIDES{is}, obj.MIRROR_MAPS{im}, options.map_param.start_position, options.map_param.pitch, options.map_table_length, ic);
                   end
               end
            end 
            [obj.sbc_struct, obj.inline_sdm_struct] = bmmo_kt_process_SBC2(obj.xml_data);
        end
        
        function define_KA_from_corr(obj, corr)
            ka_start = min(corr.KA.grid_2de(1).x);
            ka_pitch = max(diff(corr.KA.grid_2de(1).x));
            ka_length = sqrt(numel(corr.KA.grid_2de(1).x));
            
            for ic = 1:obj.NUMBER_CHUCKS
                obj.fix_ka_grid(ka_start, ka_start, ka_pitch, ka_pitch, ka_length, ka_length, ic);
            end
            
            if isfield(corr.KA, 'grid_2dc')
                ka_start = min(corr.KA.grid_2dc(1).x);
                ka_pitch = max(diff(corr.KA.grid_2dc(1).x));
                ka_length = sqrt(numel(corr.KA.grid_2dc(1).x));
                for ic = 1:obj.NUMBER_CHUCKS
                    obj.fix_ka_measure_grid(ka_start, ka_start, ka_pitch, ka_pitch, ka_length, ka_length, ic);
                end
            end
            
            [obj.sbc_struct, obj.inline_sdm_struct] = bmmo_kt_process_SBC2(obj.xml_data);
        end
        
        function define_MI_from_corr(obj, corr)
            mi_start = min(corr.MI.wse(1).x_mirr.y);
            mi_pitch = max(diff(corr.MI.wse(1).x_mirr.y));
            mi_length = numel(corr.MI.wse(1).x_mirr.y);
            
            for ic = 1:obj.NUMBER_CHUCKS
               for is = 1:length(obj.MIRROR_SIDES)
                   for im = 1:length(obj.MIRROR_MAPS)
                       obj.fix_mi_map(obj.MIRROR_SIDES{is}, obj.MIRROR_MAPS{im}, mi_start, mi_pitch, mi_length, ic);
                   end
               end
            end 
            [obj.sbc_struct, obj.inline_sdm_struct] = bmmo_kt_process_SBC2(obj.xml_data);
        end
        
    end
    
    %%
    methods (Access = private)
        function fix_xml_data(obj)
            obj.create_header();
            
            % fix susd correction 
            obj.fix_susd();
            
            for ic = 1:obj.NUMBER_CHUCKS
               obj.xml_data.CorrectionSets(ic).elt.CorrectionSetName = sprintf('Correction_sr_%d', ic);
               obj.xml_data.CorrectionSets(ic).elt.CorrectionSetType = 'sbcoverlaydriftcontrol';
               obj.xml_data.CorrectionSets(ic).elt.ApplicationRange.Exposure.Wafer.WaferStageChuckId = sprintf('Waferstage chuck ID %d', ic);
               

               
               % set 13x19 SDM disto map
               obj.fix_sdm_distomap(obj.DEFAULT_INTRAF_X, obj.DEFAULT_INTRAF_Y, ic);
               
               % set 61x61 KA grid
               obj.fix_ka_grid(obj.DEFAULT_KA_START, obj.DEFAULT_KA_START, obj.DEFAULT_KA_PITCH, obj.DEFAULT_KA_PITCH,...
                   obj.DEFAULT_KA_SIZE, obj.DEFAULT_KA_SIZE, ic);
               
               % By default, no KA measure grid
               if isfield(obj.xml_data.CorrectionSets(ic).elt.Parameters, 'KaOffsetMapMeasure')
                   obj.xml_data.CorrectionSets(ic).elt.Parameters = rmfield(obj.xml_data.CorrectionSets(ic).elt.Parameters, 'KaOffsetMapMeasure');
               end
               
               % set MI maps
               for is = 1:length(obj.MIRROR_SIDES)
                   for im = 1:length(obj.MIRROR_MAPS)
                       obj.fix_mi_map(obj.MIRROR_SIDES{is}, obj.MIRROR_MAPS{im}, obj.DEFAULT_MI_START, obj.DEFAULT_MI_PITCH, obj.DEFAULT_MI_SIZE, ic);
                   end
               end        
            end
        end
        
        function fix_susd(obj)
            obj.xml_data.CorrectionSets = repmat(obj.xml_data.CorrectionSets(1), 1, 6);
            for ic = 1:obj.NUMBER_CHUCKS
               % first two correction sets have no IntraFieldOffset
               if isfield(obj.xml_data.CorrectionSets(ic).elt.Parameters, 'IntraFieldOffset')
                   obj.xml_data.CorrectionSets(ic).elt.Parameters = rmfield(obj.xml_data.CorrectionSets(ic).elt.Parameters, 'IntraFieldOffset');

               end
               

            end
            
            correction_names = {'Correction_chuck_1_down', 'Correction_chuck_1_up', 'Correction_chuck_2_down', 'Correction_chuck_2_up'};
            scan_direction = {'Downwards', 'Upwards', 'Downwards', 'Upwards'};
            chuck_name = {'Waferstage chuck ID 1', 'Waferstage chuck ID 1', 'Waferstage chuck ID 2', 'Waferstage chuck ID 2'};
            
            for ic = 3:6
                % remove all fields other than IntraFieldOffset
                fn = fieldnames(obj.xml_data.CorrectionSets(ic).elt.Parameters);
                fn(strcmp(fn, 'IntraFieldOffset')) = [];
                for ifield = 1:length(fn)
                    obj.xml_data.CorrectionSets(ic).elt.Parameters = rmfield(obj.xml_data.CorrectionSets(ic).elt.Parameters, fn{ifield});
                end
                obj.xml_data.CorrectionSets(ic).elt.CorrectionSetName = correction_names{ic - 2};
                obj.xml_data.CorrectionSets(ic).elt.CorrectionSetType = 'sbcoverlaydriftcontrol';
                obj.xml_data.CorrectionSets(ic).elt.ApplicationRange.Exposure.ExposureScanDirection = scan_direction{ic - 2};
                obj.xml_data.CorrectionSets(ic).elt.ApplicationRange.Exposure.Wafer.WaferStageChuckId = chuck_name{ic - 2};
               
            end                
        end
        
        function fix_mi_map(obj, side, map, start, pitch, steps, ic)
            obj.xml_data.CorrectionSets(ic).elt.Parameters.(side).(map).Header.InitialPosition = sprintf('%.3f', start * 1e3);
            obj.xml_data.CorrectionSets(ic).elt.Parameters.(side).(map).Header.Pitch = sprintf('%.3f', pitch * 1e3);
            obj.xml_data.CorrectionSets(ic).elt.Parameters.(side).(map).Header.Steps = sprintf('%d', steps-1);
            obj.xml_data.CorrectionSets(ic).elt.Parameters.(side).(map).Offsets = repmat(...
                obj.xml_data.CorrectionSets(ic).elt.Parameters.(side).(map).Offsets(1), 1, steps);
        end
        
        function fix_ka_grid(obj, startx, starty, pitchx, pitchy, numx, numy, ic)
            obj.xml_data.CorrectionSets(ic).elt.Parameters.KaOffsetMapExpose.Header.InitialPosition.X = sprintf('%.3f', startx * 1e3);
            obj.xml_data.CorrectionSets(ic).elt.Parameters.KaOffsetMapExpose.Header.InitialPosition.Y = sprintf('%.3f', starty * 1e3);
            obj.xml_data.CorrectionSets(ic).elt.Parameters.KaOffsetMapExpose.Header.Pitch.X = sprintf('%.3f', pitchx * 1e3);
            obj.xml_data.CorrectionSets(ic).elt.Parameters.KaOffsetMapExpose.Header.Pitch.Y = sprintf('%.3f', pitchy * 1e3);
            obj.xml_data.CorrectionSets(ic).elt.Parameters.KaOffsetMapExpose.Header.Steps.X = sprintf('%d', numx-1);
            obj.xml_data.CorrectionSets(ic).elt.Parameters.KaOffsetMapExpose.Header.Steps.Y = sprintf('%d', numy-1);
            obj.xml_data.CorrectionSets(ic).elt.Parameters.KaOffsetMapExpose.Offsets = repmat(...
                obj.xml_data.CorrectionSets(ic).elt.Parameters.KaOffsetMapExpose.Offsets(1), 1, numx*numy);
            

        end
        
        function fix_ka_measure_grid(obj, startx, starty, pitchx, pitchy, numx, numy, ic)
            obj.xml_data.CorrectionSets(ic).elt.Parameters.KaOffsetMapMeasure.Header.InitialPosition.X = sprintf('%.3f', startx * 1e3);
            obj.xml_data.CorrectionSets(ic).elt.Parameters.KaOffsetMapMeasure.Header.InitialPosition.Y = sprintf('%.3f', starty * 1e3);
            obj.xml_data.CorrectionSets(ic).elt.Parameters.KaOffsetMapMeasure.Header.Pitch.X = sprintf('%.3f', pitchx * 1e3);
            obj.xml_data.CorrectionSets(ic).elt.Parameters.KaOffsetMapMeasure.Header.Pitch.Y = sprintf('%.3f', pitchy * 1e3);
            obj.xml_data.CorrectionSets(ic).elt.Parameters.KaOffsetMapMeasure.Header.Steps.X = sprintf('%d', numx-1);
            obj.xml_data.CorrectionSets(ic).elt.Parameters.KaOffsetMapMeasure.Header.Steps.Y = sprintf('%d', numy-1);
            obj.xml_data.CorrectionSets(ic).elt.Parameters.KaOffsetMapMeasure.Offsets = repmat(...
            obj.xml_data.CorrectionSets(ic).elt.Parameters.KaOffsetMapExpose.Offsets(1), 1, numx*numy);
        end
        
        function fix_sdm_distomap(obj, x, y, ic)
            obj.xml_data.CorrectionSets(ic).elt.Parameters.SdmDistortionMap.Header.Steps.X = sprintf('%d', x-1);
            obj.xml_data.CorrectionSets(ic).elt.Parameters.SdmDistortionMap.Header.Steps.Y = sprintf('%d', y-1);
            obj.xml_data.CorrectionSets(ic).elt.Parameters.SdmDistortionMap.Offsets = repmat(...
                obj.xml_data.CorrectionSets(ic).elt.Parameters.SdmDistortionMap.Offsets(1), 1, x*y);
        end
        
        function create_header(obj)
            doctime = obj.update_header();
            obj.xml_data.Header.VersionId = obj.xml_data.Header.DocumentTypeVersion;
            obj.xml_data.Header.RecipeName = 'ADELsbcOverlayDriftControlNxe/default_default';
            obj.xml_data.Header.CreateTime = datestr(doctime, obj.DATEFORMAT);
        end
        
        function doctime = update_header(obj)

            machine_id = obj.xml_data.Header.MachineName;
            doctime = now;
            obj.xml_data.Header.LastModifiedTime = datestr(doctime, obj.DATEFORMAT);
       
            doc_timestr = datestr(doctime, obj.DOCID_DATEFORMAT);        
            obj.xml_data.Header.DocumentId = sprintf('ADELsbc2-%s-%s', machine_id, doc_timestr);

        end
        
        function updateXMLDataFromAdeller(obj, adeller)
             if ischar(adeller)
                adeller = xml_load(adeller); 
             end
             
             obj.xml_data.Header.MachineName = adeller.Header.MachineID;
             obj.xml_data.Header.CreateTime = adeller.Header.CreateTime;
             obj.xml_data.Header.SoftwareRelease = adeller.Header.SoftwareRelease;
             obj.xml_data.Header.RecipeName = adeller.Input.LotSettings.ScannerBaseLineConstantsDriftControl.OverlayDriftControlSbcRecipeId;
             obj.xml_data.Header.DocumentId = adeller.Input.LotSettings.ScannerBaseLineConstantsDriftControl.OverlayDriftControlSbcRecipeUuid;
             obj.xml_data.Header.LastModifiedTime = adeller.Input.LotSettings.ScannerBaseLineConstantsDriftControl.OverlayDriftControlSbcRecipeChangedTime;
             
         end
        
    end
end