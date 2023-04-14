function wmap = bmmo_create_adel_wafermap(adeller, wafers, wids, fname)

dateformat = 'YYYY-mm-DDTHH:MM:SS';
doctime = now;


wmap.Header.Title = 'Wafer Mapping';
wmap.Header.MachineCustomerName = 'AT';
wmap.Header.SoftwareRelease = 'at7.3';
wmap.Header.CreatedBy = 'Test';
wmap.Header.CreateTime = datestr(doctime, dateformat);
wmap.Header.DocumentId = ['ADELwaferMapping' wmap.Header.CreateTime];
wmap.Header.DocumentType = 'ADELwaferMapping';
wmap.Header.DocumentTypeVersion =  'v1.1';

aler = xml_load(adeller);

wmap.Results.LotIdentification.EquipmentId = aler.Header.MachineID;
wmap.Results.LotIdentification.LotId = aler.Input.LotId;
wmap.Results.LotIdentification.LotStart = aler.Conditions.LotStart;

nwafer = length(wafers);
for ii = 1:nwafer
    wmap.Results.WaferList(ii).elt.WaferId = aler.Results.WaferResultList(wafers(ii)).elt.WaferId;
    wmap.Results.WaferList(ii).elt.SubstrateWaferId = wids{ii};
end

root = 'ADELwaferMapping:Report';
root_attrib = 'xmlns:ADELwaferMapping="http://www.asml.com/XMLSchema/MT/Generic/ADELwaferMapping/v1.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.asml.com/XMLSchema/MT/Generic/ADELwaferMapping/v1.0 file:/C:/Localdata/TOP-MMO%20Stability/schema%27s/ADELwaferMapping.xsd"';

bmmo_xml_save(fname, wmap, root, root_attrib);
