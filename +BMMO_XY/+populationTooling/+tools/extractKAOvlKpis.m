function values = extractKAOvlKpis(inStruct, location, type, uncontrolled)
% values = extractKAOvlKpis(inStruct, location, type, uncontrolled)
%
% Function that extracts the uncontrolled or controlled clamp overlay kpis for chuck 1 and chuck 2 from the simulation results
% (rerun/self-correction) for x and y.
%
% Input Arguments:
% - inStruct        [ array of structs ]        Structs containing the
%                                                 simulation results from the 
%                                                 rerun or self-correction
%                                                 tooling, including the kpis
% - location        [ char array ]              'radial_inward', 'inner',
%                                                 'outer', 'radial' 
% - type            [ char array ]              'mean', 'median', 'x', 'y'
% 
% Optional Arguments:
% - uncontrolled    [ double ]                  Controlled (0) or uncontrolled
%                                                 ('uncontrolled' or 1)
%                                                 kpis. Default: controlled
% Output Arguments:
% - values          [ array of structs ]        Structs containing the
%                                                 extracted kpis
%


import BMMO_XY.populationTooling.tools.*

if exist('uncontrolled', 'var') && uncontrolled
    uncontrolled = true;
else
    uncontrolled = false;
end

if uncontrolled
    values.chk1.(type) = extractArrayFromStruct(inStruct, ['kpis.uncontrolled.input_clamp.ovl_' location '_chk1_' type]);
    values.chk2.(type) = extractArrayFromStruct(inStruct, ['kpis.uncontrolled.input_clamp.ovl_' location '_chk2_' type]);
elseif string(location) == "radial"
    values.chk1.(type) = extractArrayFromStruct(inStruct, ['kpis.input.input_clamp.ovl_radial_chk1_' type]);
    values.chk2.(type) = extractArrayFromStruct(inStruct, ['kpis.input.input_clamp.ovl_radial_chk2_' type]);
else
    values.chk1.x = extractArrayFromStruct(inStruct, ['kpis.input.input_clamp.ovl_' location '_chk1_' type '_x']);
    values.chk1.y = extractArrayFromStruct(inStruct, ['kpis.input.input_clamp.ovl_' location '_chk1_' type '_y']);
    values.chk2.x = extractArrayFromStruct(inStruct, ['kpis.input.input_clamp.ovl_' location '_chk2_' type '_x']);
    values.chk2.y = extractArrayFromStruct(inStruct, ['kpis.input.input_clamp.ovl_' location '_chk2_' type '_y']);
end

end