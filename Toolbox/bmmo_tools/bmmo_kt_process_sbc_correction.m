function sbc2 = bmmo_kt_process_sbc_correction(sbc2, corr_set, index)
%  function sbc2 = bmmo_kt_process_sbc_correction(sbc2, corr_set, index)
%
%  Process a single correction from an ADELsbcOverlayDriftControlNxe or
%   ADELsbcOverlayDriftControlNxeRep
%
% Input: sbc2: input sbc2 correction set
%        corr_set: either CorrectionSets(index).elt.Parameters (from SBCnxe)
%             or AppliedCorrectionList(index).elt.Corrections (from SBCnxerep)
%        index: index of correction set in XML file
%
% Output: sbc2: input sbc2 with correction added
%
%
% 20160503 SBPR Refactored from bmmo_kt_process_SBC2
% 20190322 SELR Preparation code for SUSD SBC (according to SIA-0)
% 20190801 SELR Updated for IFO in SBC2




par_names = {'SdmDistortionMap', 'MiMirrorOffsetMapMeasure', ...
    'MiMirrorOffsetMapExpose', 'KaOffsetMapExpose', ...
    'BlueAlignmentOffset', 'WaferHeatingOffset', 'IntraFieldOffset','KaOffsetMapMeasure'};
struct_fields = {'ffp', 'wsm', 'wse', 'grid_2de', 'BAO', 'IR2EUV', 'SUSD','grid_2dc'};

processing_functions = {@sub_parse_SDM, @sub_parse_MI, @sub_parse_MI, ...
    @sub_parse_KA, @sub_parse_BAO, @sub_parse_WH, @sub_parse_SUSD, @sub_parse_KA};

for j = 1:length(par_names)
    if isfield(corr_set, par_names{j})
        correction = feval(processing_functions{j}, corr_set.(par_names{j}));
        
        switch j
            case 2
                sbc2.MI.(struct_fields{j})(index) = correction;
            case 3
                sbc2.MI.(struct_fields{j})(index) = correction;
            case 4
                sbc2.KA.(struct_fields{j})(index) = correction;
            case 8
                sbc2.KA.(struct_fields{j})(index) = correction;
            otherwise
                sbc2.(struct_fields{j})(index) = correction;
        end
    end
end


% sub_parse_SDM
function grid = sub_parse_SDM(xml)

% dummy field will provide the x and y
dummy_field = ovl_get_fields(ovl_create_dummy('13x19', 'nlayer', 1, 'nwafer', 1), 1);

% From ADEL definition:
% List of offsets in X, Y, representing the XY map. The position in the list of
% map element (X,Y) can be found at position X + Y * (StepsX + 1) where StepsX
% is defined in the header of the map
g = [xml.Offsets.elt];
xg = str2double({g.X});
yg = str2double({g.Y});
xg = xg' * 1e-9;
yg = yg' * 1e-9;

% dummy_field has x in rows and y in cols: want to simulate this
% from definition: r,c = r + c * 13
% then the order of xg (before meander added) is:
% 0 = (0,0)
% 1 = (1,0)
% ...
%12 = (12,0),
%13 = (0,1)
%14 = (1,1) (etc)
% so xg has (meander excepted) the same order as dummy_field.wd.xf

% With the same meander as dummy_field.wd.xf, it should have this
% order:
% 0 = (0,0)
% 1 = (1,0)
% ...
%12 = (12,0),
%13 = (12,1)
%14 = (11,1) (etc)

% reshape to a 13x19 matrix
% Now all columns contain ascending x-values in the same order
xg = reshape(xg, 13, 19);
yg = reshape(yg, 13, 19);

% To match the meander of the data in dummy_field, every second column
% should be flipped top to bottom
xg(:, 2:2:end) = flipud(xg(:,2:2:end));
xg = xg(:);

yg(:, 2:2:end)  = flipud(yg(:,2:2:end));
yg = yg(:);

grid.x = dummy_field.wd.xf;
grid.y = dummy_field.wd.yf;
grid.dx = xg;
grid.dy = yg;


