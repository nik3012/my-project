function [sbc2, inline_sdm] = bmmo_kt_process_SBC2rep(filename)
% function [sbc2, inline_sdm] = bmmo_kt_process_SBC2rep(filename)
% <help_update_needed>

% function [sbc2, inline_sdm] = bmmo_kt_process_SBC2rep(filename)
%
% Read an ADELsbcDriftControlNxeRep.xml (Protected/Unprotected) file and 
% format the sbc output like the output of bmmo_nxe_drift_control_model.
%
% Input:
% - filename: name of the .xml file containing the sbc report
%
% Output:
% - sbc2: formatted correction set
% - inline_sdm: Inline SDM output with following fields:
%     sdm_res: Inline SDM residuals
%     sdm_cet_res: Intrafield system CET residual (only if present)
%     sdm_model: SDM model type: Baseliner 3/ BMMO NXE 
%     sdm_kpi: Inline SDM KPIs

MAX_CHUCK_NR = 2;

if ischar(filename)
    xml = bmmo_load_ADEL(filename);
else
    xml = filename;
end

sbc2 = [];
tmp = bmmo_default_output_structure(bmmo_default_options_structure);
sdm_res = tmp.corr;
sdm_cet_res = tmp.corr;

for ic = 1:MAX_CHUCK_NR
    mask = arrayfun(@(x) endsWith(x.elt.MatchedInfoList.elt.CorrSetList.elt.CorrSetName, num2str(ic)), xml.AppliedCorrectionList);
    ind(ic) = find(mask, 1);
    waferstagechuckid = xml.AppliedCorrectionList(ind(ic)).elt.MatchedInfoList.elt.CorrSetList.elt.CorrSetName;
    chuck_id = str2double(waferstagechuckid(end));
    
    this_set = xml.AppliedCorrectionList(ind(ic)).elt.Corrections;
    
    sbc2 = bmmo_kt_process_sbc_correction(sbc2, this_set, chuck_id);
    
    this_set.SdmDistortionMap = xml.AppliedCorrectionResults.SdmDistortionResiduals(ind(ic)).elt;
    
    sdm_res = bmmo_kt_process_sbc_correction(sdm_res, this_set, chuck_id);
    inline_sdm.sdm_res = sdm_res.ffp;
    
    if isfield(xml.AppliedCorrectionResults, 'SdmIntrafieldSystemCetResidual')
        this_set.SdmDistortionMap = xml.AppliedCorrectionResults.SdmIntrafieldSystemCetResidual(ind(ic)).elt;
        sdm_cet_res = bmmo_kt_process_sbc_correction(sdm_cet_res, this_set, chuck_id);
        inline_sdm.sdm_cet_res = sdm_cet_res.ffp;
        
        if isfield(xml.AppliedCorrectionResults.SdmIntrafieldSystemCetResidual(1).elt.Header, 'AppliedFilter')
            inline_sdm.sdm_filter  = xml.AppliedCorrectionResults.SdmIntrafieldSystemCetResidual(1).elt.Header.AppliedFilter;
        end
    end
end
xml_corr_IFO = xml.AppliedCorrectionList;
corr_names = arrayfun(@(x) x.elt.MatchedInfoList.elt.CorrSetList.elt.CorrSetName, xml_corr_IFO, 'UniformOutput', false);
[~, idx_unique] = unique(string(corr_names), 'stable');
corr_names = corr_names(idx_unique);
IFO_id = idx_unique > max(ind);
[~, I] = sort(corr_names(IFO_id));
xml_corr_IFO = xml_corr_IFO(IFO_id);
xml_corr_IFO = xml_corr_IFO(I);
xml_corr_IFO = arrayfun(@(x) x.elt.Corrections.IntraFieldOffset, xml_corr_IFO);
sbc2 = bmmo_parse_sbc_IFO(sbc2, xml_corr_IFO);
sbc2 = bmmo_add_missing_corr(sbc2);

if ~all(sbc2.IR2EUV == sbc2.IR2EUV(1))
    warning('Different IR/EUV ratios found for different correction sets. Using the first value found.');
end
sbc2.IR2EUV = sbc2.IR2EUV(1);

if isfield(xml.AppliedCorrectionList(1).elt.Corrections.SdmDistortionMap.Header, 'SdmModel')
    inline_sdm.sdm_model  = xml.AppliedCorrectionList(1).elt.Corrections.SdmDistortionMap.Header.SdmModel;
end

if isfield(xml.AppliedCorrectionList(1).elt.Corrections.SdmDistortionMap.Header,'TimeFilter')
    inline_sdm.time_filter = str2double(xml.AppliedCorrectionList(1).elt.Corrections.SdmDistortionMap.Header.TimeFilter);
else
    inline_sdm.time_filter = 1;
end

kpi_struct = bmmo_parse_kpi_ADELsbcrep_inlineSDM(xml);
inline_sdm.sdm_kpi =  kpi_struct.applied.InlineSDM;
