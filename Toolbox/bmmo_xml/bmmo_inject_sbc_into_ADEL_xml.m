% function bmmo_inject_sbc_into_ADEL_xml(xml_data, sbc)
%
% Inject the data from a bmmo sbc correction into the xml_data read from an
% ADELsbcOverlayDriftControlNxe with xml_load
%
% Input: (both structs)   
%   xml_data: read from an ADELsbcOverlayDriftControlNxe with xml_load
%   sbc: out.corr output from BMMO-NXE model
%
% 20201017 SBPR refactored from bmmo_create_ADEL_SBC; replaced OTIE chuck 
function tmp_data = bmmo_inject_sbc_into_ADEL_xml(xml_data, sbc)

tmp_data = xml_data;

% Verify 
% data.CorrectionSets(c).elt.ApplicationRange.Exposure.Wafer.WaferStageChuckId
% is the same as the chuck id

sbc_chuck_order = arrayfun(@(x) str2double(x.elt.ApplicationRange.Exposure.Wafer.WaferStageChuckId(end)), xml_data.CorrectionSets);

for ic = 1:2
    chuck_id = sbc_chuck_order(ic);
    
    tmp_data.CorrectionSets(chuck_id).elt.Parameters.MiMirrorOffsetMapExpose = ...
        sub_update_mi(tmp_data.CorrectionSets(chuck_id).elt.Parameters.MiMirrorOffsetMapExpose, sbc.MI.wse(ic));
    
    tmp_data.CorrectionSets(chuck_id).elt.Parameters.MiMirrorOffsetMapMeasure = ...
        sub_update_mi(tmp_data.CorrectionSets(chuck_id).elt.Parameters.MiMirrorOffsetMapMeasure, sbc.MI.wsm(ic));
    
    tmp_data.CorrectionSets(chuck_id).elt.Parameters.KaOffsetMapExpose = ...
        sub_update_ka(tmp_data.CorrectionSets(chuck_id).elt.Parameters.KaOffsetMapExpose, sbc.KA.grid_2de(ic));
    
    tmp_data.CorrectionSets(chuck_id).elt.Parameters.BlueAlignmentOffset = ...
        sub_update_bao(tmp_data.CorrectionSets(chuck_id).elt.Parameters.BlueAlignmentOffset, sbc.BAO(ic));
    
    tmp_data.CorrectionSets(chuck_id).elt.Parameters.SdmDistortionMap = ...
        sub_update_intraf(tmp_data.CorrectionSets(chuck_id).elt.Parameters.SdmDistortionMap, sbc.ffp(ic));
    
    tmp_data.CorrectionSets(chuck_id).elt.Parameters.WaferHeatingOffset.Ir2EuvRatioOffset = sprintf('%.4f', sbc.IR2EUV);
    
    if ~isfield(sbc.KA, 'grid_2dc')
        if isfield(tmp_data.CorrectionSets(chuck_id).elt.Parameters, 'KAOffsetMapMeasure')
            tmp_data.CorrectionSets(chuck_id).elt.Parameters = rmfield(tmp_data.CorrectionSets(chuck_id).elt.Parameters, 'KAOffsetMapMeasure');
        end
    else
        if ~isfield(tmp_data.CorrectionSets(chuck_id).elt.Parameters, 'KaOffsetMapMeasure')
            error('Measure side offset present in SBC structure but not in XML data');
        else
            tmp_data.CorrectionSets(chuck_id).elt.Parameters.KaOffsetMapMeasure = ...
                sub_update_ka(tmp_data.CorrectionSets(chuck_id).elt.Parameters.KaOffsetMapMeasure, sbc.KA.grid_2dc(ic));
        end
    end
    
end    

recipe_version = xml_data.Header.DocumentTypeVersion;
IFO_in_recipe = ~(strcmp(recipe_version, 'v1.0') | strcmp(recipe_version, 'v1.1'));

if IFO_in_recipe
    IFO_corr_set_ind = arrayfun(@(x) ~(endsWith(x.elt.CorrectionSetName, num2str(1)) | endsWith(x.elt.CorrectionSetName, num2str(2))), xml_data.CorrectionSets);
    IFO_corr_set = xml_data.CorrectionSets(IFO_corr_set_ind);
    IFO_corr_set_names = arrayfun(@(x) x.elt.CorrectionSetName, IFO_corr_set, 'UniformOutput', false);
    [~, IFO_corr_set_ind_sorted] = sort(IFO_corr_set_names);
    
    
    for icorr_IFO = 1:length(IFO_corr_set_ind_sorted)
        IFO_corr_set(IFO_corr_set_ind_sorted(icorr_IFO)).elt.Parameters.IntraFieldOffset = ...
            sub_update_susd(IFO_corr_set(IFO_corr_set_ind_sorted(icorr_IFO)).elt.Parameters.IntraFieldOffset,...
            sbc.SUSD(icorr_IFO));
    end
    
    tmp_data.CorrectionSets(IFO_corr_set_ind) = IFO_corr_set;
end



function mi_out = sub_update_mi(mi_in, sbc_mi)

mi_out = mi_in;

for ii = 1:length(mi_out.XTYMirrorMap.Offsets)
    dy_offset = sprintf('%.2f', (sbc_mi.y_mirr.dy(ii) * 1e9));
    mi_out.XTYMirrorMap.Offsets(ii).elt = dy_offset;
    dx_offset = sprintf('%.2f', (sbc_mi.x_mirr.dx(ii) * 1e9));
    mi_out.YTXMirrorMap.Offsets(ii).elt = dx_offset;
end
    

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


function intraf_out = sub_update_intraf(intraf_in, sbc_intraf)

xu = unique(sbc_intraf.x);
yu = unique(sbc_intraf.y);

[yg, xg] = meshgrid(yu, xu);
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


function susd_out = sub_update_susd(susd_in, sbc_susd)

susd_out = susd_in;

susd_out.Translation.X     =  sprintf('%.3f', (sbc_susd.TranslationX * 1e9));
susd_out.Translation.Y     =  sprintf('%.3f', (sbc_susd.TranslationY * 1e9));
susd_out.Magnification     =  sprintf('%.3f', (sbc_susd.Magnification * 1e6));
susd_out.Rotation          =  sprintf('%.4f', (sbc_susd.Rotation * 1e6));
susd_out.AsymRotation      =  sprintf('%.4f', (sbc_susd.AsymRotation * 1e6));
susd_out.AsymMagnification =  sprintf('%.3f', (sbc_susd.AsymMagnification * 1e6));

