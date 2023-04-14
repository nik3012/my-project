function [report, sbcout, filter, mapped_wids, exposure_wids, settings] = bmmo_parse_job_report(lpcjobreport, use_report_filter, bar_struct)
% function [report, sbcout] = bmmo_parse_job_report(lpcjobreport)
%
% Parse an ADELlpcJobReportBaseLinerMmoNxe to retrieve
%   1) a structure containing a list of ADEL filenames
%   2) the report structure returned by xml_load
%
% Input: lpcjobreport: full path of ADELlpcJobReportBaseLinerMmoNxe file
%
% Output: report: Structure returned by xml_load
%         sbcout: filename of sbc output structure
%         filter: Time filter enabled or not
%         mapped_wids: Substrate Wafer Ids
%         exposure_wids: Exposure Context Wafer Ids
%         settings: Job settings for SUSD, KA, and adjustable & adaptive time filter
%
%
% 20170131 SBPR Creation
% 20200918 ANBZ Updated as wrapper for Job report Configurations for LCP/VCP
% 20201118 LUDU Added job setting for bl3

% Case: LIS JOB REPORT
if contains(lpcjobreport, 'ADELbmmoOverlayJobReport')
    bar_struct = bmmo_log_progress('Parsing ADELbmmoOverlayJobReport', bar_struct);
    
    % xml load job report and find the correct sbc recipe used
    [report, sbcout] = sub_parse_job_report(lpcjobreport);
    
    % Determine if the job is Control = 1 or Recover = 0
    if use_report_filter
        filter =   sub_get_filter_state(report.Input.ControlMode);
    end
    
    % Subtrate Wafer Ids from Job report
    for i=1:length(report.Results.WaferContextList)
        mapped_wids{i} = report.Results.WaferContextList(i).WaferContext.WaferErrorCorrection.SubstrateWaferId;
    end
    
    % Exposure Context Wafer Ids from Job report
    for i=1:length(report.Results.WaferContextList)
        exposure_wids{i} = report.Results.WaferContextList(i).WaferContext.ExposureContext.WaferId;
    end
    
    % Check for configuration options
    settings.configuration_data = []; % Initialize
    settings.configuration_data.platform = 'LIS';
    % SUSD control
    if isfield(report.Input, 'ControlLoopSettings')
        % Determine if  SUSD or  KA control is enabled
        settings = sub_SUSD_KA_settings(report.Input.ControlLoopSettings, settings);
        
        % Determine if BL3 is enabled
        if isfield(report.Input.ControlLoopSettings, 'Modeling')
            if strcmp(report.Input.ControlLoopSettings.Modeling, 'BaseLiner 3')
                settings.configuration_data.bl3_model = 1;
            end
        end
        
        % Get adjustable time filter values
        if isfield(report.Input.ControlLoopSettings, 'AdjustableTimeFilter')
            if isfield(report.Input.ControlLoopSettings.AdjustableTimeFilter, 'WeightFactors')
                settings = sub_adjust_time_filter(report.Input.ControlLoopSettings.AdjustableTimeFilter.WeightFactors, settings);
            end
        end
    end
    
    % Previous and current exposure time for Adaptive time filter (if ON)
    settings = sub_adapt_time_filter(report.Results, settings);

    % Add intrafield actuation to configuration
    if isfield(report.Results.StatisticsPerClassList(1).StatisticsPerClass.CorrectionMagnitude.TotalFilteredMonitoring.KFactors,'K51')
        settings.configuration_data.intraf_actuation = 5;
    else
        settings.configuration_data.intraf_actuation = 3;
    end   
    % Case:OTAS JOB REPORT
