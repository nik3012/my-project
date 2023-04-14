function corr_out = bmmo_parse_sbc_IFO(corr_in, xml_corr_IFO)
%% Description:
% Add the IFO corrections from xml to the input correction structure in the
% format of the bmmo_nxe_drift_control_model output
%
% Input:
% - corr_in: formatted correction structure with all corrections except SUSD
% - xml_corr_IFO: IntraFieldOffset for both chuck and scan directions from 
%                 xml (ADELsbc or ADELscbrep)  
%
% Output:
% - sbc2: formatted correction set including SUSD

%% History
% 20151008  SELR	Creation

corr_out = corr_in;

NM = 1e-9;
UM = 1e-6;
URAD = 1e-6;

for i_IFO = 1:length(xml_corr_IFO)    
    corr_out.SUSD(i_IFO).TranslationX = NM * str2double(xml_corr_IFO(i_IFO).Translation.X);
    corr_out.SUSD(i_IFO).TranslationY = NM * str2double(xml_corr_IFO(i_IFO).Translation.Y);
    corr_out.SUSD(i_IFO).Magnification = UM * str2double(xml_corr_IFO(i_IFO).Magnification);
    corr_out.SUSD(i_IFO).AsymMagnification = UM * str2double(xml_corr_IFO(i_IFO).AsymMagnification);
    corr_out.SUSD(i_IFO).Rotation = URAD * str2double(xml_corr_IFO(i_IFO).Rotation);
    corr_out.SUSD(i_IFO).AsymRotation = URAD * str2double(xml_corr_IFO(i_IFO).AsymRotation);
end