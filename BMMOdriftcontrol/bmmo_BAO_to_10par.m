function parlist = bmmo_BAO_to_10par(bao)
% function parlist = bmmo_BAO_to_10par(bao)
%
% Convert a BAO correction to a 10 par parlist
%
% Input
%   bao: BAO parameter list as defined in bmmo_default_output_structure
%
% Output
%   parlist: 10par parlist as outputted by ovl_model

parlist.tx = bao.TranslationX;
parlist.ty = bao.TranslationY;
parlist.ms = bao.Magnification;
parlist.ma = bao.AsymMagnification;
parlist.rs = bao.Rotation;
parlist.ra = bao.AsymRotation;
parlist.mws = (bao.ExpansionX + bao.ExpansionY) / 2;
parlist.mwa = (bao.ExpansionX - bao.ExpansionY) / 2;
parlist.rwa = bao.NonOrtho / 2;
parlist.rws = bao.InterfieldRotation + parlist.rwa;

