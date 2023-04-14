classdef  bmmo_RecorrectTsActuation < handle
    %% bmmo_RecorrectTsActuation  BMMO NXE & BL3 TS actuation Recorrection model.
    %
    % bmmo_RecorrectTsActuation Properties:
    % tsActuationConfig        - bmmo_Configuration object
    %                           (eg:bl3_3600D_configuration)
    % bmmoInput                - BMMO/BL3 input as parsed by bmmo_read_lcp_zip
    % recorrectionSbc          - SBC correction used for recorrection
    % kaFpActuationBaseliner3  - KA actuation method used for BL3
    %                            recorrectionSbc (determined using
    %                            tsActuationConfig)
    % kaFpActuationBmmo        - KA actuation method used for BMMO
    %                            recorrectionSbc (Constant)
    % defaultPlatform          - Platform (Constant) used for calculation of
    %                            recorrection and decorrection fingerprints
    % mlBmmoInput              - ml structure of bmmoInput
    % decorrectedMl            - ml structure of de-corrected bmmoInput
    % decorrectOptions         - Decorrection FPS calculation option struct
    % recorrectOptions         - Recorrection FPS calculation option struct
    % decorrectionFps          - FPS calculated for bmmoInput de-correction
    % recorrectionFps          - FPS calculated for bmmoInput re-correction
    % bmmoInputRecorrected     - bmmoInput after applying decorrectionFps &
    %                            recorrectionFps
    
    properties (SetObservable)
        tsActuationConfig function_handle
    end
    
    properties
        bmmoInput struct
        recorrectionSbc struct
        kaFpActuationBaseliner3 char
        decorrectedMl
    end
    
    properties (Constant)
        defaultPlatform = 'LIS'
    end
    
    properties (SetAccess = private)
        mlBmmoInput
        decorrectOptions
        recorrectOptions
        decorrectionFps
        recorrectionFps
        bmmoInputRecorrected
    end
    
    properties (Access = private)
        recorrectionSbcType
        bmmoDefaultInput = bmmo_default_input
        bmmoDefaultOutput = bmmo_default_output_structure(bmmo_default_options_structure)
    end
    
    
    
    methods
        function obj = bmmo_RecorrectTsActuation(tsActuationConfig, bmmoInput,...
                recorrectionSbc)
            % bmmo_RecorrectTsActuation constructs object
            %
            % Usage
            %
            %   obj = bmmo_RecorrectTsActuation(tsActuationConfig)
            %       Constructs the object using tsActuationConfig. Default
            %       vaules (zero) are given to other inputs and can be set later
            %
            %   obj = bmmo_RecorrectTsActuation(tsActuationConfig, bmmoInput)
            %       Constructs the object using tsActuationConfig and bmmoInput.
            %       Default output structure is set for recorrectionSbc
            %
            % Inputs
            %
            % tsActuationConfig        - bmmo_Configuration object
            %                           (eg:bl3_3600D_configuration)
            % bmmoInput                - BMMO/BL3 input as parsed by bmmo_read_lcp_zip
            % recorrectionSbc          - SBC correction used for recorrection
            %
            % Outputs (relevant)
            % bmmoInputRecorrected     - bmmoInput after applying decorrectionFps &
            %                            recorrectionFps
            
            obj.tsActuationConfig = tsActuationConfig;
            
            switch nargin
                case 3
                    obj.bmmoInput = bmmoInput;
                    obj.recorrectionSbc = recorrectionSbc;
                case 2
                    obj.bmmoInput = bmmoInput;
                    obj.recorrectionSbc = obj.bmmoDefaultOutput.corr;
                case 1
                    obj.bmmoInput = obj.bmmoDefaultInput;
                    obj.recorrectionSbc = obj.bmmoDefaultOutput.corr;
            end
            
            obj.kaFpActuationBaseliner3 = obj.getKaFpActuationFromIntraf(obj.tsActuationConfig);
            addlistener(obj,{'tsActuationConfig'},'PostSet',@obj.handleKaActuationChange);
        end
        
        
        function run(obj)
            
            getRecorrectionModelOptions(obj)
            modelRecorrectionFps(obj)
            applyRecorrectionToBmmoInput(obj)
            
            switch obj.recorrectionSbcType
                case 'Baseliner 3'
                    updateBaseliner3InputNce(obj)
                case 'BMMO NXE'
                    updateBmmoNxeInputNce(obj)
            end
        end
        
        function getRecorrectionModelOptions(obj)
            [obj.mlBmmoInput, obj.decorrectOptions] = bmmo_process_input(obj.bmmoInput);
            obj.decorrectOptions.intraf_actuation.fnhandle = @bmmo_INTRAF_inline_SDM_fingerprint;
            
            switch obj.decorrectOptions.bl3_model
                case true
                    obj.decorrectOptions.KA_actuation.fnhandle = @bmmo_KA_HOC_fingerprint;
                    obj.decorrectOptions.KA_actuation.type = obj.getKaFpActuationFromIntraf...
                        (obj.decorrectOptions.inline_sdm_config.fnhandle);
                case false
                    obj.decorrectOptions.KA_actuation.fnhandle = @bmmo_KA_LOC_CET_fingerprint;
                    obj.decorrectOptions.KA_actuation.type = obj.getKaFpActuationFromIntraf...
                        (obj.decorrectOptions.inline_sdm_config.fnhandle);

            end
            
            obj.recorrectOptions = obj.decorrectOptions;
            obj.recorrectOptions.inline_sdm_config.fnhandle = obj.tsActuationConfig;
            switch obj.recorrectionSbcType
                case 'Baseliner 3'
                    obj.recorrectOptions.KA_actuation.fnhandle = @bmmo_KA_HOC_fingerprint;
                    obj.recorrectOptions.KA_actuation.type = obj.kaFpActuationBaseliner3;
                case 'BMMO NXE'
                    obj.recorrectOptions.KA_actuation.fnhandle = @bmmo_KA_LOC_CET_fingerprint;
                    obj.recorrectOptions.KA_actuation.type = obj.kaFpActuationBaseliner3;
            end
        end
        
        
        function modelRecorrectionFps(obj)
            mlDummy = ovl_create_dummy(obj.mlBmmoInput, 'edge', obj.decorrectOptions.wafer_radius_in_mm);
            prevSbc = obj.bmmoInput.info.previous_correction;
            obj.decorrectionFps = bmmo_apply_SBC_core(mlDummy,...
                prevSbc, 1, obj.decorrectOptions);
            
            obj.recorrectionFps  = bmmo_apply_SBC_core(mlDummy,...
                obj.recorrectionSbc, 1, obj.recorrectOptions);
        end
        
        
        function applyRecorrectionToBmmoInput(obj)
            obj.decorrectedMl = ovl_sub(obj.mlBmmoInput,...
                obj.decorrectionFps.TotalSBCcorrection);
            recorrectedMl = ovl_add(obj.decorrectedMl,...
                obj.recorrectionFps.TotalSBCcorrection);
            obj.bmmoInputRecorrected = bmmo_map_to_smf(recorrectedMl, obj.bmmoInput);
            obj.bmmoInputRecorrected.info.previous_correction = obj.recorrectionSbc;
        end
        
        
        function updateBaseliner3InputNce(obj)
            [recorrectKaCorr, recorrectKaRes] = obj.calculateKaCetCorrection(obj.mlBmmoInput, ...
                obj.recorrectionSbc.KA, obj.recorrectOptions);
            obj.bmmoInputRecorrected.info.report_data.KA_cet_corr = recorrectKaCorr;
            obj.bmmoInputRecorrected.info.report_data.KA_cet_nce = recorrectKaRes;
            obj.bmmoInputRecorrected.info.report_data.inline_sdm_residual = obj.calculateIntrafReportedNce...
                (obj.recorrectionSbc.ffp, obj.recorrectOptions);
            
            
            if isfield(obj.bmmoInput.info.configuration_data, 'bl3_model') &&...
                    obj.bmmoInput.info.configuration_data.bl3_model
                
                [~, decorrectKaRes] = obj.calculateKaCetCorrection(obj.mlBmmoInput, ...
                    obj.bmmoInput.info.previous_correction.KA, obj.decorrectOptions);
                DeltaKaRes = ovl_sub(recorrectKaRes, decorrectKaRes);
                
                obj.bmmoInputRecorrected.info.report_data.cet_residual = ovl_add...
                    (obj.bmmoInputRecorrected.info.report_data.cet_residual, DeltaKaRes);
                
                if ~isfield(obj.bmmoInput.info.report_data,'inline_sdm_cet_residual')
                    obj.bmmoInputRecorrected.info.report_data.inline_sdm_cet_residual =...
                        obj.calculateIntrafReportedNce...
                        (obj.bmmoInput.info.previous_correction.ffp, obj.decorrectOptions);
                end
                
            else
                obj.bmmoInputRecorrected.info.report_data.cet_residual = recorrectKaRes;
                obj.bmmoInputRecorrected.info.report_data.inline_sdm_cet_residual = ...
                    obj.bmmoDefaultOutput.corr.ffp;
            end
        end
        
        
        function updateBmmoNxeInputNce(obj)
            obj.bmmoInputRecorrected.info.report_data.inline_sdm_residual = obj.calculateIntrafReportedNce...
                (obj.recorrectionSbc.ffp, obj.recorrectOptions);
        end
        
        
        function handleKaActuationChange(obj,~, ~)
            obj.kaFpActuationBaseliner3 = obj.getKaFpActuationFromIntraf(obj.tsActuationConfig);
        end
        
        
        function val = get.recorrectionSbcType(obj)
            sbc_configuration = bmmo_configuration_from_sbc(obj.recorrectionSbc);
            if sbc_configuration.bl3_model
                val = 'Baseliner 3';
            else
                val = 'BMMO NXE';
            end
        end
        
        
        function set.bmmoInput(obj, val)
            val.info.configuration_data.platform = obj.defaultPlatform;
            obj.bmmoInput = val;
        end
    end
    
    
    methods (Static)
        function KaFpActuation = getKaFpActuationFromIntraf(IntrafFpActuation)
            configuration = feval(IntrafFpActuation);
            hocActuation = configuration.getConfigurationObject('CetModel');
            KaFpActuation = hocActuation.cetModel;
        end
        
        
        function [inlineSdmRes, inlineCetSdmRes] = calculateIntrafReportedNce(IntrafSbc, options)
            isdmConfig = feval(options.inline_sdm_config.fnhandle);
            inlineSDM = isdmConfig.getConfigurationObject('InlineSdmModel');
            inlineSDM.mlDistoIn = bmmo_ffp_to_ml_simple(IntrafSbc);
            inlineSDM.calcReport;
            inlineSdmRes = inlineSDM.mlToFfp(inlineSDM.report.res);
            inlineCetSdmRes = inlineSDM.mlToFfp(inlineSDM.report.hoc.mlHocResSrr);
        end
        
        
        function [mlKaCorr, mlKaRes] = calculateKaCetCorrection(ml, KaSbc, options)
            mlKaInput = ovl_create_dummy(ml, 'marklayout',...
                options.CET_marklayout,'nwafer',1, 'edge', 200);
            mlKaCorrPerChuck = ovl_get_wafers(mlKaInput,[]);
            mlKaResPerChuck = ovl_get_wafers(mlKaInput,[]);
            mlKaCorrTemp = mlKaInput;
            
            for ic = 1:length(KaSbc.grid_2de)
                ka_grid = bmmo_KA_corr_to_grid(KaSbc.grid_2de(ic));
                mlKaCorrTemp.layer.wr.dx = ka_grid.interpolant_x(mlKaInput.wd.xw, mlKaInput.wd.yw);
                mlKaCorrTemp.layer.wr.dy = ka_grid.interpolant_y(mlKaInput.wd.xw, mlKaInput.wd.yw);
                mlKaResTemp = bmmo_cet_model(mlKaCorrTemp, options.KA_actuation.type);
                mlKaCorrPerChuck = ovl_combine_wafers(mlKaCorrPerChuck, mlKaCorrTemp);
                mlKaResPerChuck = ovl_combine_wafers(mlKaResPerChuck, mlKaResTemp);
            end
            
            mlKaCorr = ovl_get_wafers(mlKaCorrPerChuck, options.chuck_usage.chuck_id);
            mlKaRes = ovl_get_wafers(mlKaResPerChuck, options.chuck_usage.chuck_id);
        end
    end
    
end