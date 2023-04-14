function bmmo_create_ADEL_SBCrep(infile, outfile, sbc, SDM_res, SDM_kpi)
% function bmmo_create_ADEL_SBCrep(infile, outfile, sbc, SDM_res, SDM_kpi)
%
% Build a new ADEL SBC2 report on the template of an existing one
% replacing the applied correction data with the data from
% a Matlab sbc2 correction. Optionally, the applied correction results can
% also be replaced with the KPIs and residuals from inline SDM model
%  [~, ~, ~, SDM_kpi, resid] = BMMO_model_inlineSDM(ovl_get_wafers(flds, 1), ovl_get_wafers(flds, 2), 'LFP', 0);


% Input
%   infile: full path of ADEL SBC2 report from Twinscan
%   outfile: path of output file.
%   sbc: Matlab sbc correction (output by bmmo_nxe_drift_control_model)
%   SDM_kpi :  KPIs of inline SDM (output by  BMMO_model_inlineSDM)
%   SDM_res:  Residuals of inline SDM (output by  BMMO_model_inlineSDM)

%machine id and doc id cannot be updated and z2 and z3 not *1e9

xml_data = xml_load(infile);

tmp_data = xml_data;

%Optional Update for KPIs and resid from SDM model
%If inlineSDM model outputs not provided then, the values in the output report becomes zero
if  ~exist('SDM_res','var')
    
    for jj = 1:length(sbc.ffp)
        SDM_res.TotalRes(jj).dx=sbc.ffp(jj).dx*0;
        SDM_res.TotalRes(jj).dy=sbc.ffp(jj).dy*0;
        
    end
end
if  ~exist('SDM_kpi','var')
    %     if  isempty(SDM_kpi)
    
    for jj = 1:length(sbc.ffp)
        SDM_kpi.maxTotalRes(jj).dx=0;
        SDM_kpi.maxTotalRes(jj).dy=0;
        SDM_kpi.maxTotalCorr(jj).dx=0;
        SDM_kpi.maxTotalCorr(jj).dy=0;
        SDM_kpi.FadingMSD(jj).x=0;
        SDM_kpi.FadingMSD(jj).y=0;
        SDM_kpi.maxHOCCorr(jj).dx=0;
        SDM_kpi.maxHOCCorr(jj).dy=0;
        SDM_kpi.maxHOCRes(jj).dx=0;
        SDM_kpi.maxHOCRes(jj).dy=0;
    end
    SDM_kpi.maxLensRes.dy=0;
    SDM_kpi.maxLensRes.dx=0;
    SDM_kpi.maxLensCorr.dx=0;
    SDM_kpi.maxLensCorr.dy=0;
    SDM_kpi.Z2_2=0;
    SDM_kpi.Z3_2=0;
    
    
end

mld = ovl_average_fields(ovl_create_dummy('13X19', 'nlayer', 1, 'nwafer', 2));
corr_out = sbc;
flds = bmmo_ffp_to_ml(sbc.ffp, mld);

I = knnsearch([mld.wd.xf mld.wd.yf], [corr_out.ffp(1).x corr_out.ffp(1).y]);
for jj = 1:2
    res(jj).dx = SDM_res.TotalRes(jj).dx(I);
    res(jj).dy = SDM_res.TotalRes(jj).dy(I);
    res(jj).x = corr_out.ffp(jj).x;
    res(jj).y = corr_out.ffp(jj).y;
end

for ic = 1:2
    chuck_id = 0;
    for tc = 1:2
        cid = str2double(xml_data.AppliedCorrectionResults.SdmDistortionResiduals(tc).elt.Header.ChuckId(end));
        if cid == ic
            chuck_id = tc;
        end
    end
    tmp_data.AppliedCorrectionResults.SdmDistortionResiduals(chuck_id).elt = ...
        sub_update_sdm_res(tmp_data.AppliedCorrectionResults.SdmDistortionResiduals(chuck_id).elt, res(ic));
    
    
