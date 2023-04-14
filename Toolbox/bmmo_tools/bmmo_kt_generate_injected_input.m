function mlo = bmmo_kt_generate_injected_input(mli)
% function mlo = bmmo_kt_generate_injected_input(mli)
%
% Given an input ml structure (valid input for BMMO-NXE model
% and the injected_MC structure, build an ml structure with the injected
% data
%
% Input
%   mli: valid input for BMMO-NXE model
%
% Output
%   mlo: overlay structure with complete drift
%
% 20160419 SBPR Creation

mcpath = '\\asml.com\eu\shared\nl011052\BMMO_NXE_TS\03-Integration\302-Integration_Milestones\BMMO_Functional_Integration\KT_testing\KT_Injected_MC.mat';

mci = load(mcpath);

mcs = mci.Injected_MC;

corr = bmmo_translate_injected_MCs(mcs);

out = bmmo_kt_apply_SBC(mli, corr);

mlo = out.TotalSBCcorrection;
