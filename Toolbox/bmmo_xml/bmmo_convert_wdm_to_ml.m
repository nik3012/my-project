function [ml_all, invalids] = bmmo_convert_wdm_to_ml(adelwdm, load_invalids, use_meas_layout, skip_reconstruction)
% function ml_all = bmmo_convert_wdm_to_ml(adel_wdm)
%
% Load all the waferdata maps from an ADELwaferdatamap xml file into an ml
% structure
%
% If the function is run without any input, a dialog box is opened to choose the
% options
%
% Input:    adelwdm: full path of ADEL_waferdatamap file
%           load_invalids: If set to 1, the invalid measurements will be
%                          loaded as valids
%           use_meas_layout: If set to 1, uses the RIT target as center,
%                            otherwise XPA
%
% Output:   ml_all:  matlab struct containing all the different waferdatamaps
%                    as substructures in the ml format
%
% 20190726 SELR creation based on code from JIMI

if nargin < 2
    load_invalids = 0;
end
if nargin < 3
    use_meas_layout = 1;
end
if nargin < 4
    skip_reconstruction = 0;
end


if ischar(adelwdm)
    data = xml_load(adelwdm);
else
    data = adelwdm;
end

if length(data.Body.WaferLayoutDefinitionList) > 1
    WL_data = data.Body.WaferLayoutDefinitionList(2).elt.FieldList;
else
    WL_data = data.Body.WaferLayoutDefinitionList.elt.FieldList;
end
for ii=1:length(WL_data)
    f_id = str2double(WL_data(ii).elt.Id);
    xc_F(f_id) = str2double(WL_data(f_id).elt.Position.X)*1e-3;
    yc_F(f_id) = str2double(WL_data(f_id).elt.Position.Y)*1e-3;
end

ml_all=[];
ml_all.mid = data.Header.MachineID;
if isfield(data.Body, 'JobId')
    ml_all.jid = data.Body.JobId;
end

Allmaps= data.Body.WaferDataSetList;
% clear data

for i=1:length(Allmaps)
    
    if length(Allmaps(i).elt.WaferDataList) == 2 
        Chk_all = sub_get_ChuckId(Allmaps(i).elt.WaferDataList);
    else
        Chk_all = sub_get_WaferId(Allmaps(i).elt.WaferDataList);
    end
    
    MapName = matlab.lang.makeValidName(Allmaps(i).elt.Definition.Name);
    for j = 1:length(Allmaps(i).elt.WaferDataList)
        
        Chk = Chk_all(j);
        map = Allmaps(i).elt.WaferDataList(Chk).elt.DataValueList;
        mlt=sub_get_ml(map, xc_F, yc_F);
        
        % Load invalids
        invalidx = arrayfun(@(x) isfield(x.elt.Overlay.X, 'InvalidationReasonId'), map);
        invalidy = arrayfun(@(x) isfield(x.elt.Overlay.Y, 'InvalidationReasonId'), map);
        
        invalidx = invalidx';
        invalidy = invalidy';
        
        invalidation_reason_id = arrayfun(@(x) str2double(x.elt.Overlay.X.InvalidationReasonId), map(invalidx));
        invalidation_reason_id2 = arrayfun(@(x) str2double(x.elt.Overlay.Y.InvalidationReasonId), map(invalidy));

        if ~load_invalids
            mlt.layer.wr.dx(invalidx) = NaN;
            mlt.layer.wr.dy(invalidy) = NaN;
        end
        
        
        if ~skip_reconstruction
            dummy_in = bmmo_default_input;
            mlt.expinfo = dummy_in.expinfo;
            options = bmmo_default_options_structure;
            try
                options = bmmo_get_xy_shift(mlt, options);
            catch
                warning('You better be importing s2f data or something :)')
            end
            mlo = bmmo_field_reconstruction(mlt, options);
            if use_meas_layout
                mlo = bmmo_shift_fields(mlo, options.x_shift, options.y_shift);
            end
        else
            mlo = mlt;
        end
        
        try
            for iwafer = 1:mlo.nwafer
                assert(sum(~isnan(mlo.layer.wr(iwafer).dx)) == sum(~isnan(mlt.layer.wr(iwafer).dx)));
            end
        catch
            warning('Some marks were lost during mapping')
        end
        
        ml_all.(MapName)(j) = mlo;
        invalid = invalidx & invalidy;
        if sum(invalid) > 0
            wc_invalid = [invalidation_reason_id' mlt.wd.xw(invalid), mlt.wd.yw(invalid) invalidation_reason_id2'];
            invalids.(MapName)(j).invalid = wc_invalid;
            invalids.(MapName)(j).chk = Chk;
        end
        
    end
end
if exist('invalids','var')
ml_all.invalids = invalids;
end


function mlo = sub_get_ml(data, xc_F, yc_F)
map=data;
nwafer=1;
for kk=1:length(map)
    f_id = str2double(map(kk).elt.IntrafieldPosition.FieldId);
    xf(kk) = str2double(map(kk).elt.IntrafieldPosition.Position.X)*1e-3;
    yf(kk) = str2double(map(kk).elt.IntrafieldPosition.Position.Y)*1e-3;
    if ~isempty(map(kk).elt.Overlay.X)
        dx(kk) = str2double(map(kk).elt.Overlay.X.Value) * 1e-9;
    else
        dx(kk) = NaN;
    end
    if ~isempty(map(kk).elt.Overlay.Y)
        dy(kk) = str2double(map(kk).elt.Overlay.Y.Value) * 1e-9;
    else
        dy(kk) = NaN;
    end
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



function Chk =  sub_get_WaferId(map)

for i =  1:length(map)
    if isfield(map(1).elt, 'WaferId')   
        wid(i) = str2double(map(i).elt.WaferId(end-1:end));
    elseif isfield(map(1).elt, 'ChuckId')
        wid(i) = str2double(map(i).elt.ChuckId(end));
    else
        wid(i) = i;
    end
end
[~, Chk] = sort(wid);


function Chk =  sub_get_ChuckId(map)
for i =  1:length(map)
    if isfield(map(1).elt, 'ChuckId')   
        wid(i) = str2double(map(i).elt.ChuckId(end));
    elseif isfield(map(1).elt, 'WaferId')
        wid(i) = str2double(map(i).elt.WaferId(end));
    else
        wid(i) = i;
    end
end
[~, Chk] = sort(wid);