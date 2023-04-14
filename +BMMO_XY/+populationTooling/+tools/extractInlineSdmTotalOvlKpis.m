function values = extractInlineSdmTotalOvlKpis(inStruct)
% values = extractInlineSdmTotalOvlKpis(inStruct)
%
% Function that extracts the maxTotalRes kpis for chuck 1 and chuck 2 from the simulation results
% (rerun/self-correction).
%
% Input Arguments:
% - inStruct        [ array of structs ]        Structs containing the
%                                                 simulation results from the 
%                                                 rerun or self-correction
%                                                 tooling, including the kpis
% Output Arguments:
% - values          [ array of structs ]        Structs containing the
%                                                 extracted kpis
%
import BMMO_XY.populationTooling.tools.*

values.chk1.x = extractArrayFromStruct(inStruct, 'Kpi.maxTotalRes(1).dx');
values.chk1.y = extractArrayFromStruct(inStruct, 'Kpi.maxTotalRes(1).dy');
values.chk2.x = extractArrayFromStruct(inStruct, 'Kpi.maxTotalRes(2).dx');
values.chk2.y = extractArrayFromStruct(inStruct, 'Kpi.maxTotalRes(2).dy');

end