end
% SDM Kpi HOC update
for ic = 1:2
    chuck_id = 0;
    for tc = 1:2
        cid = str2double(xml_data.AppliedCorrectionResults.KpiHocList(tc).elt.ChuckId(end));
        if cid == ic
            chuck_id = tc;
        end
    end
    tmp_data.AppliedCorrectionResults.KpiHocList(chuck_id).elt.KpiMaxCorrHoc.X = ...
        sprintf('%.3f', (SDM_kpi.maxHOCCorr(ic).dx * 1e9));
    tmp_data.AppliedCorrectionResults.KpiHocList(chuck_id).elt.KpiMaxCorrHoc.Y = ...
        sprintf('%.3f', (SDM_kpi.maxHOCCorr(ic).dy * 1e9));
    
    tmp_data.AppliedCorrectionResults.KpiHocList(chuck_id).elt.KpiMaxResHoc.X = ...
        sprintf('%.3f', (SDM_kpi.maxHOCRes(ic).dx * 1e9));
    tmp_data.AppliedCorrectionResults.KpiHocList(chuck_id).elt.KpiMaxResHoc.Y = ...
        sprintf('%.3f', (SDM_kpi.maxHOCRes(ic).dy * 1e9));
    
    tmp_data.AppliedCorrectionResults.KpiHocList(chuck_id).elt.KpiMaxCorrTotal.X = ...
        sprintf('%.3f', (SDM_kpi.maxTotalCorr(ic).dx * 1e9));
    tmp_data.AppliedCorrectionResults.KpiHocList(chuck_id).elt.KpiMaxCorrTotal.Y = ...
        sprintf('%.3f', (SDM_kpi.maxTotalCorr(ic).dy * 1e9));
    
    tmp_data.AppliedCorrectionResults.KpiHocList(chuck_id).elt.KpiMaxResTotal.X = ...
        sprintf('%.3f', (SDM_kpi.maxTotalRes(ic).dx * 1e9));
    tmp_data.AppliedCorrectionResults.KpiHocList(chuck_id).elt.KpiMaxResTotal.Y = ...
        sprintf('%.3f', (SDM_kpi.maxTotalRes(ic).dy * 1e9));
    
    tmp_data.AppliedCorrectionResults.KpiHocList(chuck_id).elt.KpiFading.MsdX = ...
        sprintf('%.3f', (SDM_kpi.FadingMSD(ic).x * 1e9));
    tmp_data.AppliedCorrectionResults.KpiHocList(chuck_id).elt.KpiFading.MsdY = ...
        sprintf('%.3f', (SDM_kpi.FadingMSD(ic).y * 1e9));
    
    
end


%SDM KPI POB/Lens Update
tmp_data.AppliedCorrectionResults.KpiPob.KpiMaxCorrPob.X= sprintf('%.3f', (SDM_kpi.maxLensCorr.dx * 1e9));
tmp_data.AppliedCorrectionResults.KpiPob.KpiMaxCorrPob.Y= sprintf('%.3f', (SDM_kpi.maxLensCorr.dy * 1e9));
tmp_data.AppliedCorrectionResults.KpiPob.KpiMaxResPob.X=sprintf('%.3f', (SDM_kpi.maxLensRes.dx * 1e9));
tmp_data.AppliedCorrectionResults.KpiPob.KpiMaxResPob.Y=sprintf('%.3f', (SDM_kpi.maxLensRes.dy * 1e9));
tmp_data.AppliedCorrectionResults.KpiPob.KpiZ2_2 =sprintf('%.3f', (SDM_kpi.Z2_2));
tmp_data.AppliedCorrectionResults.KpiPob.KpiZ3_2= sprintf('%.3f', (SDM_kpi.Z3_2 ));


for ic = 1:2
    chuck_id = 0;
    for tc = 1:2
        cid = str2double(xml_data.AppliedCorrectionList(tc).elt.MatchedInfoList.elt.CorrSetList.elt.CorrSetName(end));
        if cid == ic
            chuck_id = tc;
        end
    end
    
    % Verify
    % data.CorrectionSets(c).elt.ApplicationRange.Exposure.Wafer.WaferStageChuckId
    % is the same as the chuck id
    % xml_rep.AppliedCorrectionList(2).elt.MatchedInfoList.elt.CorrSetList
    tmp_data.AppliedCorrectionList(chuck_id).elt.Corrections.MiMirrorOffsetMapExpose = ...
        sub_update_mi(tmp_data.AppliedCorrectionList(chuck_id).elt.Corrections.MiMirrorOffsetMapExpose, sbc.MI.wse(ic));
    
    tmp_data.AppliedCorrectionList(chuck_id).elt.Corrections.MiMirrorOffsetMapMeasure = ...
        sub_update_mi(tmp_data.AppliedCorrectionList(chuck_id).elt.Corrections.MiMirrorOffsetMapMeasure, sbc.MI.wsm(ic));
    
    tmp_data.AppliedCorrectionList(chuck_id).elt.Corrections.BlueAlignmentOffset = ...
        sub_update_bao(tmp_data.AppliedCorrectionList(chuck_id).elt.Corrections.BlueAlignmentOffset, sbc.BAO(ic));
    
    tmp_data.AppliedCorrectionList(chuck_id).elt.Corrections.KaOffsetMapExpose = ...
        sub_update_ka(tmp_data.AppliedCorrectionList(chuck_id).elt.Corrections.KaOffsetMapExpose, sbc.KA.grid_2de(ic));
    
    tmp_data.AppliedCorrectionList(chuck_id).elt.Corrections.KaOffsetMapMeasure = ...
        sub_update_ka(tmp_data.AppliedCorrectionList(chuck_id).elt.Corrections.KaOffsetMapMeasure, sbc.KA.grid_2dc(ic));
    
    tmp_data.AppliedCorrectionList(chuck_id).elt.Corrections.SdmDistortionMap = ...
        sub_update_intraf(tmp_data.AppliedCorrectionList(chuck_id).elt.Corrections.SdmDistortionMap, sbc.ffp(ic));
    
    tmp_data.AppliedCorrectionList(chuck_id).elt.Corrections.WaferHeatingOffset.Ir2EuvRatioOffset = sprintf('%.4f', sbc.IR2EUV);
    
