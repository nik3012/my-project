classdef bmmoLisDevbenchRunner < handle
%% <help_update_needed>
%  for the class and for the function
%
%

    %%
    properties
        devbench % devbench object
        lis
        lisHttp
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
        function obj = bmmoLisDevbenchRunner(devbench, lis)
           obj.devbench = devbench;
           obj.http = bmmoDevbenchHTTPInterface();
           obj.sftp = bmmoDevbenchSFTPInterface();
           obj.initialization_state = false;
           obj.lis = lis;
           obj.lisHttp = bmmoLISHTTPInterface();
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
                    [fms_data, fms_txt] = obj.http.get_last_adel_from_ip('ADELfineMetrologyOverlayState', 'EDI', obj.devbench.ip_address);
                catch err
                    disp('Please set the Fine Metrology State of the devbench using the command "python KT/tstpkg/KTMI_BMMO_set_fms.py"');
                    rethrow(err);
                end
                obj.devbench.fms = fms_data.FineMetrologyOverlayState.CalibrationState;
                
                % Upload FMS to LIS
                adelfms_filename = 'ADELfineMetrologyOverlayState.xml';
                obj.writeAdel(adelfms_filename, fms_txt);
                response = obj.lisHttp.send_adel_to_ip(adelfms_filename, obj.lis.ip_address);
                
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
                % to do, copy file to iteration directory
                sbc_file = initial_sbc;
            end
            
            % to do add BL3 neutral           
            for ii = first_iteration:(first_iteration + (iterations-1))
                fprintf('\nIteration %d\n==========\n', ii);
                currentdir = sprintf('iteration_%d', ii);
                fprintf('\n - Upload the SBC file %s to the Devbench using http://%s:8080/EDI/baselinermmonxe.html\n', sbc_file, obj.devbench.ip_address);
                fprintf(' - Run a BMMO-NXE lot with SBC recipe sbc_iteration_%d and press a key when ready\n', ii);
                
                pause;
                obj.getBl3AdelsFromDevbench(currentdir);
                obj.uploadBl3AdelsToLis(currentdir);
                adeljct = obj.generateAdelJobControl(currentdir, timefilter);
                
                disp('running BaseLiner 3 model on LIS');
                
                %to do, handle response
                response = obj.lisHttp.send_adel_control_to_ip([currentdir filesep adeljct], obj.lis.ip_address);
                disp(['LIS Job Created: ' char(datetime)]);
                
                %to do: automate sbc download
                mkdir(sprintf('iteration_%d', ii+1));
                fprintf('\n - Download the generated SBC file from LIS and place it in the folder iteration_%d\n', ii+1);
                fprintf('Make sure the file is named ADELsbcOverlayDriftControlNxe.xml\n');
                
                pause;               
            end           
        end
        
        function getBl3AdelsFromDevbench(obj, currentdir)
                disp('retrieving ADELler');
                [adeller, adeller_txt, adel_date] = obj.http.get_last_adel_from_ip('ADELler', 'EDI', obj.devbench.ip_address);
                fprintf('retrieved ADELler with timestamp %s\n', adel_date);
                adeller_filename = [pwd filesep sprintf('%s%sADELler.xml', currentdir, filesep)];
                obj.writeAdel(adeller_filename, adeller_txt);
                
                disp('retrieving ADELsbcOverlayDriftControlNxerep');
                [~, adelsbcrep_txt, adel_date] = obj.http.get_last_adel_from_ip('ADELsbcOverlayDriftControlNxerep', 'EDI', obj.devbench.ip_address);
                fprintf('retrieved ADELsbcOverlayDriftControlNxerep with timestamp %s\n', adel_date);
                adelsbcrep_filename = [pwd filesep sprintf('%s%sADELsbcOverlayDriftControlNxerep.xml', currentdir, filesep)];
                obj.writeAdel(adelsbcrep_filename, adelsbcrep_txt);

                disp('retrieving ADELexposureTrajectoriesReportProtected');
                [~, adelexp_txt, adel_date] = obj.http.get_last_adel_from_ip('ADELexposureTrajectoriesReportProtected', 'EDI', obj.devbench.ip_address);
                fprintf('retrieved ADELexposureTrajectoriesReportProtected with timestamp %s\n', adel_date);
                adelexp_filename = [pwd filesep sprintf('%s%sADELexposureTrajectoriesReport.xml', currentdir, filesep)];
                obj.writeAdel(adelexp_filename, adelexp_txt);
                
                disp('retrieving ADELwaferGridResidualReportProtected');
                [~, adelwfrgridNCE_txt, adel_date] = obj.http.get_last_adel_from_ip('ADELwaferGridResidualReportProtected', 'EDI', obj.devbench.ip_address);
                fprintf('retrieved ADELwaferGridResidualReportProtected with timestamp %s\n', adel_date);
                adelwfrgridNCE_filename = [pwd filesep sprintf('%s%sADELwaferGridResidualReport.xml', currentdir, filesep)];
                obj.writeAdel(adelwfrgridNCE_filename, adelwfrgridNCE_txt);
                
                disp('retrieving ADELwaferHeatingCorrectionsReport');
                [~, adelwhc_txt, adel_date] = obj.http.get_last_adel_from_ip('ADELwaferHeatingCorrectionsReport', 'EDI', obj.devbench.ip_address);
                fprintf('retrieved ADELwaferHeatingCorrectionsReport with timestamp %s\n', adel_date);
                adelwhc_filename = [pwd filesep sprintf('%s%sADELwaferHeatingCorrectionsReport.xml', currentdir, filesep)];
                obj.writeAdel(adelwhc_filename, adelwhc_txt);
                
                disp('retrieving KT_wafers_out');
                bmmoDevbenchSFTPInterface.get_file_from_devbench('KT/KT_wafers_out', obj.devbench.machine_name, obj.devbench.ip_address, currentdir);
                KT_wo = sprintf('%s%sKT_wafers_out', currentdir, filesep);
                
                disp('generating ADELmetrology');
                bmmo_generate_ADELmetrology_simple(KT_wo, adeller);
                movefile('ADELmetrology*', currentdir)              
        end
        
        function uploadBl3AdelsToLis(obj, currentdir)
            allFiles = dir (fullfile(currentdir, '**', '*ADEL*'));
            
            for i = 1:length(allFiles)
                disp(['Uploading ' allFiles(i).name])
                adel_path = [allFiles(i).folder filesep allFiles(i).name];
                response(i) = obj.lisHttp.send_adel_to_ip(adel_path, obj.lis.ip_address);
            end                       
        end
        
        function adeljct = generateAdelJobControl(obj, currentdir, timefilter)
            % todo more robust way of using job control template
            adeljcttemp = '\\asml.com\eu\shared\nl011052\BMMO_NXE_TS\03-Integration\302-Integration_Milestones\LIS_job_for_VCP\TPS\Templates\ADELbmmoOverlayJobControl.xml';
            copyfile(adeljcttemp, currentdir)
            bmmo_create_job_control(currentdir, timefilter);
            [~, name,ext] = fileparts(adeljcttemp);
            adeljct = [name ext];      
            
        end
        
        function writeAdel(obj, filename, adel_txt)
                fid = fopen(filename, 'w');
                fprintf(fid, '%s', adel_txt);
                fclose(fid);
        end
        
    end
end