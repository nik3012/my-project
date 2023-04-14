function values = extractInlineSdmLensOvlKpis(inStruct)
% values = extractInlineSdmLensOvlKpis(inStruct)
%
% Function that extracts the maxLensRes kpi from the simulation results
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

values.x = extractArrayFromStruct(inStruct, 'lens.Kpi.maxLensRes.dx');
values.y = extractArrayFromStruct(inStruct, 'lens.Kpi.maxLensRes.dy');

end