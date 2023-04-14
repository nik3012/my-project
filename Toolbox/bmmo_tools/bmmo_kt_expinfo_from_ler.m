function [expinfo, scan_direction] = bmmo_kt_expinfo_from_ler(ler)
% function [expinfo, scan_direction] = bmmo_kt_expinfo_from_ler(ler)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%


% read from exposure results of first wafer
exposed_fields = [ler.Results.WaferResultList(1).elt.ImageResultList(1).elt.ExposureResultList.elt];
exp_pos = [exposed_fields.FieldPosition];
expids = {exposed_fields.ExposureId};

exposure_image_list = ler.Input.WaferSettings.WaferGenericSettings.ImageSettings.ImageSpecificSettingsList;

% Check if there is just one exposure image
if length(exposure_image_list) == 1
    if ~strcmp(exposure_image_list.elt.ImageId, 'GEN_01')
        warning('Exposure image ID in ADELler is non-standard: %s', exposure_image_list.elt.ImageId)
    end
    image_index = 1;
else
    % If there are multiple images, store their ImageID's in a vector and
    % check for GEN_01
    for index = 1:length(exposure_image_list)
        image_IDs{index} = exposure_image_list(index).elt.ImageId;
        if strcmp(image_IDs{index}, 'GEN_01')
            image_index = index;
        end
    end
    % If none of the image ID's match with GEN_01, default to first one and
    % display a warning.
    if ~image_index
        image_index = 1;
        warning('BMMO image ID: GEN_01 not found from the image ID list: \n%s \nChoosing first image ID by default: %s', cell2str(image_IDs), image_IDs{image_index})
    end
end

% read settings to get scan direction and map to exposure results
settings = [ler.Input.WaferSettings.WaferGenericSettings.ImageSettings.ImageSpecificSettingsList(image_index).elt.ExposureSettings.ExposureSpecificSettingsList.elt];
setids = {settings.ExposureId};
scandirs = {settings.ExposureScanDirection};

% We've read cell arrays of strings. Convert to double.
xc_exp = {exp_pos.X}';
yc_exp = {exp_pos.Y}';
xc = 1e-3 * str2double(xc_exp);
yc = 1e-3 * str2double(yc_exp);

% Map result exposure ID to settings exposure ID
expid = str2double(expids);
setid = str2double(setids);
[lid, loc] = ismember(expid, setid);
map_setid_to_expid = loc(lid);

% Make sure all exposed results are mapped
assert(length(expid) == length(setid(map_setid_to_expid)), 'not all exposure results can be mapped to exposure settings');

% Get scan direction in order of result exposures
scanup =  double(strcmp(scandirs, 'Upwards'));
scandown = -1 * double(strcmp(scandirs, 'Downwards'));
scan_direction = scanup + scandown;
scan_direction = scan_direction(map_setid_to_expid)';

expinfo.xc = xc;
expinfo.yc = yc;
