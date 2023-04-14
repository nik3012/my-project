classdef bmmo_SelfCorrectTsActuation < handle
    %% bmmo_SelfCorrectTsActuation  BMMO NXE & BL3 TS actuation based Self- Correction model.
    %
    % bmmo_SelfCorrectTsActuation Properties:
    % bmmoInputs           - BMMO/BL3 inputs as parsed by bmmo_read_lcp_zip
    % jobConfig            - BMMO/BL3 OTAS/LIS job configuration as given
    %                        in bmmoInputs.info.configuration_data
    % tsActuationConfig    - bmmo_Configuration object
    %                       (eg:bl3_3600D_configuration)
    % timeFilter           - Option to enable or disable time filter.
    %                        Acceptable values include the following:
    %                        {'DEFAULT', 'DISABLED' 'ENABLED'}.By default the
    %                        value 'DISABLED' is set, which disbles the
    %                        time filter for all bmmoInputs. The value 'DEFAULT'
    %                        uses the time filter config available in
    %                        bmmoInputs. The value 'ENABLED' will enable time filter for
    %                        all the bmmoInputs.
    % selfCorrectOutput     - Self-correction outputs containing decorrected input,
    %                        SBC correction, KPIs, WDMs, InvalidatedData
    %                        and other meta data
    
    
    properties (SetAccess = private)
        bmmoInputs struct
        selfCorrectOutput struct
    end
    
    properties (SetObservable)
        jobConfig struct
        tsActuationConfig function_handle
        timeFilter {mustBeValidFilter} = 'DISABLED'
    end
    
    properties (Hidden)
        lisWdm
        lisKpis
        sbcOutput
        invalidData
    end
    
    
    properties (Hidden)
        decorrectOptions
        inputStruct
        mlInputStruct
        inputStructDecorrected
        decorrectedMl
        selfCorrectOptions
        interfieldModelResidual
        interfieldTsResidual
    end
    
    properties (Constant, Hidden)
        validTimeFilter = {'DEFAULT', 'DISABLED' 'ENABLED'}
        defaultPlatform = 'LIS'
    end
    
    methods
        function obj = bmmo_SelfCorrectTsActuation(bmmoInputs, jobConfig,...
                tsActuationConfig)
            % bmmo_SelfCorrectTsActuation constructs object
            %
            % Usage
            %
            %   obj = bmmo_SelfCorrectTsActuation(bmmoInputs)
            %       Constructs the object and estimates jobConfig and
            %       tsActuationConfig using the first input of bmmoInputs.
            %        The other inputs can also be set at a later time
            %
            %   obj = bmmo_SelfCorrectTsActuation(bmmoInputs, jobConfig)
            %       Constructs the object using bmmoInputs and jobConfig.
            %       tsActuationConfig is estimated using the first input within
            %       the bmmoInputs struct
            %
            %   obj = bmmo_SelfCorrectTsActuation(bmmoInputs, jobConfig,...
            %   tsActuationConfig)
            %       Constructs the object using bmmoInputs, jobConfig and
            %       tsActuationConfig.
            %
            % Inputs:
            %
            % bmmoInputs          - BMMO/BL3 inputs as parsed by bmmo_read_lcp_zip
            % jobConfig           - BMMO/BL3 OTAS/LIS job configuration as given
            %                       in bmmoInputs.info.configuration_data
            % tsActuationConfig   - bmmo_Configuration object
            %                      (eg:bl3_3600D_configuration)
            % Outputs (relevant)
            % selfCorrectOutput   - Self-correction outputs containing decorrected input,
    %                               SBC correction, KPIs, WDMs, InvalidatedData
    %                               and other meta data
            
            obj.bmmoInputs = bmmoInputs;
            
            switch nargin
                case 3
                    obj.jobConfig = jobConfig;
                    obj.tsActuationConfig = tsActuationConfig;
                case 2
                    obj.jobConfig = jobConfig;
                    getTsConfigFromFirstInput(obj)
                case 1
                    getJobConfigFromFirstInput(obj)
                    getTsConfigFromFirstInput(obj)
                otherwise
            end
        end
        
        
        function run(obj)
            
            for jobNum = 1: length(obj.bmmoInputs)
                obj.inputStruct = obj.bmmoInputs(jobNum);
                obj.inputStruct.info.configuration_data.platform = obj.defaultPlatform;
                getSelfCorrectModelOptions(obj)
                getDecorrectedInput(obj)
                updateSelfCorrectInputConfiguration(obj)
                runDriftControlModel(obj)
                getInterfieldModelResidual(obj)
                generateInterfieldTsResidual(obj)
                
                obj.selfCorrectOutput(jobNum).bmmoInputsDecorrected = obj.inputStructDecorrected;
                obj.selfCorrectOutput(jobNum).sbcs = obj.sbcOutput;
                obj.selfCorrectOutput(jobNum).kpis = obj.lisKpis;
                obj.selfCorrectOutput(jobNum).wdms.uncontrolledInput = obj.decorrectedMl;
                obj.selfCorrectOutput(jobNum).wdms.interfieldModelResidual = obj.interfieldModelResidual;
                obj.selfCorrectOutput(jobNum).wdms.interfieldTsResidual = obj.interfieldTsResidual;
                obj.selfCorrectOutput(jobNum).chuckUsage = obj.selfCorrectOptions.chuck_usage;
                obj.selfCorrectOutput(jobNum).nLayers = obj.selfCorrectOptions.no_layer_to_use;
                obj.selfCorrectOutput(jobNum).invalidatedData = obj.invalidData;
            end
            generateRawIntrafieldFingerprint(obj)
        end
        
        
        function getSelfCorrectModelOptions(obj)
            
            [obj.mlInputStruct, obj.decorrectOptions] = bmmo_process_input(obj.inputStruct);
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
            
            obj.selfCorrectOptions = obj.decorrectOptions;
            obj.selfCorrectOptions.inline_sdm_config.fnhandle = obj.tsActuationConfig;
            switch obj.jobConfig.bl3_model
                case true
                    obj.selfCorrectOptions.KA_actuation.fnhandle = @bmmo_KA_HOC_fingerprint;
                    obj.selfCorrectOptions.KA_actuation.type = obj.getKaFpActuationFromIntraf...
                        (obj.tsActuationConfig);
                case false
                    obj.selfCorrectOptions.KA_actuation.fnhandle = @bmmo_KA_LOC_CET_fingerprint;
                    obj.selfCorrectOptions.KA_actuation.type = obj.getKaFpActuationFromIntraf...
                        (obj.tsActuationConfig);
            end
        end
        
        
        function getDecorrectedInput(obj)
            
            mlDummy = ovl_create_dummy(obj.mlInputStruct, 'edge', obj.decorrectOptions.wafer_radius_in_mm);
            prevSbc = obj.inputStruct.info.previous_correction;
            decorrectionFps = bmmo_apply_SBC_core(mlDummy,...
                prevSbc, 1, obj.decorrectOptions);
            obj.decorrectedMl = ovl_sub(obj.mlInputStruct,...
                decorrectionFps.TotalSBCcorrection);
            obj.inputStructDecorrected = bmmo_map_to_smf(obj.decorrectedMl, obj.inputStruct);
            
            switch obj.jobConfig.bl3_model
                case true
                    zeroSbc = bmmo_default_output_structure(bl3_default_options_structure);
                    obj.inputStructDecorrected.info.previous_correction = zeroSbc.corr;
                    obj.inputStructDecorrected = bmmo_input_to_bl3(obj.inputStructDecorrected);
                case false
                    zeroSbc = bmmo_default_output_structure(bmmo_default_options_structure);
                    obj.inputStructDecorrected.info.previous_correction = zeroSbc.corr;
                    obj.inputStructDecorrected.info.report_data.inline_sdm_residual = zeroSbc.corr.ffp;
            end
        end
        
        
        function updateSelfCorrectInputConfiguration(obj)
            obj.inputStructDecorrected.info.configuration_data = obj.jobConfig;
            updateTimeFilterState(obj)
        end
        
        
        function runDriftControlModel(obj)
            [out, wdm] = bmmo_nxe_drift_control_model...
                (obj.inputStructDecorrected);
            obj.lisKpis = out.report.KPI;
            obj.sbcOutput = rmfield(out.corr, 'Configurations');
            
            for index = 1:length(out.invalid.invalidated_data)
                for imark = 1:length(out.invalid.invalidated_data(index).mark)
                    obj.invalidData(index).x(imark,:) = ...
                        out.invalid.invalidated_data(index).mark(imark).x;
                    obj.invalidData(index).y(imark,:) = ...
                        out.invalid.invalidated_data(index).mark(imark).y;
                end
            end
            obj.lisWdm = wdm;
        end
        
        
        function getInterfieldModelResidual(obj)
            totalSbcCorrection = ovl_get_wafers(obj.lisWdm.total_filtered.TotalSBCcorrection(1), []);
            for ichk = 1:length(obj.lisWdm.total_filtered.TotalSBCcorrection)
                totalSbcCorrection = ovl_combine_wafers(totalSbcCorrection,...
                    obj.lisWdm.total_filtered.TotalSBCcorrection(ichk));
            end
            totalSbcCorrectionsPerWafer = ovl_get_wafers(totalSbcCorrection, obj.selfCorrectOptions.chuck_usage.chuck_id);
            ffp = obj.sbcOutput.ffp;
            intrafFpsPerWafer = bmmo_INTRAF_par_fingerprint(totalSbcCorrectionsPerWafer, ffp, obj.selfCorrectOptions);
            interfieldModelFpsPerWafer = ovl_sub(totalSbcCorrectionsPerWafer, intrafFpsPerWafer);
            interfieldModelResidualWithIntraf = ...
                ovl_add(obj.decorrectedMl, interfieldModelFpsPerWafer);
            intrafTotal = ovl_average_fields(ovl_average(ovl_get_fields(interfieldModelResidualWithIntraf, obj.selfCorrectOptions.fid_intrafield)));
            obj.interfieldModelResidual = ovl_sub_field(interfieldModelResidualWithIntraf, intrafTotal);
        end
        
        
        function generateInterfieldTsResidual(obj)
            mlDummy = ovl_create_dummy(obj.mlInputStruct, 'edge', obj.selfCorrectOptions.wafer_radius_in_mm);
            fpStruct = bmmo_apply_SBC_core(mlDummy, obj.sbcOutput, 1, obj.selfCorrectOptions);
            tsInterfield = ovl_sub(fpStruct.TotalSBCcorrection, fpStruct.INTRAF);
            interfieldTsResidualWithIntraf = ...
                ovl_add(obj.decorrectedMl, tsInterfield);
            intrafTotal = ovl_average_fields(ovl_average(ovl_get_fields(interfieldTsResidualWithIntraf, obj.selfCorrectOptions.fid_intrafield)));
            obj.interfieldTsResidual = ovl_sub_field(interfieldTsResidualWithIntraf, intrafTotal);
            
        end
        
        
        function generateRawIntrafieldFingerprint(obj)
            for jobNum = 1:length(obj.bmmoInputs)
                obj.selfCorrectOutput(jobNum).wdms.rawIntrafieldFp = ...
                    bmmo_ffp_to_ml_simple(obj.selfCorrectOutput(jobNum).sbcs.ffp);
            end
        end
    end
    
    
    methods % listeners, setters & getters
        
        function updateTimeFilterState(obj)
            switch obj.timeFilter
                case 'DEFAULT'
                    % do nothing
                case 'DISABLED'
                    obj.inputStructDecorrected.info.report_data.time_filtering_enabled = 0;
                case 'ENABLED'% TODO: support adaptive filter case, disabled for now.
                    obj.inputStructDecorrected.info.report_data.time_filtering_enabled = 1;
                    obj.inputStructDecorrected.info.report_data.adaptive_time_filter_enabled = 0;
            end
        end
        
        
        function getTsConfigFromFirstInput(obj)
            config = bmmo_get_inline_sdm_configuration(obj.bmmoInputs(1));
            obj.tsActuationConfig = config.fnhandle;
        end
        
        
        function getJobConfigFromFirstInput(obj)
            obj.jobConfig = obj.bmmoInputs(1).info.configuration_data;
            if ~isfield(obj.jobConfig, 'bl3_model')
                obj.jobConfig.bl3_model = 0;
            end
        end
    end
    
    
    methods (Static)
        function KaFpActuation = getKaFpActuationFromIntraf(IntrafFpActuation)
            configuration = feval(IntrafFpActuation);
            hocActuation = configuration.getConfigurationObject('CetModel');
            KaFpActuation = hocActuation.cetModel;
        end
    end
    
    
end %classdef

function mustBeValidFilter(timeFilter)
mustBeMember(timeFilter, bmmo_RerunTsActuation.validTimeFilter)
end % mustBeValidFilter
