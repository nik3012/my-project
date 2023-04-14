function ffp = bmmo_kt_get_injected_INTRAF(driftpath)
% function ffp = bmmo_kt_get_injected_INTRAF(driftpath)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%

ffp(1) = struct;
ffp(2) = struct;
load([driftpath filesep 'simulated_ml_BAO_SDM.mat']);

for ic = 1:2
    ffp(ic).x = simulated_ml_BAO_SDM.sdm{ic}.wd.xf;
    ffp(ic).y = simulated_ml_BAO_SDM.sdm{ic}.wd.yf;
    ffp(ic).dx = simulated_ml_BAO_SDM.sdm{ic}.layer(1).wr(1).dx;
    ffp(ic).dy = simulated_ml_BAO_SDM.sdm{ic}.layer(1).wr(1).dy;
end