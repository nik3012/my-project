function values = extractSusdOvlKpis(inStruct)
% values = extractSusdOvlKpis(inStruct)
%
% Function that extracts the susd overlay kpis for chuck 1 and chuck 2 from the simulation results
% (rerun/self-correction).
%
% Input Arguments:
% - inStruct            [ array of structs ]    Structs containing the
%                                                 simulation results from the 
%                                                 rerun or self-correction
%                                                 tooling, including the kpis
% 
% Output Arguments:
% - values              [ array of structs ]    Structs containing the
%                                                 extracted kpis
%
import BMMO_XY.populationTooling.tools.*

values.chk1.y   = abs(extractArrayFromStruct(inStruct, 'ovl_exp_grid_chk1_ty_susd'));
values.chk2.y   = abs(extractArrayFromStruct(inStruct, 'ovl_exp_grid_chk2_ty_susd'));
values.chk1.x   = zeros(1, length(values.chk1.y));
values.chk2.x   = zeros(1, length(values.chk2.y));

end