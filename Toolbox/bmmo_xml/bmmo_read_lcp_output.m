function [mlo, sbc_out, job_report, invalids, bar_struct, wdm_xml] = bmmo_read_lcp_output(dirname, wec_dirname, filter, bar_struct)
% function [mlo, sbc_out, job_report, invalids, bar_struct, wdm_xml] = bmmo_read_lcp_output(dirname, wec_dirname, filter, bar_struct)
%
% Reads a directory containing LCP/VCP job ADEL files and converts them into
% a valid bmmo-nxe drift control model input structure
%
% Input: dirname: directory containing ADEL files (can be downloaded as a .zip file from
% job report in LCP/VCP)
%
% Optional Input:
%   wec_dirname: dirname of wec files (if different)
%   filter: flag to set time filtering 
%       0: recover to baseline
%       1: control to baseline
%       2: use filter from LCP/VCP Job report (default)
%   bar_struct: progress bar structure with following fields
%       h: handle to progress bar
%       total: total progress
%       curr: current progress
%       update: handle to update function
%
% Output: mlo: valid input structure for bmmo_nxe_drift_control_model
%         sbc_out: BMMO-NXE sbc2 structure from SBC output
%         job_report: Parsed LCP/VCP job report structure
%         invalids: Parsed Invalidated Data structure
%         bar_struct: updated progress bar structure or []
%         wdm_xml: xml loaded ADELwaferdatamap (optional)
%
% Note on the job_report:
% use the bmmo_parse_kpi* functions to get the kpi values. This will:
% * convert the text to numerical values
% * for OTAS data: field names like 'Max99.7' converted to something that 
%   Matlab can handle properly. That is, the 99.7 part is translated to a 
%   name with _997 in it.
% See e.g. bmmo_parse_kpi_res.m how this is done.


if nargin < 2
    disp(['Using wec_dirname as "' dirname '"']);
    wec_dirname = dirname;
end
% if not provided use filter from Job report
if nargin < 3  
    use_report_filter = 1; 
else
   if filter < 2
        disp(['Overriding LCP Job Report: setting time filtering to ' num2str(filter)]);
        use_report_filter = 0;
   else
       use_report_filter  = 1;
   end
end

% empty if not provided
if nargin < 4
    bar_struct = [];
end

% Find the ADEL files in the directory
bar_struct = bmmo_log_progress('Finding ADELs', bar_struct);
adels      = bmmo_find_adels(dirname);

% Parse the LCP job report
try
    [job_report, sbc_out, filter, mapped_wids, exposure_wids, settings] = bmmo_parse_job_report(adels.adellcp,use_report_filter, bar_struct);
    % for output arguments other than BMMO MATLAB input
    if nargout > 1
        % Parse the output sbc correction
        bar_struct = bmmo_log_progress('Parsing ADELsbcOverlayDriftControlNxe', bar_struct);
        sbc_out    = bmmo_kt_process_SBC2([dirname filesep sbc_out]);

        % parse invalidated data
        if ~isempty(adels.adelinv)
            bar_struct = bmmo_log_progress('Parsing ADELsubstrateInvalidatedDataReport', bar_struct);
            invalids   = xml_load(adels.adelinv);
        else
            invalids = [];
        end
    end
    % Optional output: ADELwaferdatamap xml loaded
    if nargout > 5
         bar_struct = bmmo_log_progress('Parsing ADELwaferdatamap', bar_struct);
         wdm_xml = xml_load(adels.adelwdm);
    end
catch
    warning('Erorr in parsing, all output arguments except BMMO input will be empty')
    % default sbc output structure with zeroes
    tmp      = bmmo_default_output_structure(bmmo_default_options_structure);
    sbc_out  = tmp.corr;
    
    % emty other outputs
    invalids                    = [];
    job_report                  = [];
    mapped_wids                 = [];
    exposure_wids               = [];
    settings.configuration_data = [];
    wdm_xml                     = [];
end

% Parse ADEL files to produce BMMO MATLAB input
[mlo, bar_struct] = bmmo_input_from_adels(adels.adelmet, adels.adeller, adels.adelsbcrep,  adels.adelwhc,...
                    adels.adelrec, wec_dirname, filter, bar_struct, mapped_wids, exposure_wids, adels.adelmcl);     
                
% Parse ADELexposureTrajectoriesReport & ADELwaferGridResidualReport                
 if ~isempty(adels.adelexp)
    [ml_cet_residual, adelexp_wids] = bmmo_read_adelexposetrajectories(adels.adelexp);
    
    if ~isempty(exposure_wids)
        nwids = find(contains(adelexp_wids, exposure_wids) == 1);
    else
        nwids = 1:ml_cet_residual.nwafer;
    end
    
    % get same wafers as readout for ADELexp outputs
    mlo.info.report_data.cet_residual = ovl_get_wafers(ml_cet_residual, nwids);
    
    % Get 1L CET NCE if readout is 1L
    options = bmmo_default_options_structure;
    field_ids = [options.layer_fields{1} options.edge_fields];
    N_F_L1  = numel(field_ids);
    N_SMF_L2 = 7672; 
    if mlo.nfield < N_SMF_L2  && mlo.info.report_data.cet_residual.nfield > N_F_L1 
        mlo.info.report_data.cet_residual =  ovl_get_fields(mlo.info.report_data.cet_residual, field_ids);
    end
    
    % ADELwaferGridResidualReport parsing
    if ~isempty(adels.adelwfrgridNCE)
        [ml_KA_cet_corr, ml_KA_cet_nce, ~, settings.configuration_data.KA_actuation]  = bmmo_read_adelwafergridresidual(adels.adelwfrgridNCE, ml_cet_residual);
        % get same wafers as readout for ADELwfrgrid outputs
        mlo.info.report_data.KA_cet_corr   = ovl_get_wafers(ml_KA_cet_corr, nwids);
        mlo.info.report_data.KA_cet_nce    = ovl_get_wafers(ml_KA_cet_nce, nwids);
       
    % Get 1L KA correction & NCE if readout is 1L 
        if mlo.nfield < N_SMF_L2 && mlo.info.report_data.KA_cet_corr.nfield > N_F_L1 
            mlo.info.report_data.KA_cet_corr =  ovl_get_fields(mlo.info.report_data.KA_cet_corr, field_ids);
            mlo.info.report_data.KA_cet_nce  =  ovl_get_fields(mlo.info.report_data.KA_cet_nce, field_ids);
        end
        
    end
 end              

% Copy configuration options from settings to mlo
bar_struct = bmmo_log_progress('Copying configuration options (SUSD/KA/Timefilter) to input', bar_struct);
mlo.info.configuration_data = settings.configuration_data;
% in case of Adapative filter
if isfield(settings, 'report_data')
    mlo.info.report_data.adaptive_time_filter_enabled = settings.report_data.adaptive_time_filter_enabled;
    mlo.info.report_data.T_previous_expose            = settings.report_data.T_previous_expose;
    mlo.info.report_data.T_current_expose             = settings.report_data.T_current_expose;
end
