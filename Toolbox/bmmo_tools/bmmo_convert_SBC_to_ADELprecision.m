function out = bmmo_convert_SBC_to_ADELprecision(sbc)
% function out = bmmo_convert_SBC_to_ADELprecision(sbc)
%
% Get SBC correction from MATLAB with same precision as ADEL SBC recipe
%
% function out = bmmo_convert_SBC_to_ADELprecision(sbc)
%
% Input:
% sbc: Matlab sbc correction (out.corr, output by bmmo_nxe_drift_control_model)
%
% Output:
% out : sbc correction with precision as per schema
%
% 20200817 ANBZ Creation

% Intialize
out = sbc;

if isfield(sbc,'Configurations')
    out = rmfield(sbc,'Configurations');
end

out.IR2EUV           =   str2double(sprintf('%.16f', (sbc.IR2EUV)));

for ic = 1:2
    
    out.MI.wse(ic)       =  sub_update_mi( sbc.MI.wse(ic));
    out.MI.wsm(ic)       =  sub_update_mi( sbc.MI.wsm(ic));
    out.KA.grid_2de(ic)  =  sub_update_ka(sbc.KA.grid_2de(ic));
    out.BAO(ic)          =  sub_update_bao(sbc.BAO(ic));
    out.ffp(ic)          =   sub_update_intraf(sbc.ffp(ic));
    
    if isfield(sbc.KA, 'grid_2dc')
        out.KA.grid_2dc(ic)  =  sub_update_ka(sbc.KA.grid_2dc(ic));
    end
end

for i =1:length(sbc.SUSD)
    out.SUSD(i) =  sub_update_susd(sbc.SUSD(i));
end


function sbc_mi = sub_update_mi( sbc_mi)

for ii =1:length(sbc_mi.x_mirr.dx)
    sbc_mi.y_mirr.dy(ii) = str2double(sprintf('%.2f', (sbc_mi.y_mirr.dy(ii) * 1e9)))*1e-9;
    sbc_mi.x_mirr.dx(ii) = str2double(sprintf('%.2f', (sbc_mi.x_mirr.dx(ii) * 1e9)))*1e-9;
end


function sbc_ka = sub_update_ka(sbc_ka)

for ii =1:length(sbc_ka.dx)
    sbc_ka.dy(ii) = str2double(sprintf('%.2f', (sbc_ka.dy(ii)* 1e9)))*1e-9;
    sbc_ka.dx(ii) = str2double(sprintf('%.2f', (sbc_ka.dx(ii)* 1e9)))*1e-9;
end


function sbc_bao = sub_update_bao(sbc_bao)

sbc_bao.TranslationX                 =  str2double(sprintf('%.3f', (sbc_bao.TranslationX * 1e9)))*1e-9;
sbc_bao.TranslationY                 =  str2double(sprintf('%.3f', (sbc_bao.TranslationY * 1e9)))*1e-9;
sbc_bao.Magnification                =  str2double(sprintf('%.3f', (sbc_bao.Magnification * 1e6)))*1e-6;
sbc_bao.Rotation                     =  str2double(sprintf('%.4f', (sbc_bao.Rotation * 1e6)))*1e-6;
sbc_bao.AsymRotation                 =  str2double(sprintf('%.4f', (sbc_bao.AsymRotation * 1e6)))*1e-6;
sbc_bao.AsymMagnification            =  str2double(sprintf('%.3f', (sbc_bao.AsymMagnification * 1e6)))*1e-6;
sbc_bao.InterfieldRotation           =  str2double(sprintf('%.4f', (sbc_bao.InterfieldRotation * 1e6)))*1e-6;
sbc_bao.NonOrtho                     =  str2double(sprintf('%.4f', (sbc_bao.NonOrtho * 1e6)))*1e-6;
sbc_bao.ExpansionX                   =  str2double(sprintf('%.4f', (sbc_bao.ExpansionX * 1e6)))*1e-6;
sbc_bao.ExpansionY                   =  str2double(sprintf('%.4f', (sbc_bao.ExpansionY * 1e6)))*1e-6;


function sbc_intraf = sub_update_intraf(sbc_intraf)

for ii=1:length(sbc_intraf.dx)
    sbc_intraf.dx(ii)                = str2double(sprintf('%.2f', (sbc_intraf.dx(ii) * 1e9)))*1e-9;
    sbc_intraf.dy(ii)                = str2double(sprintf('%.2f', (sbc_intraf.dy(ii) * 1e9)))*1e-9;
end


function sbc_susd = sub_update_susd(sbc_susd)

sbc_susd.TranslationX      =  str2double(sprintf('%.3f', (sbc_susd.TranslationX * 1e9)))*1e-9;
sbc_susd.TranslationY      =  str2double(sprintf('%.3f', (sbc_susd.TranslationY * 1e9)))*1e-9;
sbc_susd.Magnification     =  str2double(sprintf('%.3f', (sbc_susd.Magnification * 1e6)))*1e-6;
sbc_susd.Rotation          =  str2double(sprintf('%.4f', (sbc_susd.Rotation * 1e6)))*1e-6;
sbc_susd.AsymRotation      =  str2double(sprintf('%.4f', (sbc_susd.AsymRotation * 1e6)))*1e-6;
sbc_susd.AsymMagnification =  str2double(sprintf('%.3f', (sbc_susd.AsymMagnification * 1e6)))*1e-6;