end

%sorting SUSD intrafield offsets for correction

if length(xml_data.AppliedCorrectionList)>2
    IFO_corr_set_ind = arrayfun(@(x) ~(endsWith(x.elt.MatchedInfoList.elt.CorrSetList.elt.CorrSetName, num2str(1)) | endsWith(x.elt.MatchedInfoList.elt.CorrSetList.elt.CorrSetName, num2str(2))), xml_data.AppliedCorrectionList);
    IFO_corr_set = xml_data.AppliedCorrectionList(IFO_corr_set_ind);
    IFO_corr_set_names = arrayfun(@(x) x.elt.MatchedInfoList.elt.CorrSetList.elt.CorrSetName, IFO_corr_set, 'UniformOutput', false);
    [~, IFO_corr_set_ind_sorted] = sort(IFO_corr_set_names);
    
    
    for icorr_IFO = 1:length(IFO_corr_set_ind_sorted)
        IFO_corr_set(IFO_corr_set_ind_sorted(icorr_IFO)).elt.Corrections.IntraFieldOffset = ...
            sub_update_susd(IFO_corr_set(IFO_corr_set_ind_sorted(icorr_IFO)).elt.Corrections.IntraFieldOffset,...
            sbc.SUSD(icorr_IFO));
    end
    
    tmp_data.AppliedCorrectionList(IFO_corr_set_ind) = IFO_corr_set;
end


machine='0000';
tmp_data.Header = sub_update_header(tmp_data.Header, machine);

recipe_version = xml_data.Header.DocumentTypeVersion;

str1=string('xmlns:ADELsbcOverlayDriftControlNxerep="http://www.asml.com/XMLSchema/MT/Generic/ADELsbcOverlayDriftControlNxerep/vx.x"');
str2=string('xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"');
str3=string('xsi:schemaLocation="http://www.asml.com/XMLSchema/MT/Generic/ADELsbcOverlayDriftControlNxerep/vx.x ADELsbcOverlayDriftControlNxerep.xsd"');
schema_info = compose(str1 + '\n' + str2 + '\n' + str3);
schema_info = strrep(schema_info, 'vx.x', recipe_version);
bmmo_xml_save(outfile, tmp_data, 'ADELsbcOverlayDriftControlNxerep:Report', schema_info);


function header_out = sub_update_header(header_in, machine_id)

header_out = header_in;

dateformat = 'YYYY-mm-DDTHH:MM:SS';
doctime = now;
header_out.CreateTime = datestr(doctime, dateformat);
% header_out.LastModifiedTime = datestr(doctime, dateformat);
% header_out.MachineID = num2str(machine_id);




%Document ID left same as the orginal report
% docid_dateformat = 'YYYYmmDD_HHMM';
% doc_timestr = datestr(doctime, docid_dateformat);
% header_out.DocumentId = ['ADELsbc2-' num2str(machine_id) '-' doc_timestr];



function mi_out = sub_update_mi(mi_in, sbc_mi)

mi_out = mi_in;

for ii = 1:length(mi_out.XTYMirrorMap.Offsets)
    dy_offset = sprintf('%.2f', (sbc_mi.y_mirr.dy(ii) * 1e9));
    mi_out.XTYMirrorMap.Offsets(ii).elt = dy_offset;
    dx_offset = sprintf('%.2f', (sbc_mi.x_mirr.dx(ii) * 1e9));
    mi_out.YTXMirrorMap.Offsets(ii).elt = dx_offset;
end

function bao_out = sub_update_bao(bao_in, sbc_bao)

bao_out = bao_in;

