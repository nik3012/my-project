function [out, wdms] = bmmo_nxe_drift_control_model(mli)
% function [out, wdms] = bmmo_nxe_drift_control_model(mli)
%
% This function is the main function for NXE BMMO and BL3 drift control model.
%
% This model is intended to support BMMO NXE drift control for NXE3350B and
% NXE3400 as well as BL3 drift control for NXE 3400 and NXE3600
%
% Input:
% mli:  YieldStar measurement translated by Java SW layer. mli also
% includes additional scanner data that is needed during modeling
%
% Output:
% out:  Modeled SBC2 correction parameters and KPI parameters
% wdms: waferdatamaps containing measurement data, correction sets, residuals etc
%
% For details of the model and definitions of in/out interfaces, refer to
% D000323756 EDS BMMO NXE drift control model - BMMO NXE in OTAS
% D000810611 EDS BMMO NXE_drift control model functional - BMMO NXE and BL3
% in LIS

[ml, options] = bmmo_process_input(mli);

% Run the submodels in the sequence specified in options.submodel_sequence
model_results = bmmo_run_submodels(ml, options);

if nargout < 2
    out = bmmo_process_output(mli, model_results, options);
else
    [out, wdms] = bmmo_process_output(mli, model_results, options);
end