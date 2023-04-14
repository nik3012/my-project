function mlo = bmmo_kt_preprocess_input( mli, adeller, adelwhc, adelsbc, filter_enabled, widmapping)
% function mlo = bmmo_kt_preprocess_input( mli, adeller, adelwhc, adelsbc, filter_enabled, widmapping )
%
% Given a standard ml input structure mli and the paths of three ADEL files
% (ADELler, ADELwaferHeatingCorrectionsReport and ADELsbcOverlayDriftControlNxerep,
% return an ml structure that is valid input for the BMMO-NXE drift control
% model
%
% Input
%   mli: standard input structure with wd, layer, raw and tlgname fields
%   adeller: full path of ADELler xml file
%   adelwhc: full path of ADELwaferHeatingCorrectionsReport xml file
%
%
% Optional Input
%   adelsbc: full path of ADELsbcOverlayDriftControlNxerep xml file
%   filter_enabled: 1 if time filtering enabled; 0 otherwise
%   widmapping: [1xn double array) subset of wafers to map (default:
%       1:nwafer)
%
% Output
%   mlo: ml structure validated for input to BMMO-NXE drift control model

% fill in redundant info.M fields
if ~isfield(mli, 'tlgname')
    mli.tlgname = '';
end

if nargin < 5
    filter_enabled = 0;
end

if nargin < 6
    widmapping = 1:mli.nwafer;
end

mli.info.M.nwafer = mli.nwafer;
mli.info.M.nfield = mli.nfield;

ml_1 = bmmo_kt_process_adeller_input(mli, adeller);

ml_2 = bmmo_kt_process_adelwhc_input(ml_1, adelwhc, widmapping);

ml_2 = sub_get_wafer_info(ml_2, widmapping);

if nargin > 4
    % get previous correction
    [ml_2.info.previous_correction, inline_sdm] = bmmo_kt_process_SBC2rep(adelsbc);
    
    % get SDM residual
    ml_2.info.report_data.inline_sdm_residual = inline_sdm.sdm_res;
    if isfield(inline_sdm, 'sdm_model')
        ml_2.info.report_data.inline_sdm_model = inline_sdm.sdm_model;
    end
    
    % get time filter factor
    ml_2.info.report_data.inline_sdm_time_filter = inline_sdm.time_filter;
    
    
    % get SDM CET NCE
    if isfield(inline_sdm, 'sdm_cet_res')
        ml_2.info.report_data.inline_sdm_cet_residual = inline_sdm.sdm_cet_res;
    end
else
    % fill in a zero previous correction
    disp('No SBC report provided: filling in zero previous correction');
    options = bmmo_default_options_structure;
    pc = bmmo_default_output_structure(options);
    ml_2.info.previous_correction = pc.corr;

    ml_2.info.report_data.inline_sdm_residual = pc.corr.ffp; 
end
  
mlo = ml_2;
if nargin < 5
    filter_enabled = 0;
end

mlo.info.report_data.time_filtering_enabled = filter_enabled;

bmmo_validate_input(mlo);



function mlo = sub_get_wafer_info(mli, wafer_list)

mlo = mli;
mlo.info.report_data.FIWA_translation.x = mlo.info.report_data.FIWA_translation.x(wafer_list);
mlo.info.report_data.FIWA_translation.y = mlo.info.report_data.FIWA_translation.y(wafer_list);
mlo = sub_fix_chuck_info(mlo, wafer_list);


function mlo = sub_fix_chuck_info(mli, wafer_list)
    mlo = mli;
    
    mlo.info.F.chuck_id = mlo.info.F.chuck_id(wafer_list);
    mlo.info.F.wafer_accepted = mlo.info.F.wafer_accepted(wafer_list);

    % now count the number of chucks used
    chucks_used = length(unique(mlo.info.F.chuck_id));
    if chucks_used < 2
        mlo.info.F.chuck_operation = 'ONE_CHUCK';
    end
