function ml = bmmo_kt_process_adelwhc_input(mli, adelwhc, widmapping)
% function ml = bmmo_kt_process_adelwhc_input(mli, adelwhc)
%
% Given an ml structure, return the structure with added fields parsed from
% the given ADELwaferHeatingCorrectionsReport, as required by the BMMO-NXE drift control model
%
% Input
%   mli: standard input structure 
%   adelwhc: full path of ADELwaferHeatingCorrectionsReport xml file
%
% Output
%   ml: input structure with added fields
%       ml.info.report_data.WH_K_factors
%       ml.info.report_data.IR2EUVsensitivity
%       ml.info.report_data.Rir2EUV
%       ml.info.report_data.r;
%       ml.info.report_data.t;
%       ml.info.report_data.Pdgl;
%       ml.info.report_data.SLIP;
%       ml.info.report_data.tret;
%
% 20160412 SBPR Creation
% 20200512 SELR Fix for 2L expose and 1L readout

NM = 1e-9;
PPM = 1e-6;
URAD = 1e-6;
NM_CM2 = 1e-5;
NM_CM3 = 1e-3;
options = bmmo_default_options_structure;

ml = mli;

if nargin < 3
    widmapping = 1:mli.nwafer;
end

% Read adel whc
whc = xml_load(adelwhc);

% Read K-factors
wafer_results = [whc.Results.WaferResultsList.elt];
wafer_results = wafer_results(widmapping);

totalsensitivity = 0;

if isfield(mli, 'raw')
    nfield = mli.raw.nfield;
else
    nfield = mli.nfield;
end

mean_slip_pw = ones(1, mli.nwafer);

for iw = 1:mli.nwafer
   field_results = [wafer_results(iw).ImageResultsList.elt.ExposureResultList.elt];
   exposed_fields = length(field_results);
   % Load correct fields in case of 2L exp and 1L readout
   if  exposed_fields > nfield
       field_selection = [options.layer_fields{1} options.edge_fields];
   else
       field_selection = 1:nfield;
   end
   
   mean_slip_pw(iw) = mean(str2double({field_results.SLIP}));
   
   % make sure the fields are sorted by exposuresequence number
   exp_seq = str2double({field_results.ExposureSequenceNumber});
   [~, sortid] = sort(exp_seq);
   field_results = field_results(sortid);
   
   for ifield = 1:nfield
       linear = field_results(field_selection(ifield)).WaferHeatingCorrections.OverlayParameters.LinearIntraFieldCorrections;
       hoc = field_results(field_selection(ifield)).WaferHeatingCorrections.OverlayParameters.HigherOrderIntraFieldCorrections;
       
       kfactors.K1  = str2double(linear.Translation.X) * NM; 
       kfactors.K2  = str2double(linear.Translation.Y) * NM;
       kfactors.ms  = str2double(linear.Magnification) * PPM;
       kfactors.ma  = str2double(linear.AsymMagnification) * PPM;
       kfactors.rs  = str2double(linear.Rotation) * URAD;
       kfactors.ra  = str2double(linear.AsymRotation) * URAD;
       
       kfactors.K7  = str2double(hoc.SecondOrderMagnification.X) * NM_CM2;
       kfactors.K8  = str2double(hoc.SecondOrderMagnification.Y) * NM_CM2;    
       kfactors.K9  = str2double(hoc.Trapezoid.X) * NM_CM2;
       kfactors.K10 = str2double(hoc.Trapezoid.Y) * NM_CM2;
       kfactors.K11 = str2double(hoc.Bow.X) * NM_CM2;
       kfactors.K12 = str2double(hoc.Bow.Y) * NM_CM2;
       
       kfactors.K14 = str2double(hoc.ThirdOrderMagnification.Y) * NM_CM3;
       kfactors.K15 = str2double(hoc.Accordion.X) * NM_CM3;
       kfactors.K16 = str2double(hoc.Accordion.Y) * NM_CM3;
       kfactors.K17 = str2double(hoc.CShapeDistortion.X) * NM_CM3;
       kfactors.K18 = str2double(hoc.CShapeDistortion.Y) * NM_CM3;
       kfactors.K19 = str2double(hoc.ThirdOrderFlow.X) * NM_CM3;
       
       ml.info.report_data.WH_K_factors.wafer(iw).field(ifield) = kfactors;
   end
   assertEqual(length(ml.info.report_data.WH_K_factors.wafer(iw).field), nfield)
   
   if isfield(wafer_results(iw).ImageResultsList.elt,'IR2EUVRatioScalingSensitivity') 
      totalsensitivity = totalsensitivity + str2double(wafer_results(iw).ImageResultsList.elt.IR2EUVRatioScalingSensitivity);
   end
end

ml.info.report_data.IR2EUVsensitivity = totalsensitivity / ml.nwafer;
ml.info.report_data.Rir2euv = str2double(whc.Input.LotSettings.WaferHeatingCorrections.IR2EUVRatio);
ml.info.report_data.r =  str2double(whc.Input.LotSettings.WaferHeatingCorrections.WaferIRReflectance);
ml.info.report_data.t =  str2double(whc.Input.LotSettings.WaferHeatingCorrections.WaferIRTransmittance);
ml.info.report_data.Pdgl = str2double(whc.Input.LotSettings.WaferHeatingCorrections.DGLPower);
ml.info.report_data.SLIP = mean(mean_slip_pw);
