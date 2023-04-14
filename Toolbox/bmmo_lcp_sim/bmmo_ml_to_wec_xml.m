function wec = bmmo_ml_to_wec_xml(ml, filename, wid, target)
% function bmmo_ml_to_wec_xml(ml, filename)
%
% Convert the input single-wafer ml structure to a wec structure and then write to an
% ADELwaferErrorCorrection.xml file of the given version
%
% Input
%   ml:     overlay structure
%   filename: path to write to
%   wid: string containing the wafer id
%
% Output
%   wec: struct describing wec data, in same format as xml_load output
%
% 20160607 SBPR Creation

version = 1.4;

xmlroot = 'ADELwaferErrorCorrection:Report';
xmlattrib = 'xsi:schemaLocation="http://www.asml.com/XMLSchema/MT/Generic/ADELwaferErrorCorrection/v1.4 ADELwaferErrorCorrection.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ADELwaferErrorCorrection="http://www.asml.com/XMLSchema/MT/Generic/ADELwaferErrorCorrection/v1.4"';

wec.Header = sub_get_wec_header(wid, target, version);
wec.ErrorCorrectionData = sub_get_err_struct(ml, wid, target, version);

% update the wid

bmmo_xml_save(filename, wec, xmlroot, xmlattrib);

function err = sub_get_err_struct(ml, wid, target, version)

err.WaferId = wid;
if version == 1.4
    err.WaferVersion = 'V4';
end
err.ToolType = 'Yieldstar';
err.WecQuality = 'Silver';
err.TargetLabel = target;
err.TargetList = bmmo_get_wec_data(ml);



function header = sub_get_wec_header(wid, target, version)

dateformat = 'YYYY-mm-DDTHH:MM:SS';

header.Title = 'ADELwaferErrorCorrection BMMO wafers';
header.MachineID = '0000';
header.MachineCustomerName = '';
header.MachineType = 'Proto tool';
header.SoftwareRelease = 'SoftwareRelease0';
header.CreatedBy = 'BMMO_WEC_Proto';
doctime = now;
header.CreateTime = datestr(doctime, dateformat);
header.MachineHostDeltaTime = '0';

docid_dateformat = 'YYYYmmDD_HHMM';
doc_timestr = datestr(doctime, docid_dateformat);
versionidstr = sprintf('v%d_%d', floor(version), round(mod(version,1) * 10));
versionstr = sprintf('v%g', version);

docid = sprintf('WEC_%s_%s_%s_%s', wid, target, doc_timestr, versionidstr);
header.DocumentId = docid;
header.DocumentType = 'ADELwaferErrorCorrection';
header.DocumentTypeVersion = versionstr;
header.CategoryList = '';

