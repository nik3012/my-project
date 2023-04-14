function corr = bmmo_add_output_corr(corr1, corr2)
% function out = bmmo_add_output_corr(out1, out2)
% 
% This function adds two SBC corrections together(BMMO/BL3).
%
% Input:
%   corr1, corr2: BMMO/BL3 SBC correction structures as defined in
%       bmmo_default_output_structure, out.corr
% 
% Output:
%   corr: sum of the two SBC correction structures

corr = corr1;
options = bmmo_default_options_structure;

baofields = fieldnames(corr.BAO(1));
susdfields = {'TranslationY'};

corr.IR2EUV  = corr.IR2EUV + corr2.IR2EUV;

for ic = 1:2
    corr.MI.wse(ic).x_mirr.dx = corr.MI.wse(ic).x_mirr.dx + corr2.MI.wse(ic).x_mirr.dx;
    corr.MI.wse(ic).y_mirr.dy = corr.MI.wse(ic).y_mirr.dy + corr2.MI.wse(ic).y_mirr.dy;
    corr.MI.wsm(ic).x_mirr.dx = corr.MI.wsm(ic).x_mirr.dx + corr2.MI.wsm(ic).x_mirr.dx;
    corr.MI.wsm(ic).y_mirr.dy = corr.MI.wsm(ic).y_mirr.dy + corr2.MI.wsm(ic).y_mirr.dy;
    
    corr.KA.grid_2de(ic).dx = corr.KA.grid_2de(ic).dx + corr2.KA.grid_2de(ic).dx;
    corr.KA.grid_2de(ic).dy = corr.KA.grid_2de(ic).dy + corr2.KA.grid_2de(ic).dy;
    
    corr.KA.grid_2dc(ic).dx = corr.KA.grid_2dc(ic).dx + corr2.KA.grid_2dc(ic).dx;
    corr.KA.grid_2dc(ic).dy = corr.KA.grid_2dc(ic).dy + corr2.KA.grid_2dc(ic).dy;
    
    corr.ffp(ic).dx = corr.ffp(ic).dx + corr2.ffp(ic).dx;        
    corr.ffp(ic).dy = corr.ffp(ic).dy + corr2.ffp(ic).dy;

    for ibao = 1:length(baofields)
        corr.BAO(ic).(baofields{ibao}) = corr.BAO(ic).(baofields{ibao}) + corr2.BAO(ic).(baofields{ibao});
    end
end

for icorr_IFO = 1:length(options.IFO_scan_direction)
    for isusd = 1:length(susdfields)
        corr.SUSD(icorr_IFO).(susdfields{isusd}) = corr.SUSD(icorr_IFO).(susdfields{isusd}) + corr2.SUSD(icorr_IFO).(susdfields{isusd});
    end
end
