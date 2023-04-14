function values = extractMiOvlKpis(inStruct, type)
% values = extractMiOvlKpis(inStruct, type)
%
% Function that extracts the MI model overlay kpis for chuck 1 and chuck 2 from the simulation results
% (rerun/self-correction).
%
% Input Arguments:
% - inStruct        [ array of structs ]        Structs containing the
%                                                 simulation results from the 
%                                                 rerun or self-correction
%                                                 tooling, including the kpis
% - type            [ char array ]              'mean', 'median', 'x', 'y'
% 
% Output Arguments:
% - values          [ array of structs ]        Structs containing the
%                                                 extracted kpis
%

import BMMO_XY.populationTooling.tools.*

values.chk1.x = extractArrayFromStruct(inStruct, ['ovl_exp_ytx_' type '_wafer_chk1']);
values.chk1.y = extractArrayFromStruct(inStruct, ['ovl_exp_xty_' type '_wafer_chk1']);
values.chk2.x = extractArrayFromStruct(inStruct, ['ovl_exp_ytx_' type '_wafer_chk2']);
values.chk2.y = extractArrayFromStruct(inStruct, ['ovl_exp_xty_' type '_wafer_chk2']);
end