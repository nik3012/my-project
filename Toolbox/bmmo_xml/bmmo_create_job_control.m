
% Create Job control file for recover/control job
%
%   input
%       path: path of the folder with ADELler, ADELmetrology and Job
%       control template
%
%   Optional input
%     job_type = 1, Recover to baseline (default)
%     job_type = 2, Control to baseline
%
%   output
%     Updated Job control file with same name and path as the input
%     Conditional output: Updated ADELler with wafer Ids if not already present




function adel_jbctrl =  bmmo_create_job_control(path, time_filter)

if nargin < 2
    time_filter = 0;
end

if nargin < 1
    path = pwd;
end

% Find necessary ADELs
adels_to_find = {'ADELmetrology', 'ADELler','ADELbmmoOverlayJobControl'};
adel_fields = {'adelmet', 'adeller', 'jbctrl'};
adels = bmmo_find_adels(path, adels_to_find, adel_fields);

% load xml files
adel_met = xml_load(adels.adelmet);
adel_adeller = xml_load(adels.adeller);
adel_jbctrl = xml_load(adels.jbctrl);

% get WEC ids from adelmetrology
ml_all     = bmmo_process_adelmetrology(adels.adelmet);
wid_id     =  strcmp({ml_all.targetlabel}, 'WID_UP');
wids = bmmo_get_wid(ml_all(wid_id));

% update exposure context equipment and lot id
adel_jbctrl.Job.ExposureContext.EquipmentId  = adel_adeller.Header.MachineID;
adel_jbctrl.Job.ExposureContext.LotId        = adel_adeller.Input.LotId;
% update metology context equipment and lot id
adel_jbctrl.Job.MetrologyContext.EquipmentId =  adel_met.Header.MachineID;
adel_jbctrl.Job.MetrologyContext.LotId       =  adel_met.Input.LotId;
rand_uid = erase(num2str(floor(clock)), ' ');
max_length = min(length(rand_uid), 8);
adel_jbctrl.Header.DocumentId(1:max_length) = rand_uid(end-max_length+1:end);

% Update type of job
if time_filter
    adel_jbctrl.Job.ControlMode = 'Control to baseline';
else
    adel_jbctrl.Job.ControlMode = 'Recover to baseline';
end

% check if Wafer ids are present in ADELLer or else create them
if isempty(adel_adeller.Results.WaferResultList(1).elt.WaferId)
    warning('No Wafer Ids found in ADELler, creating default Ids to 1,2,3..');
    for ii = 1:length(adel_adeller.Results.WaferResultList)
        adel_adeller.Results.WaferResultList(ii).elt.WaferId = num2str(ii);
    end
    
    % create new ADELler
    recipe_version = adel_adeller.Header.DocumentTypeVersion;
    str1='xmlns:ADELler="http://www.asml.com/XMLSchema/MT/Generic/ADELler/vx.x.x"';
    str2='xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"';
    str3='xsi:schemaLocation="http://www.asml.com/XMLSchema/MT/Generic/ADELler/vx.x.x ADELler.xsd"';
    schema_info =compose(str1+"\n"+str2+"\n"+str3);
    schema_info = strrep(schema_info, 'vx.x.x', recipe_version);
    bmmo_xml_save(adels.adeller, adel_adeller, 'ADELler:Report', schema_info);
end

% copy ADEller, ADELmetrology and WEC wafer Ids to Job control
nwafer = length(adel_met.Results.WaferResultList); % number of readout wafers
for i = 1:nwafer
    adel_jbctrl.Job.WaferContextList(i).WaferContext.ExposureContext.WaferId = adel_adeller.Results.WaferResultList(i).elt.WaferId;
    adel_jbctrl.Job.WaferContextList(i).WaferContext.MetrologyContext.WaferId = adel_met.Results.WaferResultList(i).WaferResult.WaferId;
    adel_jbctrl.Job.WaferContextList(i).WaferContext.WaferErrorCorrection.SubstrateWaferId = wids{i};
end

% create Job control xml
recipe_version = adel_jbctrl.Header.DocumentTypeVersion;
str1='xmlns:ADELbmmoOverlayJobControl="http://www.asml.com/XMLSchema/MT/Generic/ADELbmmoOverlayJobControl/vx.x"';
str2='xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"';
str3='xsi:schemaLocation="http://www.asml.com/XMLSchema/MT/Generic/ADELbmmoOverlayJobControl/vx.x ADELbmmoOverlayJobControl_vx.x.xsd"';
schema_info =compose(str1+"\n"+str2+"\n"+str3);
schema_info = strrep(schema_info, 'vx.x', recipe_version);
bmmo_xml_save(adels.jbctrl, adel_jbctrl, ['ADELbmmoOverlayJobControl:JobControl' newline], schema_info);

