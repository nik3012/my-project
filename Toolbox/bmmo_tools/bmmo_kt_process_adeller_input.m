function ml = bmmo_kt_process_adeller_input(mli, adeller)
% function ml = bmmo_kt_process_adeller_input(mli, adeller)
%
% Given an ml structure, return the structure with added fields parsed from
% the given ADELler, as required by the BMMO-NXE drift control model
%
% Input
%   mli: standard input structure 
%   adeller: full path of ADELler xml file
%
% Output
%   ml: input structure with added fields
%       ml.expinfo
%       ml.raw.expinfo
%       ml.info.report_data.FIWA_translation
%       ml.info.report_data.scan_direction
%       ml.info.F.machine_id
%       ml.info.F.chuck_id
%       ml.info.F.wafer_accepted
%       ml.info.F.exp_energy
%       ml.info.F.layer_id
%       ml.info.F.chuck_operation
%       ml.info.F.recipe
%       ml.info.F.image_size
%       ml.info.M.machine_type
%       ml.info.M.machine_id
%
% 20160411 SBPR Creation

% initialise output
ml = mli;

NM = 1e-9;

% read adeller
if ischar(adeller)
    ler = xml_load(adeller);
else
    ler = adeller;
end
    
[expinfo, Scan_direction] = bmmo_kt_expinfo_from_ler(ler);

[ml.expinfo, ml.info.report_data.Scan_direction] = bmmo_kt_expinfo_subset(ml, expinfo, Scan_direction);

if isfield(ml, 'raw')
    ml.raw.expinfo = bmmo_kt_expinfo_subset(ml.raw, expinfo, Scan_direction);
end

% Read FIWA translation 
wafer_results = [ler.Results.WaferResultList.elt];
wa_results = [wafer_results.WaferAlignmentResult];
wa_results = [wa_results.Translation];

ml.info.report_data.FIWA_translation.x = str2double({wa_results.X}) * NM;
ml.info.report_data.FIWA_translation.y = str2double({wa_results.Y}) * NM;

% Read wafer accepted array 
wa_accepted = {wafer_results.WaferResult};
map = strcmp(wa_accepted, 'Accepted');
for ia = 1:length(map)
   if(map(ia))
       wa_accepted{ia} = 'TRUE';
   else
       wa_accepted{ia} = 'FALSE';
   end
end
ml.info.F.wafer_accepted = wa_accepted;

% Read chuck info array
ch_id = {wafer_results.ChuckId};
chuck_id = cell(1,length(ch_id));
for ic = 1:length(ch_id)
   if strcmp(ch_id{ic}, 'Waferstage chuck ID 1')
       chuck_id{ic} = 'CHUCK_ID_1';
   elseif strcmp(ch_id{ic}, 'Waferstage chuck ID 2')
       chuck_id{ic} = 'CHUCK_ID_2';
   end
end
ml.info.F.chuck_id = chuck_id;

% Read exp_energy from exposure 1 wafer 1
ml.info.F.exp_energy = str2double(wafer_results(1).ImageResultList(1).elt.ExposureResultList(1).elt.EnergyTotal); 

ml.info.F.layer_id = ler.Input.LotSettings.LayerId;

% Read chuck operation
ml.info.F.chuck_operation = 'USE_BOTH_CHUCK';
if strncmp(ler.Input.WaferSettings.WaferGenericSettings.ChuckDedicationMethod, 'Single', 6)
    ml.info.F.chuck_operation = 'USE_ONE_CHUCK';
end

ml.info.F.recipe = ler.Input.LotSettings.ExposureRecipeId;

MM = 1e-3;
ml.info.F.image_size.x = str2double(ler.Input.WaferSettings.WaferGenericSettings.ImageSettings.ImageSpecificSettingsList(1).elt.ImageSize.X) * MM;
ml.info.F.image_size.y = str2double(ler.Input.WaferSettings.WaferGenericSettings.ImageSettings.ImageSpecificSettingsList(1).elt.ImageSize.Y) * MM;
if isfield(ler.Input.WaferSettings.WaferGenericSettings.ImageSettings.ImageSpecificSettingsList(1).elt, 'ImageShift')
    ml.info.F.image_shift.x = str2double(ler.Input.WaferSettings.WaferGenericSettings.ImageSettings.ImageSpecificSettingsList(1).elt.ImageShift.X)* MM;
    ml.info.F.image_shift.y = str2double(ler.Input.WaferSettings.WaferGenericSettings.ImageSettings.ImageSpecificSettingsList(1).elt.ImageShift.Y)* MM;
end

% Read machine data
ml.info.F.machine_id                = ler.Header.MachineID;
ml.info.M.machine_id                = ler.Header.MachineID;
ml.info.M.machine_type              = ler.Header.MachineType;
ml.info.F.machine_type              = ler.Header.MachineType;

tret =  str2double({ler.Results.LotImageResultList(1).elt.ImageReticleResult.TransmissionFactorUsed}) ./ 100.0;
ml.info.report_data.Tret = mean(tret);
