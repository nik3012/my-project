function ml = bmmo_read_idatsbcovldcnxekacorrections(idat_filepath, ml_cet, translation)
%function ml = bmmo_read_idatsbcovldcnxekacorrections(idat_filepath, ml_cet, translation)

% Given the file path for IDATsbcOvldcNxeKaCorrectionsReport(Protected), the
% function decryptes and parses to output KA corrections provided.
%
% Input
%   idat_filepath         : IDATsbcOvldcNxeKaCorrectionsReport(Protected)
%   ml_cet                : full CET NCE in ml structure
%   translation [OPTIONAL]: Translation (m), only required for WSCS based IDAT reports
% Output:
%   ml                    : KA corrections provided to CET in ml struct

% Load the IDAT report
xmlData = bmmo_load_ADEL(idat_filepath);

% Determine the coordinate type reported in the IDAT
if isfield(xmlData.Results.WaferResultList(1).elt.ImageResultList.elt.ExposureResultList(1).elt, 'NominalGridPointPositionListFCS')
    NominalGridPointPositionList = 'NominalGridPointPositionListFCS';
elseif isfield(xmlData.Results.WaferResultList(1).elt.ImageResultList.elt.ExposureResultList(1).elt, 'NominalGridPointPositionListWSCS')
    NominalGridPointPositionList = 'NominalGridPointPositionListWSCS';
else
    error('The coordinate type specified in the IDAT report is not recognized');
end

% Populate the metadata
ml.nmark   = length(xmlData.Results.WaferResultList(1).elt.ImageResultList.elt.ExposureResultList(1).elt.(NominalGridPointPositionList));
ml.nfield  = length(xmlData.Results.WaferResultList(1).elt.ImageResultList.elt.ExposureResultList);
ml.nlayer  = 1;
ml.nwafer  = length(xmlData.Results.WaferResultList);
ml.tlgname = [xmlData.DocumentMetaData.LotId, '_KA_corrections_provided'];

% Build the coordinates array
coordinates = zeros(ml.nmark, 2);
for field = 1 : ml.nfield
    sliceStart                              = (field - 1) * ml.nmark + 1;
    sliceEnd                                = sliceStart + ml.nmark - 1;
    coordinates((sliceStart : sliceEnd), :) = getGridPointData(xmlData.Results.WaferResultList(1).elt.ImageResultList.elt.ExposureResultList(field).elt.(NominalGridPointPositionList), 1e-3);
end

% Populate the wafer definition
if strcmp(NominalGridPointPositionList, 'NominalGridPointPositionListWSCS')
    if ~exist('translation', 'var')
        warning('Translation has not been provided, using WCS from ml_cet instead of WSCS from IDAT report. This can cause numerical differences.');
        ml.wd = ml_cet.wd;
    else
        ml.wd.xf = ml_cet.wd.xf;
        ml.wd.yf = ml_cet.wd.yf;
        ml.wd.xw = round(coordinates(:, 1) - translation(1), 12);
        ml.wd.yw = round(coordinates(:, 2) - translation(2), 12);
    end
else
    ml.wd.xf = round(coordinates(:, 1), 12);
    ml.wd.yf = round(coordinates(:, 2), 12);
    ml.wd.xw = ml_cet.wd.xw;
    ml.wd.yw = ml_cet.wd.yw;
end
ml.wd.xc = ml.wd.xw - ml.wd.xf;
ml.wd.yc = ml.wd.yw - ml.wd.yf;

% Ensure that xw, yw are as expected
bmmo_assert_equal(ml.wd.xw, ml_cet.wd.xw, 1e-9);
bmmo_assert_equal(ml.wd.yw, ml_cet.wd.yw, 1e-9);

% Build dx and dy
for wafer = 1 : ml.nwafer
    d = zeros(ml.nmark, 2);
    for field = 1 : ml.nfield
        sliceStart = (field - 1) * ml.nmark + 1;
        sliceEnd   = sliceStart + ml.nmark - 1;
        d((sliceStart:sliceEnd), :) = getGridPointData(xmlData.Results.WaferResultList(wafer).elt.ImageResultList.elt.ExposureResultList(field).elt.CorrectionList, 1e-9);
    end
    ml.layer.wr(wafer).dx = round(d(:, 1), 12);
    ml.layer.wr(wafer).dy = round(d(:, 2), 12);
end

function [ data ] = getGridPointData( dataList, scaleFactor )
    data = [ arrayfun(@(x) sscanf(x.elt.X, '%f', 1) * scaleFactor, dataList)', arrayfun(@(x) sscanf(x.elt.Y, '%f', 1) * scaleFactor, dataList)' ];
end

end