elseif contains(lpcjobreport, 'ADELlpcJobReportBaseLinerMmoNxe')
    bar_struct =  bmmo_log_progress('Parsing ADELlpcJobReportBaseLinerMmoNxe', bar_struct);

    % xml load job report and find the correct sbc recipe used
    [report, sbcout] = sub_parse_job_report(lpcjobreport);
    
    % Determine if the job is Control = 1 or Recover = 0
    if use_report_filter
        filter = sub_get_filter_state(report.Input.JobType);
    end
    
    % Subtrate Wafer Ids from Job report
    widinfo     = [report.Results.WaferInformationList.WaferInformation];
    mapped_wids = {widinfo.SubstrateWaferId};
    
    % Exposure Context Wafer Ids from Job report
    for i=1:length(report.Input.WaferMapping)
        exposure_wids{i} = report.Input.WaferMapping(i).elt.ExposureContext.WaferId;
    end
    
    % Check for configuration options
    settings.configuration_data = []; % Initialize
    settings.configuration_data.platform = 'OTAS';
    % Determine if  SUSD or  KA control is enabled
    settings = sub_SUSD_KA_settings(report.Input.JobSettings.BaseLinerMmo.Overlay, settings);
    
    
    % Adjustable time filter
    if isfield(report.Input.JobSettings.BaseLinerMmo.Overlay, 'AdjustableTimeFilter')
        if sub_str2bool(report.Input.JobSettings.BaseLinerMmo.Overlay.AdjustableTimeFilter.EnableAdjustableTimeFilter)
            settings = sub_adjust_time_filter(report.Input.JobSettings.BaseLinerMmo.Overlay.AdjustableTimeFilter.WeightFactors, settings);
        end
    end
    
    % Previous and current exposure time for Adaptive time filter (if ON)
    settings = sub_adapt_time_filter(report.Results, settings);
    
    % Add intrafield actuation to configuration
    if isfield(report.Results.KpiList.BaseLinerMmo.Overlay.CorrectionMagnitude.Monitoring.KFactors,'K51')
        settings.configuration_data.intraf_actuation = 5;
    else
        settings.configuration_data.intraf_actuation = 3;
    end
end


% SUB FUNCTIONS
% sub function to parse job report and load correct SBC recipe
function [report, sbcout] = sub_parse_job_report(lpcjobreport)
report = xml_load(lpcjobreport);
% Find the sbc output
doclist = [report.Results.DocumentList.Document];
sbcout = 'error';
for ii = 1:length(doclist)
    if strcmp(doclist(ii).Type, 'ADELsbcOverlayDriftControlNxe')
        sbcout = [doclist(ii).Type '_' doclist(ii).Name '.xml'];
    end
end
if strcmp(sbcout, 'error')
    error('SBC output file not found in LCP job report');
end


% sub function to determine Recover or Control Job
function filter = sub_get_filter_state(Mode)
switch Mode
    case 'Recover to baseline'
        filter = 0;
    case 'Control to baseline'
        filter = 1;
    otherwise
        error('Unknown job type ''%s'' in LCP job report', report.Input.JobType);
end


% sub function to determine if SUSD or KA control is enabld
function settings = sub_SUSD_KA_settings(report_input, settings)
%SUSD control
if isfield(report_input, 'IncludeCorrectionsPerScanDirection')
    settings.configuration_data.susd_correction_enabled = sub_str2bool(report_input.IncludeCorrectionsPerScanDirection);
end
% KA control
if isfield(report_input, 'IncludeKaControl')
    settings.configuration_data.KA_correction_enabled = sub_str2bool(report_input.IncludeKaControl);
end


% sub function to get the values provided for time filter
function settings = sub_adjust_time_filter(filter_weights, settings)
ml_fieldnames   = {'coeff_MI', 'coeff_KA', 'coeff_WH', 'coeff_BAO', 'coeff_ffp', 'coeff_SUSD'};
adel_fieldnames = {'Mirror', 'Ka', 'WaferHeating', 'Bao', 'Intrafield', 'SuSd'};
for ii = 1:length(ml_fieldnames)
    if isfield(filter_weights, adel_fieldnames{ii})
        
        settings.configuration_data.filter.(ml_fieldnames{ii}) = str2double(filter_weights.(adel_fieldnames{ii}));
    end
end


% sub function to get the previous and curent exposure time when Adaptive
% time filter is enabled
function settings = sub_adapt_time_filter(report_results, settings)
if isfield(report_results, 'TimeFilter')
    if isfield(report_results.TimeFilter, 'PreviousJobExposureTime')
        settings.report_data.adaptive_time_filter_enabled = 1;
        settings.report_data.T_previous_expose = sub_calculate_time_in_days(report_results.TimeFilter.PreviousJobExposureTime);
        settings.report_data.T_current_expose  = sub_calculate_time_in_days(report_results.TimeFilter.CurrentJobExposureTime);
    end
end


% sub function to calculate no. of days from date
function T_days = sub_calculate_time_in_days(date)

epoch = datetime(1970,1,1);
date = datetime(date(1:19), 'InputFormat', 'uuuu-MM-dd''T''HH:mm:ss');
T_days = days(date - epoch);



% sub function for string to boolean conversion
function bool = sub_str2bool(str)
if ischar(str)
    if strcmpi(str,'True') || strcmpi(str,'true')
        bool=1;
    elseif strcmpi(str,'False')|| strcmpi(str,'false')
        bool=0;
    end
else
    bool=str;
end

