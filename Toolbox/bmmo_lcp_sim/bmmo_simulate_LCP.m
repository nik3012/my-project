function [sbc_new, ml_in, out] = bmmo_simulate_LCP(KT_wo, adelsbcrep, adeller, timefilter)
% function [sbc_new, ml_in] = bmmo_simulate_LCP(KT_wo, adelsbcrep, adeller)
%
% Given KT wafers out, SBC report and ADELler, simulate LCP control loop
% (no WH)
%
% Input:
%   KT_wo: KT_wafers_out from KT Devbench Monitor Lot
%   adelsbcrep: full path of ADELsbcOverlayDriftControlNxerep from same lot
%   adeller: full path of ADELler from same lot
%
% Optional Input:
%   timefilter: (0/1) flag to specify if time filter is enabled (default 0)
%       0 means Recover to Baseline
%       1 means Control to Baseline
%
% Output:  
%   sbc_new: SBC correction returned by offline model
%   ml_in: BMMO-NXE model input read from input data
%   out: BMMO-NXE model output
%
% 201701 SBPR Creation

% read adeller to get expinfo (containing only xc, yc field centres)

ml_in = bmmo_input_struct_from_devbench(KT_wo, adelsbcrep, adeller, timefilter);

out = bmmo_nxe_drift_control_model(ml_in);
 
sbc_new = out.corr;

% % Invert to compare with actuated correction
% sbc_inv = sbc;
% for ic = 1:2
%     sbc_inv.MI.wse(ic).x_mirr.dx = -1 * sbc_inv.MI.wse(ic).x_mirr.dx;
%     sbc_inv.MI.wse(ic).y_mirr.dy = -1 * sbc_inv.MI.wse(ic).y_mirr.dy;
% end



