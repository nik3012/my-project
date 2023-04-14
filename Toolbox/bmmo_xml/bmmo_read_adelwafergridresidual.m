function [ml_KA_cet_corr, ml_KA_cet_nce, xml_data, KA_actuation] = bmmo_read_adelwafergridresidual(adel_filepath, ml_cet)
%function [ml_KA_cet_corr, ml_KA_cet_nce, xml_data, KA_actuation] = bmmo_read_adelwafergridresidual(adel_filepath, ml_cet)

% Given the file path for ADELwaferGridResidualReportProtected, the
% function decryptes and parses to output KA requested correction & KA CET NCE.
%
% Input
%   adel_filepath: ADELwaferGridResidualReportProtected path
%   ml_cet   : ful CET NCE in ml structure
% Output:
%   ml_KA_cet_corr: KA correction requested to CET in ml struct
%   ml_KA_cet_nce : KA CET NCE in ml struct
%   xml_data     : decrypted ADEL in xml_load format
%   KA_actuation  : Shows which type of actuation (higher/lower order).

%load in the residual report
xml_data = bmmo_load_ADEL(adel_filepath);
   
ROUNDING_SF = 12;
%
% build xc, yc
xc = str2double(arrayfun(@(x) (x.elt.FieldPosition.X), xml_data.Results.WaferResultList(1).elt.ImageResultList(1).elt.ExposureResultList, 'UniformOutput', false)) * 1e-3;
yc = str2double(arrayfun(@(x) (x.elt.FieldPosition.Y), xml_data.Results.WaferResultList(1).elt.ImageResultList(1).elt.ExposureResultList, 'UniformOutput', false)) * 1e-3;

full_grid_size = numel(xml_data.Results.WaferResultList(1).elt.ImageResultList.elt.ExposureResultList(1).elt.SbcResiduals.Corrections);
number_of_exposures = numel(xml_data.Results.WaferResultList(1).elt.ImageResultList.elt.ExposureResultList);

% build the base ml structure
ml.wd.xf = ml_cet.wd.xf;
ml.wd.yf = ml_cet.wd.yf;
ml.wd.xc = round(reshape(repmat(xc, full_grid_size,1), [], 1), ROUNDING_SF);
ml.wd.yc = round(reshape(repmat(yc, full_grid_size,1), [], 1), ROUNDING_SF);
ml.wd.xw = ml.wd.xf + ml.wd.xc;
ml.wd.yw = ml.wd.yf + ml.wd.yc;

%make sure xw, yw are same
if ~isequal(ml.wd.xw, ml_cet.wd.xw) || ~isequal(ml.wd.yw, ml_cet.wd.yw)
    error('Error parsing: ADELexposeTrajectoriesReport and ADELwaferGridResidualReport have different wafer coordinates (xw,yw)');
end
ml.nmark = full_grid_size;
ml.nfield = number_of_exposures;
ml.nlayer = 1;
ml.nwafer = numel(xml_data.Results.WaferResultList);

wr.dx = [];
wr.dy = [];
ml.layer.wr = repmat(wr, 1, ml.nwafer);

% copy the base ml struct for KA correction & residual
ml_KA_cet_corr = ml;
ml_KA_cet_corr.tlgname = 'KA CET corrections';

ml_KA_cet_nce  = ml;
ml_KA_cet_nce.tlgname = 'KA CET residuals';


for iw = 1:ml.nwafer
    for i_exp = 1:number_of_exposures
        % map the residuals and corrections of each field to ml struct
        corr_dx_field = str2double(arrayfun(@(x) (x.elt.Dx), xml_data.Results.WaferResultList(iw).elt.ImageResultList(1).elt.ExposureResultList(i_exp).elt.SbcResiduals.Corrections, 'UniformOutput', false)) * 1e-9;
        corr_dy_field = str2double(arrayfun(@(x) (x.elt.Dy), xml_data.Results.WaferResultList(iw).elt.ImageResultList(1).elt.ExposureResultList(i_exp).elt.SbcResiduals.Corrections, 'UniformOutput', false)) * 1e-9;
        nce_dx_field  = str2double(arrayfun(@(x) (x.elt.Dx), xml_data.Results.WaferResultList(iw).elt.ImageResultList(1).elt.ExposureResultList(i_exp).elt.SbcResiduals.Residuals, 'UniformOutput', false)) * 1e-9;
        nce_dy_field  = str2double(arrayfun(@(x) (x.elt.Dy), xml_data.Results.WaferResultList(iw).elt.ImageResultList(1).elt.ExposureResultList(i_exp).elt.SbcResiduals.Residuals, 'UniformOutput', false)) * 1e-9;
        
        ml_KA_cet_corr.layer.wr(iw).dx  = [ml_KA_cet_corr.layer.wr(iw).dx ; corr_dx_field(:)];
        ml_KA_cet_corr.layer.wr(iw).dy  = [ml_KA_cet_corr.layer.wr(iw).dy ; corr_dy_field(:)];
        
        ml_KA_cet_nce.layer.wr(iw).dx   = [ml_KA_cet_nce.layer.wr(iw).dx ; nce_dx_field(:)];
        ml_KA_cet_nce.layer.wr(iw).dy   = [ml_KA_cet_nce.layer.wr(iw).dy ; nce_dy_field(:)];
    end
end


if isfield(xml_data.Results, 'ReportedSbcResiduals')
    if strcmp(xml_data.Results.ReportedSbcResiduals, 'Higher Order KA Actuation')
        KA_actuation = 'HOC';
    elseif  strcmp(xml_data.Results.ReportedSbcResiduals, 'Lower Order KA Actuation')
        KA_actuation = 'LOC';
    else
        KA_actuation = [];
    end
else
    KA_actuation = [];
end