bao_out.IntraField.Translation.X     =  sprintf('%.3f', (sbc_bao.TranslationX * 1e9));
bao_out.IntraField.Translation.Y     =  sprintf('%.3f', (sbc_bao.TranslationY * 1e9));
bao_out.IntraField.Magnification     =  sprintf('%.3f', (sbc_bao.Magnification * 1e6));
bao_out.IntraField.Rotation          =  sprintf('%.4f', (sbc_bao.Rotation * 1e6));
bao_out.IntraField.AsymRotation      =  sprintf('%.4f', (sbc_bao.AsymRotation * 1e6));
bao_out.IntraField.AsymMagnification =  sprintf('%.3f', (sbc_bao.AsymMagnification * 1e6));
bao_out.InterField.Translation.X     =  sprintf('%.3f', 0.0);
bao_out.InterField.Translation.Y     =  sprintf('%.3f', 0.0);
bao_out.InterField.Rotation          =  sprintf('%.4f', (sbc_bao.InterfieldRotation * 1e6));
bao_out.InterField.NonOrthogonality  =  sprintf('%.4f', (sbc_bao.NonOrtho * 1e6));
bao_out.InterField.Expansion.X       =  sprintf('%.4f', (sbc_bao.ExpansionX * 1e6));
bao_out.InterField.Expansion.Y       =  sprintf('%.4f', (sbc_bao.ExpansionY * 1e6));


function ka_out = sub_update_ka(ka_in, sbc_ka)

ka_out = ka_in;

for ii = 1:length(ka_out.Offsets)
    if isnan(sbc_ka.dy(ii)) || isnan(sbc_ka.dx(ii))
        dy_offset = sprintf('%.2f', (0 * 1e9));
        ka_out.Offsets(ii).elt.Y = dy_offset;
        dx_offset = sprintf('%.2f', (0 * 1e9));
        ka_out.Offsets(ii).elt.X = dx_offset;
        ka_out.Offsets(ii).elt.valid = 'false';
    else
        dy_offset = sprintf('%.2f', (sbc_ka.dy(ii) * 1e9));
        ka_out.Offsets(ii).elt.Y = dy_offset;
        dx_offset = sprintf('%.2f', (sbc_ka.dx(ii) * 1e9));
        ka_out.Offsets(ii).elt.X = dx_offset;
        ka_out.Offsets(ii).elt.valid = 'true';
    end
end

function intraf_out = sub_update_intraf(intraf_in, sbc_intraf)

xu = unique(sbc_intraf.x);
yu = unique(sbc_intraf.y);

[xg, yg] = meshgrid(xu, yu);
xg = xg(:);
yg = yg(:);

I = knnsearch([xg yg], [sbc_intraf.x sbc_intraf.y]);

dxmap = sbc_intraf.dx(I);
dymap = sbc_intraf.dy(I);

intraf_out = intraf_in;

for ii = 1:length(intraf_out.Offsets)
    intraf_out.Offsets(ii).elt.X = sprintf('%.2f', (dxmap(ii) * 1e9));
    intraf_out.Offsets(ii).elt.Y = sprintf('%.2f', (dymap(ii) * 1e9));
end

function sdm_res_out = sub_update_sdm_res(sdm_res_in, res)

xu = unique(res.x);
yu = unique(res.y);

[xg, yg] = meshgrid(xu, yu);
xg = xg(:);
yg = yg(:);

I = knnsearch([xg yg], [res.x res.y]);

dxmap = res.dx(I);
dymap = res.dy(I);

sdm_res_out = sdm_res_in;

for ii = 1:length(sdm_res_out.Offsets)
    sdm_res_out.Offsets(ii).elt.X = sprintf('%.2f', (dxmap(ii) * 1e9));
    sdm_res_out.Offsets(ii).elt.Y = sprintf('%.2f', (dymap(ii) * 1e9));
end


function susd_out = sub_update_susd(susd_in, sbc_susd)

susd_out = susd_in;

susd_out.Translation.X     =  sprintf('%.3f', (sbc_susd.TranslationX * 1e9));
susd_out.Translation.Y     =  sprintf('%.3f', (sbc_susd.TranslationY * 1e9));
susd_out.Magnification     =  sprintf('%.3f', (sbc_susd.Magnification * 1e6));
susd_out.Rotation          =  sprintf('%.4f', (sbc_susd.Rotation * 1e6));
susd_out.AsymRotation      =  sprintf('%.4f', (sbc_susd.AsymRotation * 1e6));
susd_out.AsymMagnification =  sprintf('%.3f', (sbc_susd.AsymMagnification * 1e6));