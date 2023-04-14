function bmmo_create_ADEL_SBC(infile, outfile, sbc, inline_sdm, machine, fms)
% function bmmo_create_ADEL_SBC(infile, outfile, sbc)
%
% Build a new ADEL SBC2 correction on the template of an existing one
% replacing the correction data with the data from a Matlab sbc2 correction
%
% Input
%   infile: full path of ADEL SBC2 recipe
%   outfile: full path of output file
%   sbc: Matlab sbc correction (output by bmmo_nxe_drift_control_model)
%
% Optional input:
%   inline_sdm: inline_sdm struct with either or both time_filter and sdm_model fields
%               (as parsed by bmmo_kt_process_SBC2).The value can be left
%               empty if not needed to be updated [Example:
%               bmmo_create_ADEL_SBC('AdelSbcIn.xml', 'AdelSbcOut.xml',
%               sbc, [], '1001', fms)]
%   machine: Machine ID (char) to be updated in the outfile
%   fms: xml loaded ADELfineMetrologyOverlayState file to update the FMS value
%
%
% 20160922 SBPR Creation
% 20190524 KZAK Fixed KA-map generation
% 20190807 SELR Updated for IFO in SBC2a

if ischar(infile)
    xml_data = xml_load(infile);
else
    xml_data = infile;
end
    
tmp_data = bmmo_inject_sbc_into_ADEL_xml(xml_data, sbc);

if nargin > 3
    if ~isempty(inline_sdm)
        tmp_data = sub_bmmo_inject_inline_sdm_into_ADEL_xml(tmp_data, inline_sdm);
    else
        warning('inline_sdm is empty, Header of SdmDistortionMap will not be updated in the xml.')
    end
end
% Optional: overwrite machine name
if nargin > 4
    tmp_data.Header = sub_update_header(tmp_data.Header, machine);
end
    
% Optional: overwrite FMS
if nargin > 5
    tmp_data.FineMetrologyOverlayState = fms.FineMetrologyOverlayState.CalibrationState.Value;
end

schema_info = 'xsi:schemaLocation="http://www.asml.com/XMLSchema/MT/Generic/ADELsbcOverlayDriftControlNxe/vx.x ADELsbcOverlayDriftControlNxe.xsd" xmlns:ns0="http://www.asml.com/XMLSchema/MT/Generic/ADELsbcOverlayDriftControlNxe/vx.x" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"';
schema_info = strrep(schema_info, 'vx.x', xml_data.Header.VersionId);
bmmo_xml_save(outfile, tmp_data, 'ns0:Recipe', schema_info);

function tmp_data = sub_bmmo_inject_inline_sdm_into_ADEL_xml(tmp_data, inline_sdm)
MAX_CHUCK_NR = 2;
sbc_chuck_order = arrayfun(@(x) str2double(x.elt.ApplicationRange.Exposure.Wafer.WaferStageChuckId(end)), tmp_data.CorrectionSets);

for ic = 1:MAX_CHUCK_NR
    chuck_id = sbc_chuck_order(ic);
    if isfield(inline_sdm, 'time_filter')
        tmp_data.CorrectionSets(chuck_id).elt.Parameters.SdmDistortionMap.Header.TimeFilter = sprintf('%.4f', inline_sdm.time_filter);
    end
    if isfield(inline_sdm, 'sdm_model')
        tmp_data.CorrectionSets(chuck_id).elt.Parameters.SdmDistortionMap.Header.SdmModel = inline_sdm.sdm_model;
    end
end


function header_out = sub_update_header(header_in, machine_id)

header_out = header_in;

dateformat = 'YYYY-mm-DDTHH:MM:SS';
doctime = now;
header_out.CreateTime = datestr(doctime, dateformat);
header_out.LastModifiedTime = datestr(doctime, dateformat);
header_out.MachineName = num2str(machine_id);

docid_dateformat = 'YYYYmmDD_HHMM';
doc_timestr = datestr(doctime, docid_dateformat);

header_out.DocumentId = ['ADELsbc2-' num2str(machine_id) '-' doc_timestr];
