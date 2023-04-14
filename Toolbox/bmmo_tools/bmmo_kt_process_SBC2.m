function [sbc2, inline_sdm] = bmmo_kt_process_SBC2(filename)
% function [sbc2, inline_sdm] = bmmo_kt_process_SBC2(filename)
% <help_update_needed>


%% Description:
% Read an SBC2 NXE subrecipe and format it like the output of
% bmmo_nxe_drift_control_model.
%
% Syntax: [sbc2, header] = bmmo_kt_process_SBC2(filename)
%
% Input:
% - filename: name of the .xml file containing the subrecipe
%
% Output:
% - sbc2: formatted correction set
% - inline_sdm: structure containing fields: time_filter
%               and sdm_model (both the fields are optional)

%% History
% 20151008  OTIE	Creation
% 20151009  OTIE	Minor fix relating to grid formatting
% 20151012  OTIE    Fixed KA 2DC: zeros (since only expose grid is present
%                   in SBC2 NXE subrecipe)
% 20151026  OTIE    Fixed scales (now according to xml schema definition)
%                   and set KA values outside wafer radius to NaN
% 20160412  SBPR    Minimal rework of ovl_bmmo_nxe_read_SBC2 for BMMO-NXE KT integration testing
% 20160426  SBPR    Bugfixes: KA map, INTRAF
% 20160503  SBPR    Read Chuck ID explicitly
% 20190801  SELR    Updated for IFO in SBC2

%% Main function
if ischar(filename)
    xml = xml_load(filename);
else
    xml = filename;
end

sub_check_xml(xml);
% parse:
sbc2 = [];
inline_sdm = [];

MAX_CHUCK_NR = 2;

for ic = 1:MAX_CHUCK_NR
    mask = arrayfun(@(x) endsWith(x.elt.CorrectionSetName, num2str(ic)), xml.CorrectionSets);
    ind(ic) = find(mask, 1);
    waferstagechuckid = xml.CorrectionSets(ind(ic)).elt.ApplicationRange.Exposure.Wafer.WaferStageChuckId;
    chuck_id = str2double(waferstagechuckid(end));
    this_set = xml.CorrectionSets(ind(ic)).elt.Parameters;
    
    %% convert to dd format to use common parsing functions
    %         xmlscaling.nm = 1e-9;
    %         xmlscaling.urad = 1e-6;
    %         xmlscaling.um = 1e-6;
    %         xmlscaling.mm = 1e-3;
    %         xmlscaling.mag = 0;
    
    % this_set = bmmo_convert_xml_correction_to_dd(this_set);
    % sbc2 = bmmo_kt_process_sbc_correction_new(sbc2, this_set, chuck_id, xmlscaling);
    
    sbc2 = bmmo_kt_process_sbc_correction(sbc2, this_set, chuck_id);
    inline_sdm = sub_get_inline_sdm_info(inline_sdm, this_set, chuck_id);
end

if ~isempty(inline_sdm)
    inline_sdm = sub_verify_inline_sdm_fields(inline_sdm);
end

xml_corr_IFO = xml.CorrectionSets;
xml_corr_IFO(ind) = [];
corr_IFO_names = arrayfun(@(x) x.elt.CorrectionSetName, xml_corr_IFO, 'UniformOutput', false);
[~, I] = sort(corr_IFO_names);
xml_corr_IFO = xml_corr_IFO(I);
xml_corr_IFO = arrayfun(@(x) x.elt.Parameters.IntraFieldOffset, xml_corr_IFO);
sbc2 = bmmo_parse_sbc_IFO(sbc2, xml_corr_IFO);
sbc2 = bmmo_add_missing_corr(sbc2);
% check IR/EUV ratio identicality for all sets:
if ~all(sbc2.IR2EUV == sbc2.IR2EUV(1))
    warning('Different IR/EUV ratios found for different correction sets. Using the first value found.');
end
sbc2.IR2EUV = sbc2.IR2EUV(1);



function inline_sdm =  sub_get_inline_sdm_info(inline_sdm, this_set, chuck_id)
if isfield(this_set.SdmDistortionMap.Header,'TimeFilter')
inline_sdm(chuck_id).time_filter = str2double(this_set.SdmDistortionMap.Header.TimeFilter);
end
if isfield(this_set.SdmDistortionMap.Header,'SdmModel')
inline_sdm(chuck_id).sdm_model = this_set.SdmDistortionMap.Header.SdmModel;
end

function inline_sdm = sub_verify_inline_sdm_fields(inline_sdm)

fdnames = fieldnames(inline_sdm);
for i = 1: length(fdnames)
    if ~isequal(inline_sdm.(fdnames{i}), inline_sdm(1).(fdnames{i}))
        warning(['Different ',fdnames{i}, ' value found in SdmDistortionMaps. Using the first value found.']);
    end
end
inline_sdm = inline_sdm(1);


%% sub_check_xml
function sub_check_xml(xml)
if ~isfield(xml, 'Header')
    warning('No header present in SBC2 file.');
end

if ~isfield(xml, 'CorrectionSets')
    error('No correction sets present in SBC2 file. Exiting');
end
if isempty(xml.CorrectionSets)
    error('No correction sets present in SBC2 file. Exiting');
elseif length(xml.CorrectionSets) ~= 2 && length(xml.CorrectionSets) ~= 6
    warning('SBC file not according to spec, 2 corrections (SBC2) or 6 corrections (SBC2a) are expected');
    
end