% sub_parse_MI (parses one set of mirror maps for one chuck, i.e. either expose or mirror side, either chuck 1 or chuck 2)
function mirr = sub_parse_MI(xml)
mirr.x_mirr = sub_parse_mirr(xml.YTXMirrorMap, 'y', 'dx');
mirr.y_mirr = sub_parse_mirr(xml.XTYMirrorMap, 'x', 'dy');


% sub_parse_KA
function grid = sub_parse_KA(xml)
grid = sub_parse_grid_new(xml);



% sub_parse_BAO
function BAO = sub_parse_BAO(xml)

NM = 1e-9;
UM = 1e-6;
URAD = 1e-6;

BAO.TranslationX = NM * str2double(xml.IntraField.Translation.X);
BAO.TranslationY = NM * str2double(xml.IntraField.Translation.Y);
BAO.Magnification = UM * str2double(xml.IntraField.Magnification);
BAO.AsymMagnification = UM * str2double(xml.IntraField.AsymMagnification);
BAO.Rotation = URAD * str2double(xml.IntraField.Rotation);
BAO.AsymRotation = URAD * str2double(xml.IntraField.AsymRotation);
BAO.ExpansionX = UM * str2double(xml.InterField.Expansion.X);
BAO.ExpansionY = UM * str2double(xml.InterField.Expansion.Y);
BAO.InterfieldRotation = URAD * str2double(xml.InterField.Rotation);
BAO.NonOrtho = URAD * str2double(xml.InterField.NonOrthogonality);


% sub_parse_WH
function IR2EUV = sub_parse_WH(xml)
IR2EUV = str2num(xml.Ir2EuvRatioOffset);



function grid = sub_parse_grid_new(xml)

pitch = sub_parse_xy(xml.Header.Pitch, 1e-3);
initial = sub_parse_xy(xml.Header.InitialPosition, 1e-3);
numsteps = sub_parse_xy(xml.Header.Steps, 1);

xpos = initial.x:pitch.x:(initial.x + (numsteps.x * pitch.x));
ypos = initial.y:pitch.y:(initial.y + (numsteps.y * pitch.y));

[KAgrid_xw, KAgrid_yw] = meshgrid(xpos, ypos);
grid.x                                 = reshape(KAgrid_xw, [], 1);
grid.y                                 = reshape(KAgrid_yw, [], 1);

g = [xml.Offsets.elt];

xg = str2double({g.X});
yg = str2double({g.Y});
grid.dx = xg' * 1e-9;
grid.dy = yg' * 1e-9;

invalid_idx = arrayfun(@(x) strcmp(x.valid, 'false'), g)';
grid.dx(invalid_idx) = NaN;
grid.dy(invalid_idx) = NaN;


function SUSD = sub_parse_SUSD(xml)

NM = 1e-9;
SUSD.TranslationX = NM * str2double(xml.Translation.X);
SUSD.TranslationY = NM * str2double(xml.Translation.Y);
SUSD.Magnification = NM * str2double(xml.Magnification);
SUSD.AsymMagnification = NM * str2double(xml.AsymMagnification);
SUSD.Rotation = NM * str2double(xml.Rotation);
SUSD.AsymRotation = NM * str2double(xml.AsymRotation);


% sub_parse_mirr (parses one map, i.e. a set of (pos, val) combinations
function mirr = sub_parse_mirr(xml, pos_name, val_name)
start = str2num(xml.Header.InitialPosition) * 1e-3;
pitch = str2num(xml.Header.Pitch) * 1e-3;
steps = str2num(xml.Header.Steps);
mirr.(pos_name) = (pitch * (0:steps)) + start;
mirr.(val_name) = arrayfun(@(elt) str2num(elt{1}) * 1e-9, {xml.Offsets.elt});
mirr.(pos_name) = (mirr.(pos_name))';
mirr.(val_name) = (mirr.(val_name))'; % 401x1 instead of 1x401;


% sub_parse_xy: parse a struct with string-valued fields 'X' and 'Y' into a struct with numerical-valued fields 'x' and 'y'
function xy = sub_parse_xy(xml, scale)
xy.x = str2num(xml.X) * scale;
xy.y = str2num(xml.Y) * scale;
