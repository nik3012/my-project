function corr = bmmo_apply_time_filter(corr, filter_coefficients, scaling_factor)
% function corr = bmmo_apply_time_filter(corr, filter_coefficients, scaling_factor)
%
% Multiply a SBC correction structure by the time filtering constants
% in options, and optionally also by the given constant scaling factor
%
% Input:
%   corr: BMMO/BL3 correction structure as defined in
%       bmmo_default_output_structure (out.corr)
%   filter_coefficients: Value of time filter coefficients as defined in
%       default BMMO/Bl3 option structure
%
% Optional Input:
%   scaling_factor: scalar value
%
% Output:
%   corr: input correction with time filtering constants and scaling
%   applied

if nargin < 3
    scaling_factor = 1;
end
options = bmmo_default_options_structure;

corr.IR2EUV              = corr.IR2EUV * (scaling_factor * filter_coefficients.WH);
baonames                 = fieldnames(corr.BAO(1));
susdnames                = fieldnames(corr.SUSD(1));
baoscaling = scaling_factor * filter_coefficients.BAO;

for ichuck = 1:2
    corr.KA.grid_2de(ichuck).dx   = corr.KA.grid_2de(ichuck).dx * (scaling_factor * filter_coefficients.KA);
    corr.KA.grid_2de(ichuck).dy   = corr.KA.grid_2de(ichuck).dy * (scaling_factor * filter_coefficients.KA);
    
    corr.KA.grid_2dc(ichuck).dx   = corr.KA.grid_2dc(ichuck).dx * (scaling_factor * filter_coefficients.KA);
    corr.KA.grid_2dc(ichuck).dy   = corr.KA.grid_2dc(ichuck).dy * (scaling_factor * filter_coefficients.KA);
    
    for ibao = 1:length(baonames)
        corr.BAO(ichuck).(baonames{ibao}) = corr.BAO(ichuck).(baonames{ibao}) * baoscaling;
    end
    
    corr.ffp(ichuck).dx           = corr.ffp(ichuck).dx * (scaling_factor * filter_coefficients.INTRAF);
    corr.ffp(ichuck).dy           = corr.ffp(ichuck).dy * (scaling_factor * filter_coefficients.INTRAF);
    
    corr.MI.wse(ichuck).x_mirr.dx = corr.MI.wse(ichuck).x_mirr.dx * (scaling_factor * filter_coefficients.MI);
    corr.MI.wse(ichuck).y_mirr.dy = corr.MI.wse(ichuck).y_mirr.dy * (scaling_factor * filter_coefficients.MI);
    
    corr.MI.wsm(ichuck).x_mirr.dx = corr.MI.wsm(ichuck).x_mirr.dx * (scaling_factor * filter_coefficients.MI);
    corr.MI.wsm(ichuck).y_mirr.dy = corr.MI.wsm(ichuck).y_mirr.dy * (scaling_factor * filter_coefficients.MI);
end

for icorr_IFO = 1:length(options.IFO_scan_direction)
    for isusd = 1:length(susdnames)
        corr.SUSD(icorr_IFO).(susdnames{isusd}) = corr.SUSD(icorr_IFO).(susdnames{isusd}) * (scaling_factor * filter_coefficients.SUSD);
    end
end