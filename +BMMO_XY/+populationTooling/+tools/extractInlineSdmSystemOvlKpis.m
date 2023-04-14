function values = extractInlineSdmSystemOvlKpis(inStruct)
% values = extractInlineSdmSystemOvlKpis(inStruct)
%
% Function that extracts the maxHOCRes kpis for chuck 1 and chuck 2 from the simulation results
% (rerun/self-correction).
%
% Input Arguments:
% - inStruct        [ array of structs ]        Structs containing the
%                                                 simulation results from the 
%                                                 rerun or self-correction
%                                                 tooling, including the kpis
% Output Arguments:
% - values          [ array of structs ]        structs containing the
%                                                 extracted kpis
%

import BMMO_XY.populationTooling.tools.*

values.chk1.x = extractArrayFromStruct(inStruct, 'hoc.Kpi.maxHOCRes(1).dx');
values.chk1.y = extractArrayFromStruct(inStruct, 'hoc.Kpi.maxHOCRes(1).dy');
values.chk2.x = extractArrayFromStruct(inStruct, 'hoc.Kpi.maxHOCRes(2).dx');
values.chk2.y = extractArrayFromStruct(inStruct, 'hoc.Kpi.maxHOCRes(2).dy');

end