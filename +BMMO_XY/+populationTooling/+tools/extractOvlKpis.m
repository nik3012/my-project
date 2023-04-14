function values = extractOvlKpis(inStruct, type)
% values = extractOvlKpis(inStruct, type)
%
% Function that extracts the 997, max, m3s or 3std overlay kpis for chuck 1 and chuck 2 in x and y from the simulation results
% (rerun/self-correction).
%
% Input Arguments:
% - inStruct        [ array of structs ]        Structs containing the
%                                                 simulation results from the 
%                                                 rerun or self-correction
%                                                 tooling, including the kpis
% - type            [ char array ]              '997', 'max', 'm3s', '3std'
% 
% Output Arguments:
% - values          [ array of structs ]        Structs containing the
%                                                 extracted kpis
%

import BMMO_XY.populationTooling.tools.*

if iscell(inStruct)
    for index = 1 : length(inStruct)
        realStruct(index) = inStruct{index};
    end
    inStruct = realStruct;
end

values.chk1.x = extractArrayFromStruct(inStruct, ['ovl_chk1_' type '_x']);
values.chk1.y = extractArrayFromStruct(inStruct, ['ovl_chk1_' type '_y']);
values.chk2.x = extractArrayFromStruct(inStruct, ['ovl_chk2_' type '_x']);
values.chk2.y = extractArrayFromStruct(inStruct, ['ovl_chk2_' type '_y']);

end