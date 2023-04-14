classdef bmmo_LensModelDefault < bmmo_LensModel
    %% bmmo_LensModelDefault BMMO & BL3 NXE Lens model.
    %
    % This class calculates the KPIs, correction & residuals of the Lens
    % model. For details on the model see the EDS (D000347979)
    %
    % bmmo_LensModelDefault Properties:
    %   mlIn               - Chuck-averaged SBC ffp in ml format
    %   mlInScanIntegrated - Scan integrated mlIn, calculated automatically
    %   mlInDlm            - Input to DLM, calculated automatically
    %   mlOut              - Lens Model correction
    %   mlRes              - Lens Model residual
    %   report             - Lens model KPI report
    %   lensData           - lensData used by DLM
    %   lfp                - SDM Res saved to MC, load with readLfpFromMdl()
    %   timeFilterCoeff    - SBC Intrafield weight factor, only used with lfp
    %
    % bmmo_InlineSdmModelDefault Methods:
    %   calcActuation  - Calculate Lens correction
    %   run            - Calculate Len report & correction
    %   readLfpFromMdl - Read LFP from MDL file into lfp property
    %   distoToZernike - Convert an ml disto to z2, z3 distribution
    %   zernikeToDisto - Convert z2, z3 distribution into ml disto
    %
    % See also:
    %   bmmo_LensModel
    
    properties
        mlIn = ovl_average_fields(...
            ovl_create_dummy('13x19', 'nlayer', 1)); % Chuck-averaged SBC ffp in ml format
        mlWaferIn = bmmo_process_input(bmmo_default_input);
        mlWaferOut
        zernikes 
        lfp double = zeros(1, 13, 64); % SDM Res saved to MC, load with readLfpFromMdl()
        timeFilterCoeff  = 1; % SBC Intrafield weight factor, only used with lfp
    end
    
    properties (SetAccess = private)
        mlOut struct % Lens Model correction
        report = struct('par', []) % Lens model KPI report
        lensData struct % lensData used by DLM
    end
    
    properties (Dependent, SetAccess = private)
        mlInScanIntegrated struct % Input to DLM, calculated automatically
        mlInDlm struct % Input to DLM, calculated automatically
        mlRes struct % Lens Model residual
        mlTemplate struct % Template created from mlWaferIn
    end
    
    methods
        function obj = bmmo_LensModelDefault(configuration, mlIn, mlWaferIn)
            % bmmo_LensModelDefault constructs object
            %
            % Usage
            %
            %   obj = bmmo_LensModelDefault(configuration)
            %       Constructs the object, mlIn can be set at a later time
            %
            %   obj = bmmo_LensModelDefault(configuration, mlIn)
            %       Constructs the object with the mlIn input. The
            %       corrections & report can be immediately generated from the object.
            %
            % Inputs
            %
            %   configuration   bmmo_Configuration object
            %   mlIn            ml structure with 1 wafer & 1 field
            %          Chuck averaged SBC ffp in ml format
            %          Default: all-zeros
            %
            % Outputs
            %
            %   obj    created object
            
            obj@bmmo_LensModel(configuration);
            obj.lensData = ovl_metro_get_lensdata('lenstype', obj.lensType);
            
            switch nargin
                case 3
                    obj.mlIn = mlIn;
                    obj.mlWaferIn = mlWaferIn;
                case 2
                    obj.mlIn = mlIn;
            end
            
            obj.mlOut = obj.mlIn;
            

        end
        
        function run(obj)
            % bmmo_LensDefault method run
            %
            % Usage
            %
            %   obj.run()
            %       Run the Lens model and populate all the
            %       properties with model outputs
            obj.calcReport();
            obj.calcActuation();
        end
        
        function calcReport(obj)
            [z2_dlm_in, z3_dlm_in] = ...
                obj.distoToZernike(obj.mlInDlm, obj.lensData);
            
            [z2_out, z3_out] = obj.DLM_model_z2z3(z2_dlm_in, z3_dlm_in);
            
            obj.mlOut = obj.zernikeToDisto(...
                z2_out, z3_out, obj.lensData, obj.mlInScanIntegrated);
             
            obj.addPobFieldsToReport();
            obj.addLensCorrFieldsToReport();
        end
        
        function calcActuation(obj)
            % bmmo_LensModelDefault method calcCorrection
            %
            % Usage
            %
            %   obj.calcCorrection()
            %       Calculates correction (mlCorr) and residual (mlRes)
            [z2_dlm_in, z3_dlm_in] = ...
                obj.distoToZernike(obj.mlInDlm, obj.lensData);
            
            [z2_out, z3_out] = obj.DLM_model_z2z3(z2_dlm_in, z3_dlm_in);
            
            mlTemp = ovl_average_fields(obj.mlTemplate);
            
            mlLensAct = obj.zernikeToDisto(...
                z2_out, z3_out, obj.lensData, mlTemp);
          
            obj.mlWaferOut = ovl_distribute_field(mlLensAct, obj.mlWaferIn);
        end
        
        function readLfpFromMdl(obj, mdlPath)
            % bmmo_LensModelDefault method readLfpFromMdl
            %
            % Usage
            %
            %   obj.readLfpFromMdl(mdlPath)
            %       Loads the LFP from the MDL file, takes the slit average using the slit weights, and saves it into lfp
            
            loadedMdl = mdl_load(mdlPath, {'+KI-E001'}); %load MDL
            
            LfpZernikesFromMdlCell = loadedMdl.dat.LFP_data; % Extract LFP data from MDL
                       
            % Preallocating zernikeDecompositionLFP
            LfpZernikesFromMdl = zeros(length(LfpZernikesFromMdlCell.y), length(LfpZernikesFromMdlCell.y(1).zd), length(LfpZernikesFromMdlCell.y(1).zd{1,1}));
            
            % Loop over the height of the slit (different y values)
            for index = 1 : length(LfpZernikesFromMdlCell.y)
                % For each y value, create a matrix from the cell struct
                % stored in LFPzernikesFromMdl. Need to take transposes
                % twice to make dimensions match.
                LfpZernikesFromMdl(index, :, :) = cell2mat(LfpZernikesFromMdlCell.y(index).zd')';
            end
            
            % Take a weighted average over the slit (y-direction) using the
            % slit weights (5x13) stored in lensData, and shifting to make Z2 
            % and Z3 the second and third indices in the third dimension. 
            % This collapses the 5x13x101 structure into a 1x13x100 structure.
            slitAveragedZernikesLfp = zeros([1, size(LfpZernikesFromMdl, 2, 3)]);
            for index = 2 : size(slitAveragedZernikesLfp, 3)
                slitAveragedZernikesLfp(1, :, index-1) = sum(LfpZernikesFromMdl(:, :, index).*obj.lensData.Generic.Lens.Slit_Weights, 1);
            end
            
            % Scale slit-averaged coefficients back from NM scale
            obj.lfp = slitAveragedZernikesLfp(:, :, (1 : size(obj.lfp, 3))) * 1e9;
        end
    end
    
    methods % Setters & Getters
        
        function set.mlWaferIn(obj, val)
            obj.mlWaferIn = val;
        end
        function val = get.mlInScanIntegrated(obj)
            val = ovl_scan_integrate(obj.mlIn);
        end
        
        function val = get.mlInDlm(obj)
            val = ovl_average_columns(obj.mlInScanIntegrated);
        end
        
        function val = get.mlRes(obj)
            val = ovl_sub(obj.mlInScanIntegrated, obj.mlOut);
        end
        function val = get.mlTemplate(obj)
            val = ovl_create_dummy(obj.mlWaferIn, 'nwafer', 1);
        end
        
    end
    
    methods (Access = private)
        function [z2_out, z3_out, dynamicCorrection, fadingCorrection] = ...
                DLM_model_z2z3(obj, z2_in, z3_in)
            
            % input and output(correctables) are in nm scale
            % (No unit conversion within the file)
            % Choose DLM
            driverLensModelResults = lm_calc_lens_model(obj.lensData.Generic, obj.lensData.DLM.LM(1));
            
            
            % Initialize structure containing Z2 and Z3 inputs
            sizeLfp = size(obj.lfp);
            zernikesFfp = zeros(sizeLfp); % field of 64 zernikes, all zeros (1x13x64)
            zernikesFfp(:,:,2) = z2_in;
            zernikesFfp(:,:,3) = z3_in;

            % Extract Z2 and Z3 stored in LFP property
            slitAveragedZernikesLfp  = zeros(sizeLfp); % field of 64 zernikes, all zeros (1x13x64)
            slitAveragedZernikesLfp(:, :, (2 : 3)) = obj.lfp(:, :, (2 : 3)) * obj.timeFilterCoeff;
            
            % convert to Aber struct (5x13x64)
            aberrationsFfp = lm_calc_aberrations(zernikesFfp, 1:sizeLfp(3));
            aberrationsLfp  = lm_calc_aberrations(slitAveragedZernikesLfp, 1:sizeLfp(3));
            
            aberrationsDlmIn = aberrationsFfp;
            aberrationsDlmIn.Zernikes(:, :, 2:3)  = aberrationsFfp.Zernikes(:, :, 2:3)...
                + aberrationsLfp.Zernikes(:, :, 2:3);  %% Image tuner way
            beforeModel.Zernikes = aberrationsDlmIn.Zernikes;
            obj.report.par.m_before = max(max(abs(aberrationsDlmIn.Zernikes), [], 2), [], 1);
            
            % Calculate the adjustment corresponding to the aberration
            obj.report.adjPob = lm_calc_adjustments(driverLensModelResults, aberrationsDlmIn);    % adj in [um and urad]
            Corr = lm_calc_correction(obj.lensData.Generic, obj.report.adjPob); % Corr in [nm]
            obj.report.staticCorrZ = Corr;
            
            afterModel.Zernikes = beforeModel.Zernikes;
            for index = 1:size(Corr.Zernikes, 3)
                afterModel.Zernikes(:, :, index) = beforeModel.Zernikes(:, :, index) ...
                    + Corr.Zernikes(:, :, index);
            end
            
            obj.report.par.m_after = max(max(abs(afterModel.Zernikes), [], 2), [], 1);
            
            % Scan integrate lens Correctables of Zernikes
            % and separate Scan integrated part and fading
            
            % Dyn_corr = scan integrate(Corr),
            % Fad_corr = Corr(13x5 :copied in y) - Dyn_corr
            [dynamicCorrection, fadingCorrection] = lm_scan_integrate(obj.lensData.Generic, Corr);
            dynamicCorrectionZernikes = (-1) * lm_get_zernikes(dynamicCorrection, 1:sizeLfp(3));
            
            z2_out = dynamicCorrectionZernikes(3, :, 2);
            z3_out = dynamicCorrectionZernikes(3, :, 3);
        end
        
        
        function addPobFieldsToReport(obj)
            reportNames = {'Ob_z', 'Ob_Rx', 'Ob_Ry', 'Im_x', 'Im_y', ...
                'Im_z', 'Im_Rx', 'Im_Ry', 'Im_Rz'}; 
            adjPobNames = {'Reticle.Z', 'Reticle.Rx', 'Reticle.Ry', ...
                'Wafer.X', 'Wafer.Y', 'Wafer.Z', 'Wafer.Rx', ...
                'Wafer.Ry', 'Wafer.Rz'};
            
            mirrorParamsRep = ["x", "y", "z", "Rx", "Ry", "Rz"];
            mirrorParamsPob = ["X", "Y", "Z", "Rx", "Ry", "Rz"];
            for iMirror = 1:6
                for jMiPar = 1:length(mirrorParamsRep)
                    reportNames{end + 1} = sprintf("Mi%d_" + ...
                        mirrorParamsRep(jMiPar),  iMirror);
                    adjPobNames{end + 1} = sprintf("Mirror%d." + ...
                        mirrorParamsPob(jMiPar), iMirror);
                end
            end
            
            for iNames = 1:length(reportNames)
                obj.extractField(reportNames{iNames}, adjPobNames{iNames});
            end
        end
        
        function addLensCorrFieldsToReport(obj)
            mlInColAvg = ovl_average_columns(obj.mlIn);
            obj.report.Cor.lens.Z2 = spline(mlInColAvg.wd.xf', ...
                mlInColAvg.layer.wr.dx', obj.lensData.X) ...
                * obj.lensData.Generic.Lens.Factors.dZ2_dX ; %[m]
            obj.report.Cor.lens.Z3 = spline(mlInColAvg.wd.xf', ...
                mlInColAvg.layer.wr.dy', obj.lensData.X) ...
                * obj.lensData.Generic.Lens.Factors.dZ3_dY ; %[m]
            
            % KPI4, RES1
            lensRes = ovl_sub(obj.mlInScanIntegrated, obj.mlOut);
            obj.report.Kpi.maxLensRes.dx = max(abs(lensRes.layer.wr.dx));
            obj.report.Kpi.maxLensRes.dy = max(abs(lensRes.layer.wr.dy));
            obj.report.Res.Lens.dx = lensRes.layer.wr.dx;
            obj.report.Res.Lens.dy = lensRes.layer.wr.dy;
            
            % KPI2
            obj.report.Kpi.maxLensCorr.dx = max(abs(obj.mlOut.layer.wr.dx));
            obj.report.Kpi.maxLensCorr.dy = max(abs(obj.mlOut.layer.wr.dy));
            
            % KPI6
            z2 = mlInColAvg.layer.wr.dx ...
                * obj.lensData.Generic.Lens.Factors.dZ2_dX;
            p = polyfit(obj.lensData.X * 100, z2' * 1e9, 3);  % m - > cm, m -> nm
            z2_2 = p(2);
            
            z3 = mlInColAvg.layer.wr.dy ...
                * obj.lensData.Generic.Lens.Factors.dZ3_dY;
            p=polyfit(obj.lensData.X * 100, z3' * 1e9, 3);  % m - > cm
            z3_2 = p(2);   % m -> nm
            
            obj.report.Kpi.z2_2 = z2_2;
            obj.report.Kpi.z3_2 = z3_2;
        end
        
        function extractField(obj, reportName, adjPobName)
            obj.report.parMc.lens.(reportName)...
                = obj.report.adjPob(find(strcmp(cellstr(obj.lensData...
                .Generic.Manipulator.Name), adjPobName)));
        end
    end
    
    methods (Static = true)
        function [z2, z3] = distoToZernike(mlIn, lensData)
            % bmmo_LensDefault method distoToZernike
            % This method converts a field disto (mlIn) into a z2 & z3
            % Zernike distribution
            %
            % Usage
            %
            % [z2, z3] = distoToZernike(mlIn, lensData)
            %
            % Inputs
            %
            %   mlIn     ml structure 
            %            Containing 1 wafer & 1 field
            %   lensData structure 
            %            lensData structure, loaded from 
            %            ovl_metro_get_lensdata
            %
            % Outputs
            %
            %   z2       structure
            %            Zernike z2 distribution
            %   z3       structure
            %            Zernike z3 distribution
            
            xs = spline(mlIn.wd.xf', mlIn.layer.wr.dx', lensData.X);
            ys = spline(mlIn.wd.xf', mlIn.layer.wr.dy', lensData.X);
            
            z2 = xs * lensData.Generic.Lens.Factors.dZ2_dX * 1e+09; %[nm]
            z3 = ys * lensData.Generic.Lens.Factors.dZ3_dY * 1e+09; %[nm]
        end
        
        function mlOut = zernikeToDisto(z2, z3, lensData, mlIn)
            % bmmo_LensDefault method distoToZernike
            % This method converts a z2 & z3 Zernike distribution into a
            % field disto based on the template (mlIn)
            %
            % Usage
            %
            % mlOut = zernikeToDisto(z2, z3, mlIn, lensData)
            %
            % Inputs
            %
            %   z2       structure
            %            Zernike z2 distribution
            %   z3       structure
            %            Zernike z3 distribution
            %   lensData structure 
            %            lensData structure, loaded from 
            %            ovl_metro_get_lensdata
            %   mlIn     ml structure 
            %            Containing 1 wafer & 1 field, used as template
            %
            % Outputs
            %
            %   mlOut    ml structure 
            %            With same structure as mlIn
            
            dx_corr_line = z2 / lensData.Generic.Lens.Factors.dZ2_dX * 10^(-9);
            dy_corr_line = z3 / lensData.Generic.Lens.Factors.dZ3_dY * 10^(-9);
            
            % calculate the effect of the LM correction in terms of
            % the avg disto field
            mlOut = mlIn;
            % use spline for the backward translation from
            % 13 points to the measured x positions
            mlOut.layer.wr.dx = spline(lensData.X, dx_corr_line, mlOut.wd.xf);
            mlOut.layer.wr.dy = spline(lensData.X, dy_corr_line, mlOut.wd.xf);
        end
    end
end

