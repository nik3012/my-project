function bao = bmmo_10par_to_BAO(parlist)
% function bao = bmmo_10par_to_BAO(parlist)
%
% Convert a 10par parlist to a BAO correction
%
% Input
%   parlist: 10par parlist as output by ovl_model
%
% Output
%   bao: BAO parameter list as defined in bmmo_default_output_structure

bao.TranslationX = parlist.tx;
bao.TranslationY = parlist.ty;
bao.Magnification = parlist.ms;
bao.AsymMagnification = parlist.ma;
bao.Rotation = parlist.rs;
bao.AsymRotation = parlist.ra;
bao.ExpansionX = parlist.mws + parlist.mwa;
bao.ExpansionY = parlist.mws - parlist.mwa;
bao.InterfieldRotation = parlist.rws - parlist.rwa;
bao.NonOrtho = 2 * parlist.rwa;

