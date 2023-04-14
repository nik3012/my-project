classdef bmmoDevbenchRunner < handle
%% <help_update_needed>
%  for the class and for the function
%
% 

%%
    properties
        devbench % devbench object
        http     % http object
        sftp
        current_sbc
        current_fms
    end
        
    properties (Access = private)
       initialization_state 
    end
    
%%
% (offline: start a KT devbench, get its IP addr)
    methods
        function obj = bmmoDevbenchRunner(devbench)
           obj.devbench = devbench;
           obj.http = bmmoDevbenchHTTPInterface();
           obj.sftp = bmmoDevbenchSFTPInterface();
           obj.initialization_state = false;
        end
    end

%%    
    methods
        function setDevbench(obj, devbench)
            obj.devbench = devbench;
            obj.initialization_state = false;
        end
        
        function verifyInitialized(obj)
            if ~obj.initialization_state
                % (set the FMS state on the devbench so that it uses this report)
                disp('Retrieving Devbench Fine Metrology State');
                % get the FMS of the devbench
                try
                    fms_data = obj.http.get_last_adel_from_ip('ADELfineMetrologyOverlayState', 'EDI', obj.devbench.ip_address);
                catch err
                    disp('Please set the Fine Metrology State of the devbench using the command "python KT/tstpkg/KTMI_BMMO_set_fms.py"');
                    rethrow(err);
                end
                obj.devbench.fms = fms_data.FineMetrologyOverlayState.CalibrationState;
                % Log the FMS for use in creating an SBC
                obj.initialization_state = true;
            end
        end
        
        function runBl3Loop(obj, iterations, initial_sbc, timefilter, first_iteration)
            
            obj.verifyInitialized();
            
            if nargin < 5
                first_iteration = 1;
            end
            
            disp('About to run BMMO control loop. Please ensure the TwinScan software is running and has been initialized correctly (see https://techwiki.asml.com/index.php/BMMO_NXE_Overlay_Devbench_procedure)');
            
            adel_sbc = bmmoADELSBC();
           
            mkdir(sprintf('iteration_%d', first_iteration));
            if ~ischar(initial_sbc)
                fprintf('\nBuilding ADELsbcOverlayDriftControlNxe from sbc input\n');
                adel_sbc.create_SBC_from_corr(initial_sbc);
                adel_sbc.set_fms(obj.devbench.fms);
                adel_sbc.set_machine_name(obj.devbench.machine_name);
                adel_sbc.setRecipeName(sprintf('sbc_iteration_%d', first_iteration));
                sbc_file = sprintf('iteration_%d\\ADELsbcOverlayDriftControlNxe.xml', first_iteration);
                adel_sbc.write(sbc_file);
            else
                sbc_file = initial_sbc;
            end
            
            for ii = first_iteration:(first_iteration + (iterations-1))
                fprintf('\nIteration %d\n==========\n', ii);
                currentdir = sprintf('iteration_%d', ii);
                
                fprintf('\n - Upload the SBC file %s to the Devbench using http://%s:8080/EDI/baselinermmonxe.html\n', sbc_file, obj.devbench.ip_address);
                
                fprintf(' - Run a BMMO-NXE lot with SBC recipe sbc_iteration_%d and press a key when ready\n', ii);
                
                pause;

                input_struct = obj.calculateBl3InputFromDevbench(currentdir, timefilter);
                disp('saving input_struct');
                save(sprintf('iteration_%d%sinput_struct', ii, filesep), 'input_struct');
                
                disp('running BMMO-NXE model');
                sbc_out = bmmo_nxe_drift_control_model(input_struct);
            
                disp('creating ADELsbcOverlayDriftControlNxe file from model output');
                adel_sbc.create_SBC_from_corr(sbc_out.corr);
                adel_sbc.set_fms(obj.devbench.fms);
                adel_sbc.set_machine_name(obj.devbench.machine_name);
                adel_sbc.setRecipeName(sprintf('sbc_iteration_%d', ii+1));
                mkdir(sprintf('iteration_%d', ii+1));
                sbc_file = sprintf('iteration_%d\\ADELsbcOverlayDriftControlNxe.xml', ii+1);
                adel_sbc.writeNew(sbc_file);
                
                disp('saving SBC output');
                save(sprintf('iteration_%d%ssbc_out', ii, filesep), 'sbc_out');
            end
            
        end
        
        function input_struct = calculateBl3InputFromDevbench(obj, currentdir, timefilter)
                disp('retrieving ADELler');
                [adeller, ~, adel_date] = obj.http.get_last_adel_from_ip('ADELler', 'EDI', obj.devbench.ip_address);
                fprintf('retrieved ADELler with timestamp %s\n', adel_date);
                
                disp('retrieving ADELsbcOverlayDriftControlNxerep');
                [adelsbcrep, ~, adel_date] = obj.http.get_last_adel_from_ip('ADELsbcOverlayDriftControlNxerep', 'EDI', obj.devbench.ip_address);
                fprintf('retrieved ADELsbcOverlayDriftControlNxerep with timestamp %s\n', adel_date);

                disp('retrieving ADELexposureTrajectoriesReportProtected');
                [~, adelexp_txt, adel_date] = obj.http.get_last_adel_from_ip('ADELexposureTrajectoriesReportProtected', 'EDI', obj.devbench.ip_address);
                fprintf('retrieved ADELexposureTrajectoriesReportProtected with timestamp %s\n', adel_date);
                adelexp_filename = [pwd filesep sprintf('%s%sADELexposureTrajectoriesReport.xml', currentdir, filesep)];
                fid = fopen(adelexp_filename, 'w');
                fprintf(fid, '%s', adelexp_txt);
                fclose(fid);
                
                disp('retrieving ADELwaferGridResidualReportProtected');
                [~, adelwfrgridNCE_txt, adel_date] = obj.http.get_last_adel_from_ip('ADELwaferGridResidualReportProtected', 'EDI', obj.devbench.ip_address);
                fprintf('retrieved ADELwaferGridResidualReport with timestamp %s\n', adel_date);
                adelwfrgridNCE_filename = [pwd filesep sprintf('%s%sADELwaferGridResidualReport.xml', currentdir, filesep)];
                fid = fopen(adelwfrgridNCE_filename, 'w');
                fprintf(fid, '%s', adelwfrgridNCE_txt);
                fclose(fid);
                
                disp('retrieving KT_wafers_out');
                bmmoDevbenchSFTPInterface.get_file_from_devbench('KT/KT_wafers_out', obj.devbench.machine_name, obj.devbench.ip_address, currentdir);
                KT_wo = sprintf('%s%sKT_wafers_out', currentdir, filesep);
                
                disp('constructing BL3 input_struct');
                
                input_struct = bl3_input_struct_from_devbench(KT_wo, adelsbcrep, adeller, timefilter, adelexp_filename, adelwfrgridNCE_filename);
                if numel(input_struct.info.previous_correction.KA.grid_2de(1).x) < 4000
                   input_struct.info.configuration_data.bl3_model = 0; 
                end
                
        end
        
    end
end