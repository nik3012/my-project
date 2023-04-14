var sourceData561 = {"FileContents":["% function bmmo_inject_sbc_into_ADEL_xml(xml_data, sbc)\r","%\r","% Inject the data from a bmmo sbc correction into the xml_data read from an\r","% ADELsbcOverlayDriftControlNxe with xml_load\r","%\r","% Input: (both structs)   \r","%   xml_data: read from an ADELsbcOverlayDriftControlNxe with xml_load\r","%   sbc: out.corr output from BMMO-NXE model\r","%\r","% 20201017 SBPR refactored from bmmo_create_ADEL_SBC; replaced OTIE chuck \r","function tmp_data = bmmo_inject_sbc_into_ADEL_xml(xml_data, sbc)\r","\r","tmp_data = xml_data;\r","\r","% Verify \r","% data.CorrectionSets(c).elt.ApplicationRange.Exposure.Wafer.WaferStageChuckId\r","% is the same as the chuck id\r","\r","sbc_chuck_order = arrayfun(@(x) str2double(x.elt.ApplicationRange.Exposure.Wafer.WaferStageChuckId(end)), xml_data.CorrectionSets);\r","\r","for ic = 1:2\r","    chuck_id = sbc_chuck_order(ic);\r","    \r","    tmp_data.CorrectionSets(chuck_id).elt.Parameters.MiMirrorOffsetMapExpose = ...\r","        sub_update_mi(tmp_data.CorrectionSets(chuck_id).elt.Parameters.MiMirrorOffsetMapExpose, sbc.MI.wse(ic));\r","    \r","    tmp_data.CorrectionSets(chuck_id).elt.Parameters.MiMirrorOffsetMapMeasure = ...\r","        sub_update_mi(tmp_data.CorrectionSets(chuck_id).elt.Parameters.MiMirrorOffsetMapMeasure, sbc.MI.wsm(ic));\r","    \r","    tmp_data.CorrectionSets(chuck_id).elt.Parameters.KaOffsetMapExpose = ...\r","        sub_update_ka(tmp_data.CorrectionSets(chuck_id).elt.Parameters.KaOffsetMapExpose, sbc.KA.grid_2de(ic));\r","    \r","    tmp_data.CorrectionSets(chuck_id).elt.Parameters.BlueAlignmentOffset = ...\r","        sub_update_bao(tmp_data.CorrectionSets(chuck_id).elt.Parameters.BlueAlignmentOffset, sbc.BAO(ic));\r","    \r","    tmp_data.CorrectionSets(chuck_id).elt.Parameters.SdmDistortionMap = ...\r","        sub_update_intraf(tmp_data.CorrectionSets(chuck_id).elt.Parameters.SdmDistortionMap, sbc.ffp(ic));\r","    \r","    tmp_data.CorrectionSets(chuck_id).elt.Parameters.WaferHeatingOffset.Ir2EuvRatioOffset = sprintf('%.4f', sbc.IR2EUV);\r","    \r","    if ~isfield(sbc.KA, 'grid_2dc')\r","        if isfield(tmp_data.CorrectionSets(chuck_id).elt.Parameters, 'KAOffsetMapMeasure')\r","            tmp_data.CorrectionSets(chuck_id).elt.Parameters = rmfield(tmp_data.CorrectionSets(chuck_id).elt.Parameters, 'KAOffsetMapMeasure');\r","        end\r","    else\r","        if ~isfield(tmp_data.CorrectionSets(chuck_id).elt.Parameters, 'KaOffsetMapMeasure')\r","            error('Measure side offset present in SBC structure but not in XML data');\r","        else\r","            tmp_data.CorrectionSets(chuck_id).elt.Parameters.KaOffsetMapMeasure = ...\r","                sub_update_ka(tmp_data.CorrectionSets(chuck_id).elt.Parameters.KaOffsetMapMeasure, sbc.KA.grid_2dc(ic));\r","        end\r","    end\r","    \r","end    \r","\r","recipe_version = xml_data.Header.DocumentTypeVersion;\r","IFO_in_recipe = ~(strcmp(recipe_version, 'v1.0') | strcmp(recipe_version, 'v1.1'));\r","\r","if IFO_in_recipe\r","    IFO_corr_set_ind = arrayfun(@(x) ~(endsWith(x.elt.CorrectionSetName, num2str(1)) | endsWith(x.elt.CorrectionSetName, num2str(2))), xml_data.CorrectionSets);\r","    IFO_corr_set = xml_data.CorrectionSets(IFO_corr_set_ind);\r","    IFO_corr_set_names = arrayfun(@(x) x.elt.CorrectionSetName, IFO_corr_set, 'UniformOutput', false);\r","    [~, IFO_corr_set_ind_sorted] = sort(IFO_corr_set_names);\r","    \r","    \r","    for icorr_IFO = 1:length(IFO_corr_set_ind_sorted)\r","        IFO_corr_set(IFO_corr_set_ind_sorted(icorr_IFO)).elt.Parameters.IntraFieldOffset = ...\r","            sub_update_susd(IFO_corr_set(IFO_corr_set_ind_sorted(icorr_IFO)).elt.Parameters.IntraFieldOffset,...\r","            sbc.SUSD(icorr_IFO));\r","    end\r","    \r","    tmp_data.CorrectionSets(IFO_corr_set_ind) = IFO_corr_set;\r","end\r","\r","\r","\r","function mi_out = sub_update_mi(mi_in, sbc_mi)\r","\r","mi_out = mi_in;\r","\r","for ii = 1:length(mi_out.XTYMirrorMap.Offsets)\r","    dy_offset = sprintf('%.2f', (sbc_mi.y_mirr.dy(ii) * 1e9));\r","    mi_out.XTYMirrorMap.Offsets(ii).elt = dy_offset;\r","    dx_offset = sprintf('%.2f', (sbc_mi.x_mirr.dx(ii) * 1e9));\r","    mi_out.YTXMirrorMap.Offsets(ii).elt = dx_offset;\r","end\r","    \r","\r","function ka_out = sub_update_ka(ka_in, sbc_ka)\r","\r","ka_out = ka_in;\r","\r","for ii = 1:length(ka_out.Offsets)\r","    if isnan(sbc_ka.dy(ii)) || isnan(sbc_ka.dx(ii))\r","        dy_offset = sprintf('%.2f', (0 * 1e9));\r","        ka_out.Offsets(ii).elt.Y = dy_offset;\r","        dx_offset = sprintf('%.2f', (0 * 1e9));\r","        ka_out.Offsets(ii).elt.X = dx_offset;\r","        ka_out.Offsets(ii).elt.valid = 'false';\r","    else\r","        dy_offset = sprintf('%.2f', (sbc_ka.dy(ii) * 1e9));\r","        ka_out.Offsets(ii).elt.Y = dy_offset;\r","        dx_offset = sprintf('%.2f', (sbc_ka.dx(ii) * 1e9));\r","        ka_out.Offsets(ii).elt.X = dx_offset;\r","        ka_out.Offsets(ii).elt.valid = 'true';\r","    end\r","end\r","\r","\r","function bao_out = sub_update_bao(bao_in, sbc_bao)\r","\r","bao_out = bao_in;\r","\r","bao_out.IntraField.Translation.X     =  sprintf('%.3f', (sbc_bao.TranslationX * 1e9));\r","bao_out.IntraField.Translation.Y     =  sprintf('%.3f', (sbc_bao.TranslationY * 1e9));\r","bao_out.IntraField.Magnification     =  sprintf('%.3f', (sbc_bao.Magnification * 1e6));\r","bao_out.IntraField.Rotation          =  sprintf('%.4f', (sbc_bao.Rotation * 1e6));\r","bao_out.IntraField.AsymRotation      =  sprintf('%.4f', (sbc_bao.AsymRotation * 1e6));\r","bao_out.IntraField.AsymMagnification =  sprintf('%.3f', (sbc_bao.AsymMagnification * 1e6));\r","bao_out.InterField.Translation.X     =  sprintf('%.3f', 0.0);\r","bao_out.InterField.Translation.Y     =  sprintf('%.3f', 0.0);\r","bao_out.InterField.Rotation          =  sprintf('%.4f', (sbc_bao.InterfieldRotation * 1e6));\r","bao_out.InterField.NonOrthogonality  =  sprintf('%.4f', (sbc_bao.NonOrtho * 1e6));\r","bao_out.InterField.Expansion.X       =  sprintf('%.4f', (sbc_bao.ExpansionX * 1e6));\r","bao_out.InterField.Expansion.Y       =  sprintf('%.4f', (sbc_bao.ExpansionY * 1e6));\r","\r","\r","function intraf_out = sub_update_intraf(intraf_in, sbc_intraf)\r","\r","xu = unique(sbc_intraf.x);\r","yu = unique(sbc_intraf.y);\r","\r","[yg, xg] = meshgrid(yu, xu);\r","xg = xg(:);\r","yg = yg(:);\r","\r","I = knnsearch([xg yg], [sbc_intraf.x sbc_intraf.y]);\r","\r","dxmap = sbc_intraf.dx(I);\r","dymap = sbc_intraf.dy(I);\r","\r","intraf_out = intraf_in;\r","\r","for ii = 1:length(intraf_out.Offsets)\r","    intraf_out.Offsets(ii).elt.X = sprintf('%.2f', (dxmap(ii) * 1e9));\r","    intraf_out.Offsets(ii).elt.Y = sprintf('%.2f', (dymap(ii) * 1e9));\r","end\r","\r","\r","function susd_out = sub_update_susd(susd_in, sbc_susd)\r","\r","susd_out = susd_in;\r","\r","susd_out.Translation.X     =  sprintf('%.3f', (sbc_susd.TranslationX * 1e9));\r","susd_out.Translation.Y     =  sprintf('%.3f', (sbc_susd.TranslationY * 1e9));\r","susd_out.Magnification     =  sprintf('%.3f', (sbc_susd.Magnification * 1e6));\r","susd_out.Rotation          =  sprintf('%.4f', (sbc_susd.Rotation * 1e6));\r","susd_out.AsymRotation      =  sprintf('%.4f', (sbc_susd.AsymRotation * 1e6));\r","susd_out.AsymMagnification =  sprintf('%.3f', (sbc_susd.AsymMagnification * 1e6));\r","\r",""],"CoverageData":{"CoveredLineNumbers":[13,19,21,22,24,25,27,28,30,31,33,34,36,37,39,41,45,46,48,49,50,56,57,59,60,61,62,63,66,67,68,69,72,79,81,82,83,84,85,91,93,94,95,96,97,98,99,100,101,102,103,104,105,112,114,115,116,117,118,119,120,121,122,123,124,125,130,131,133,134,135,137,139,140,142,144,145,146,152,154,155,156,157,158,159],"UnhitLineNumbers":[42,43,47],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,2,0,2,4,0,4,4,0,4,4,0,4,4,0,4,4,0,4,4,0,4,0,4,0,0,0,4,4,0,4,4,4,0,0,0,0,0,2,2,0,2,2,2,2,2,0,0,2,8,8,8,0,0,2,0,0,0,0,0,0,8,0,8,3208,3208,3208,3208,0,0,0,0,0,8,0,8,29768,7200,7200,7200,7200,7200,22568,22568,22568,22568,22568,22568,0,0,0,0,0,0,4,0,4,4,4,4,4,4,4,4,4,4,4,4,0,0,0,0,4,4,0,4,4,4,0,4,0,4,4,0,4,0,4,988,988,0,0,0,0,0,8,0,8,8,8,8,8,8,0,0]}}