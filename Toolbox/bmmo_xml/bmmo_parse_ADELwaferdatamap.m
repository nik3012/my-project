function ml_all = bmmo_parse_ADELwaferdatamap(adelwdm)
% function ml_all = bmmo_parse_ADELwaferdatamap(adel_wdm)
%
% Load all the waferdata maps from an ADELwaferdatamap xml file into an ml
% structure
%
% If the function is run without any input, a dialog box is opened to choose the
% options
%
% Input:    adelwdm: full path of ADEL_waferdatamap file
%
% Output:   ml_all:  matlab struct containing all the different waferdatamaps
%                    as substructures in the ml format
%
% 20190726 SELR creation based on code from JIMI

data = xml_load(adelwdm);

WL_data = data.Body.WaferLayoutDefinitionList.elt.FieldList;
for ii=1:length(WL_data)
    f_id = str2double(WL_data(ii).elt.Id);
    xc_F(f_id) = str2double(WL_data(f_id).elt.Position.X)*1e-3;
    yc_F(f_id) = str2double(WL_data(f_id).elt.Position.Y)*1e-3;
end

ml_all=[];
ml_all.mid = data.Header.MachineID;
ml_all.jid = data.Body.JobId;

Allmaps= data.Body.WaferDataSetList;
for i=1:length(Allmaps)
    MapName = Allmaps(i).elt.Definition.Name;
    for j = 1:length(Allmaps(i).elt.WaferDataList)
        if isfield(Allmaps(i).elt.WaferDataList(j).elt, 'WaferId')
            Chk = str2double(Allmaps(i).elt.WaferDataList(j).elt.WaferId(end));
        elseif isfield(Allmaps(i).elt.WaferDataList(j).elt, 'ChuckId')
            Chk = str2double(Allmaps(i).elt.WaferDataList(j).elt.ChuckId(end));
        else
            Chk = 1;
        end
        map = data.Body.WaferDataSetList(i).elt.WaferDataList(j).elt.DataValueList;
        mlo=sub_get_ml(map, xc_F, yc_F);
%         invalid = arrayfun(@(x) isfield(x.elt.Overlay.X, 'InvalidationReasonId'), map);
%         invalidation_reason_id = arrayfun(@(x) str2double(x.elt.Overlay.X.InvalidationReasonId), map(invalid));
        ml_all.(MapName)(Chk) = mlo;
%         if sum(invalid) > 0
%             wc_invalid = [invalidation_reason_id' mlo.wd.xw(invalid), mlo.wd.yw(invalid)];
%             ml_all.(MapName)(Chk).invalid = wc_invalid;
%         end
    end
end


function mlo = sub_get_ml(data, xc_F, yc_F)
map=data;
nwafer=1;
for kk=1:length(map)
    f_id = str2double(map(kk).elt.IntrafieldPosition.FieldId);
    xf(kk) = str2double(map(kk).elt.IntrafieldPosition.Position.X)*1e-3;
    yf(kk) = str2double(map(kk).elt.IntrafieldPosition.Position.Y)*1e-3;
    dx(kk) = str2double(map(kk).elt.Overlay.X.Value) * 1e-9 ;
    dy(kk) = str2double(map(kk).elt.Overlay.Y.Value) * 1e-9 ;
    xc(kk) = xc_F(f_id);
    yc(kk) = yc_F(f_id);
end
numtargets=1;
mlo = repmat(struct('nwafer', nwafer, 'layer', [], 'wd', [], 'nmark', 1, 'nfield', 0, 'nlayer', 1, 'tlgname', ''), 1, numtargets);

mlo.wd.xc = xc';
mlo.wd.yc = yc';
mlo.wd.xf = xf';
mlo.wd.yf = yf';
mlo.wd.xw = mlo.wd.xc + mlo.wd.xf;
mlo.wd.yw = mlo.wd.yc + mlo.wd.yf;

mlo.nfield = length(mlo.wd.xc);

mlo.layer.wr.dx = dx';
mlo.layer.wr.dy = dy';