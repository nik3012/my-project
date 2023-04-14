function [corr] = bmmo_kt_get_injected_corr(driftpath)
% function [corr] = bmmo_kt_get_injected_corr(driftpath)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%

if nargin < 1
    driftpath = 'Z:\shared\nl011052\BMMO_NXE_TS\03-Integration\302-Integration_Milestones\BMMO_extention_SUSD_KA\Set_get\Drift_injection';
end

out = bmmo_default_output_structure(bmmo_default_options_structure);
corr = out.corr;
%corr.MI = bmmo_kt_get_injected_MI(driftpath);
corr.KA.grid_2de = bmmo_kt_get_injected_KA(driftpath);
corr.SUSD = bmmo_kt_get_injected_SUSD(driftpath);
%corr.BAO = bmmo_kt_get_injected_BAO(driftpath);
%corr.ffp = bmmo_kt_get_injected_INTRAF(driftpath);
