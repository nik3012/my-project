classdef bmmo_RerunTsActuation < handle
    %% bmmo_RerunTsActuation  BMMO NXE & BL3 TS actuation based Re-run model.
    %
    % bmmo_RerunTsActuation Properties:
    % bmmoInputs           - BMMO/BL3 inputs as parsed by bmmo_read_lcp_zip
    % jobConfig            - BMMO/BL3 OTAS/LIS job configuration as given
    %                        in bmmoInputs.info.configuration_data
    % tsActuationConfig    - bmmo_Configuration object
    %                       (eg:bl3_3600D_configuration)
    % recoveryOnFirstInput - When set to true,de-corrects first input &
    %                        recorrects with zero SBC correction
    % recorrect            - bmmo_RecorrectTsActuation object
    % timeFilter           - Option to enable or disable time filter.
    %                        Acceptable values include the following:
    %                        {'DEFAULT', 'DISABLED' 'ENABLED'}.By default the
    %                        value 'DEFAULT' is set which uses the
    %                        time filter config present in bmmoInputs. Time filter
    %                        values can be set in property jobConfig.filter. Please
    %                        note if property recoveryOnFirstInput is set to
    %                        true, then the first input will always have disabled
    %                        time filter.
    % rerunOutput          - Re-run outputs containing recorrected input,
    %                        SBC correction, KPIs, WDMs, InvalidatedData
    %                        and other meta data
    
    
    properties (SetAccess = private)
        bmmoInputs struct
        recorrect bmmo_RecorrectTsActuation
        rerunOutput struct
        recorrectionFpsPerChuck
    end
    
    properties (SetObservable)
        jobConfig struct
        tsActuationConfig function_handle
        timeFilter {mustBeValidFilter} = 'DEFAULT'
    end
    
    properties
        recoveryOnFirstInput(1,1) logical
    end
    
    properties (Hidden)
        lisWdm
    end
    properties (Dependent, Hidden)
        zeroSbc
    end
    
    properties (Constant, Hidden)
        validTimeFilter = {'DEFAULT', 'DISABLED' 'ENABLED'}
    end
    
    methods
        function obj = bmmo_RerunTsActuation(bmmoInputs, jobConfig,...
                tsActuationConfig, recoveryOnFirstInput)
            % bmmo_RerunTsActuation constructs object
            %
            % Usage
            %
            %   obj = bmmo_RerunTsActuation(bmmoInputs)
            %       Constructs the object and estimates jobConfig and
            %       tsActuationConfig using the first input of bmmoInputs.
            %        The other inputs can also be set at a later time
            %
            %   obj = bmmo_RerunTsActuation(bmmoInputs, jobConfig)
            %       Constructs the object using bmmoInputs and jobConfig.
            %       tsActuationConfig is estimated using the first input within
            %       the bmmoInputs struct
            %
            %   obj = bmmo_RerunTsActuation(bmmoInputs, jobConfig,...
            %   tsActuationConfig)
            %       Constructs the object using bmmoInputs,jobConfig and
            %       tsActuationConfig. recoveryOnFirstInput is set to false by
            %       default when not provided as an input
            %
            %   obj = bmmo_RerunTsActuation(bmmoInputs, jobConfig,...
            %   tsActuationConfig, recoveryOnFirstInput)
            %       Constructs the objedct with all inputs. The rerunOutput
            %       can then be immediately generated from the object.
            %
            % Inputs
            %
            % bmmoInputs          - BMMO/BL3 inputs as parsed by bmmo_read_lcp_zip
            % jobConfig           - BMMO/BL3 OTAS/LIS job configuration as given
            %                       in bmmoInputs.info.configuration_data
            % tsActuationConfig   - bmmo_Configuration object
            %                      (eg:bl3_3600D_configuration)
            % recoveryOnFirstInput - de-corrects first input &
            %                        re-corrects with zero SBC correction
            % Outputs (relevant)
            % rerunOutput         - Re-run outputs containing recorrected input,
            %                       SBC correction, KPIs, WDMs, InvalidatedData
            %                       and other meta data
            
            obj.bmmoInputs = bmmoInputs;
            
            switch nargin
                case 4
                    obj.jobConfig = jobConfig;
                    obj.tsActuationConfig = tsActuationConfig;
                    obj.recoveryOnFirstInput = recoveryOnFirstInput;
                case 3
                    obj.jobConfig = jobConfig;
                    obj.tsActuationConfig = tsActuationConfig;
                    obj.recoveryOnFirstInput = false;
                case 2
                    obj.jobConfig = jobConfig;
                    getTsConfigFromFirstInput(obj)
                    obj.recoveryOnFirstInput = false;
                case 1
                    getJobConfigFromFirstInput(obj)
                    getTsConfigFromFirstInput(obj)
                    obj.recoveryOnFirstInput = false;
                otherwise
            end
            
            defineRecorrectobj(obj)
            addlistener(obj,{'tsActuationConfig'},'PostSet',@obj.handleRecorrectChange);
        end
        
        
        function run(obj)
            executeRerunOnFirstInput(obj)
            executeRerunOnRemainingInputs(obj)
            generateInterfieldTsResidual(obj)
            generateRawIntrafieldFingerprint(obj)
        end
        
        
        function executeRerunOnFirstInput(obj)
            
            iterNum = 1;
            obj.recorrect.bmmoInput = obj.bmmoInputs(iterNum);
            switch obj.recoveryOnFirstInput
                case true
                    obj.recorrect.recorrectionSbc = obj.zeroSbc;
                    obj.recorrect.run
                    obj.rerunOutput(iterNum).bmmoInputsRecorrected = ...
                        obj.recorrect.bmmoInputRecorrected;
                    updateRerunInputConfiguration(obj, iterNum)
                    obj.rerunOutput(iterNum).bmmoInputsRecorrected.info.report_data.time_filtering_enabled = 0;
                case false
                    obj.recorrect.recorrectionSbc = ...
                        obj.recorrect.bmmoInput.info.previous_correction;
                    obj.recorrect.run
                    obj.rerunOutput(iterNum).bmmoInputsRecorrected = ...
                        obj.recorrect.bmmoInputRecorrected;
                    updateRerunInputConfiguration(obj, iterNum)
            end
            getInterfieldRecorrectionFps(obj, iterNum)
            obj.rerunOutput(iterNum).chuckUsage = obj.recorrect.recorrectOptions.chuck_usage;
            obj.rerunOutput(iterNum).nLayers = obj.recorrect.recorrectOptions.no_layer_to_use;
            obj.rerunOutput(iterNum).wdms.uncontrolledInput = obj.recorrect.decorrectedMl;
            runDriftControlModel(obj, iterNum)
            getInterfieldModelResidual(obj,iterNum)
        end
        
        
        function executeRerunOnRemainingInputs(obj)
            
            for iterNum = 2:length(obj.bmmoInputs)
                obj.recorrect.bmmoInput = obj.bmmoInputs(iterNum);
                obj.recorrect.recorrectionSbc = obj.rerunOutput(iterNum-1).sbcs;
                obj.recorrect.run
                obj.rerunOutput(iterNum).bmmoInputsRecorrected = ...
                    obj.recorrect.bmmoInputRecorrected;
                updateRerunInputConfiguration(obj, iterNum)
                getInterfieldRecorrectionFps(obj, iterNum)
                obj.rerunOutput(iterNum).chuckUsage = obj.recorrect.recorrectOptions.chuck_usage;
                obj.rerunOutput(iterNum).nLayers = obj.recorrect.recorrectOptions.no_layer_to_use;
                obj.rerunOutput(iterNum).wdms.uncontrolledInput = obj.recorrect.decorrectedMl;
                runDriftControlModel(obj, iterNum)
                getInterfieldModelResidual(obj,iterNum)
            end
        end
        
        
        function updateRerunInputConfiguration(obj, iterNum)
            obj.rerunOutput(iterNum).bmmoInputsRecorrected.info.configuration_data = obj.jobConfig;
            updateTimeFilterState(obj, iterNum)
        end
        
        
        function getInterfieldRecorrectionFps(obj, iterNum) 
            recorrectionFpsInterfPerWafer = ...
                ovl_sub(obj.recorrect.recorrectionFps.TotalSBCcorrection,...
                obj.recorrect.recorrectionFps.INTRAF); 
            recorrectionFpsInterfPerChuck = bmmo_average_chuck(recorrectionFpsInterfPerWafer, ...
                obj.recorrect.recorrectOptions);
            obj.recorrectionFpsPerChuck(iterNum).interf = ovl_get_wafers(recorrectionFpsInterfPerChuck(1), []);
            for ichk = 1:length(recorrectionFpsInterfPerChuck)
                obj.recorrectionFpsPerChuck(iterNum).interf = ovl_combine_wafers(...
                    obj.recorrectionFpsPerChuck(iterNum).interf, recorrectionFpsInterfPerChuck(ichk));
            end
        end
        
        
        function runDriftControlModel(obj, iterNum)
            [out, wdm] = bmmo_nxe_drift_control_model...
                (obj.rerunOutput(iterNum).bmmoInputsRecorrected);
            obj.rerunOutput(iterNum).kpis = out.report.KPI;
            obj.rerunOutput(iterNum).sbcs = rmfield(out.corr, 'Configurations');
            
            for index = 1:length(out.invalid.invalidated_data)
                for imark = 1:length(out.invalid.invalidated_data(index).mark)
                    obj.rerunOutput(iterNum).invalidatedData(index).x(imark,:) = ...
                        out.invalid.invalidated_data(index).mark(imark).x;
                    obj.rerunOutput(iterNum).invalidatedData(index).y(imark,:) = ...
                        out.invalid.invalidated_data(index).mark(imark).y;
                end
            end
            obj.lisWdm = wdm;
        end
        
        function getInterfieldModelResidual(obj,iterNum)
            totalSbcCorrection = ovl_get_wafers(obj.lisWdm.total_filtered.TotalSBCcorrection(1), []);
            for ichk = 1:length(obj.lisWdm.total_filtered.TotalSBCcorrection)
                totalSbcCorrection = ovl_combine_wafers(totalSbcCorrection,...
                    obj.lisWdm.total_filtered.TotalSBCcorrection(ichk));
            end
            optionStruct = obj.recorrect.recorrectOptions;
            totalSbcCorrectionsPerWafer = ovl_get_wafers(totalSbcCorrection, optionStruct.chuck_usage.chuck_id);
            ffp = obj.rerunOutput(iterNum).sbcs.ffp;
            intrafFpsPerWafer = bmmo_INTRAF_par_fingerprint(totalSbcCorrectionsPerWafer, ffp, optionStruct);
            interfieldModelFpsPerWafer = ovl_sub(totalSbcCorrectionsPerWafer, intrafFpsPerWafer);
            interfieldModelResidualWithIntraf = ...
                ovl_add(obj.rerunOutput(iterNum).wdms.uncontrolledInput, interfieldModelFpsPerWafer);
            intrafTotal = ovl_average_fields(ovl_average(ovl_get_fields(interfieldModelResidualWithIntraf, optionStruct.fid_intrafield)));
            obj.rerunOutput(iterNum).wdms.interfieldModelResidual = ovl_sub_field(interfieldModelResidualWithIntraf, intrafTotal);
        end
        
        
        function generateInterfieldTsResidual(obj)
            for iterNum = 1:length(obj.bmmoInputs)-1
                Fps(iterNum).tsInterfield = ovl_get_wafers(obj.recorrectionFpsPerChuck(iterNum+1).interf,...
                    obj.rerunOutput(iterNum).chuckUsage.chuck_id);
            end
            
            lastIter = length(obj.bmmoInputs);
            lastBmmoDecorrectedMl = obj.rerunOutput(lastIter).wdms.uncontrolledInput;
            lastOptionStruct = obj.recorrect.recorrectOptions;
            lastSbc = obj.rerunOutput(lastIter).sbcs;
            fpStruct = bmmo_apply_SBC_core(lastBmmoDecorrectedMl, lastSbc, 1, lastOptionStruct);    
            Fps(lastIter).tsInterfield = ovl_sub(fpStruct.TotalSBCcorrection, fpStruct.INTRAF);
            
            for iterNum = 1:length(obj.bmmoInputs)
                interfieldTsResidualWithIntraf = ...
                    ovl_add(obj.rerunOutput(iterNum).wdms.uncontrolledInput, Fps(iterNum).tsInterfield);
                intrafTotal = ovl_average_fields(ovl_average(ovl_get_fields(interfieldTsResidualWithIntraf, lastOptionStruct.fid_intrafield)));
                obj.rerunOutput(iterNum).wdms.interfieldTsResidual = ovl_sub_field(interfieldTsResidualWithIntraf, intrafTotal);
            end
        end
        
        
        function generateRawIntrafieldFingerprint(obj)
            for iterNum = 1:length(obj.bmmoInputs)
                obj.rerunOutput(iterNum).wdms.rawIntrafieldFp = ...
                    bmmo_ffp_to_ml_simple(obj.rerunOutput(iterNum).sbcs.ffp);
            end
        end
    end
    
    
    methods % listeners, setters & getters
        
        function handleRecorrectChange(obj,~, ~)
            defineRecorrectobj(obj)
        end
        
        
        function defineRecorrectobj(obj)
            obj.recorrect = bmmo_RecorrectTsActuation(obj.tsActuationConfig);
        end
        
        
        function updateTimeFilterState(obj,iterNum)
            switch obj.timeFilter
                case 'DEFAULT'
                    % do nothing
                case 'DISABLED'
                    obj.rerunOutput(iterNum).bmmoInputsRecorrected.info.report_data.time_filtering_enabled = 0;
                case 'ENABLED'% TODO: support adaptive filter case, disabled for now.
                    obj.rerunOutput(iterNum).bmmoInputsRecorrected.info.report_data.time_filtering_enabled = 1;
                    obj.rerunOutput(iterNum).bmmoInputsRecorrected.info.report_data.adaptive_time_filter_enabled = 0;
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
        
        
        function val = get.zeroSbc(obj)
            switch obj.jobConfig.bl3_model
                case true
                    out = bmmo_default_output_structure(bl3_default_options_structure);
                case false
                    out  = bmmo_default_output_structure(bmmo_default_options_structure);
            end
            val = out.corr;
        end
    end
end %classdef

function mustBeValidFilter(timeFilter)
mustBeMember(timeFilter, bmmo_RerunTsActuation.validTimeFilter)
end % mustBeValidFilter
