function [res, sbc, kpi] = bmmo_model(ml)
% function [res, sbc, kpi] = bmmo_model(ml)
%
% Perform BMMO-NXE modelling on arbitrary input, with the same output
% order as ovl_model
%
% Note: if ml is not a valid BMMO-NXE input, it will be converted assuming
% a default chuck order (alternating chucks beginning with 1) and zero WH
% fingerprint
%
% Input:
%   ml: arbitrary overlay structure
%
% Output:
%   res: residual after applying modelled SBC2 (self-correction)
%   sbc: modelled SBC2
%   kpi: KPI from modelling
%
% 20171130 SBPR Creation

mlt = ml;
try
    [mlp, options] = bmmo_process_input(mlt);
    bmmo_input =1;
catch
    warning('Invalid BMMO-NXE model input: using default chuck order and zero WH fingerprint');
    mlt = bmmo_convert_generic_ml(ml);
    [mlp, options] = bmmo_process_input(mlt);
end

model_results = bmmo_run_submodels(mlp, options);
output_struct = bmmo_process_output(mlt, model_results, options);

sbc = output_struct.corr;
kpi = output_struct.report.KPI;

if bmmo_input
    fps = bmmo_apply_SBC(mlt, sbc);
else
    fps = bmmo_apply_SBC_to_ml(mlt, sbc);
end

res = ovl_add(mlp, fps.TotalSBCcorrection);
