var sourceData8 = {"FileContents":["function bao = bmmo_10par_to_BAO(parlist)\r","% function bao = bmmo_10par_to_BAO(parlist)\r","%\r","% Convert a 10par parlist to a BAO correction\r","%\r","% Input\r","%   parlist: 10par parlist as output by ovl_model\r","%\r","% Output\r","%   bao: BAO parameter list as defined in bmmo_default_output_structure\r","\r","bao.TranslationX = parlist.tx;\r","bao.TranslationY = parlist.ty;\r","bao.Magnification = parlist.ms;\r","bao.AsymMagnification = parlist.ma;\r","bao.Rotation = parlist.rs;\r","bao.AsymRotation = parlist.ra;\r","bao.ExpansionX = parlist.mws + parlist.mwa;\r","bao.ExpansionY = parlist.mws - parlist.mwa;\r","bao.InterfieldRotation = parlist.rws - parlist.rwa;\r","bao.NonOrtho = 2 * parlist.rwa;\r","\r",""],"CoverageData":{"CoveredLineNumbers":[12,13,14,15,16,17,18,19,20,21],"UnhitLineNumbers":[],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,259,259,259,259,259,259,259,259,259,259,0,0]}}