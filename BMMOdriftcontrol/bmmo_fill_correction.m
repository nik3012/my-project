function corr = bmmo_fill_correction(corr, intermediate_results, options)
% function corr = bmmo_fill_correction(corr, intermediate_results, options)
%
% Fill in a BMMO/BL3 correction structure from the intermediate model
% results
%
% Input:
%   corr: BMMO/BL3 correction structure as defined in
%       bmmo_default_output_structure (out.corr)
%   intermediate_results: BMMO/BL3 model results as defined in
%       bmmo_default_model_result
%   options: BMMO/BL3 options structure
%
% Output:   
%   corr: correction structure with intermediate results filled in

corr.IR2EUV              = intermediate_results.WH.Calib_WH;

for ichuck = options.chuck_usage.chuck_id_used % intermediate results filled per existing chuck
    corr.KA.grid_2de(ichuck).dx   = reshape(intermediate_results.KA.Calib_KA(ichuck).dx, [], 1);
    corr.KA.grid_2de(ichuck).dy   = reshape(intermediate_results.KA.Calib_KA(ichuck).dy, [], 1);
    
    corr.KA.grid_2de(ichuck).interpolant_x = intermediate_results.KA.Calib_KA(ichuck).interpolant_x;
    corr.KA.grid_2de(ichuck).interpolant_y = intermediate_results.KA.Calib_KA(ichuck).interpolant_y;
	
	corr.KA.grid_2dc(ichuck).dx   = reshape(intermediate_results.KA.Calib_KA_meas(ichuck).dx, [], 1);
    corr.KA.grid_2dc(ichuck).dy   = reshape(intermediate_results.KA.Calib_KA_meas(ichuck).dy, [], 1);
	
	corr.KA.grid_2dc(ichuck).interpolant_x = intermediate_results.KA.Calib_KA_meas(ichuck).interpolant_x;
    corr.KA.grid_2dc(ichuck).interpolant_y = intermediate_results.KA.Calib_KA_meas(ichuck).interpolant_y;
    
    corr.BAO(ichuck)              = bmmo_10par_to_BAO(intermediate_results.BAO.correction(ichuck));
    
    corr.ffp(ichuck).dx           = intermediate_results.INTRAF.Calib_intra(ichuck).layer.wr.dx;
    corr.ffp(ichuck).dy           = intermediate_results.INTRAF.Calib_intra(ichuck).layer.wr.dy;
    
    corr.MI.wse(ichuck).x_mirr.dx = intermediate_results.MI.Calib_MI(ichuck).x_mirr.dx;
    corr.MI.wse(ichuck).y_mirr.dy = intermediate_results.MI.Calib_MI(ichuck).y_mirr.dy;
    
    corr.MI.wsm(ichuck).x_mirr.dx = intermediate_results.MI.Calib_MI_wsm(ichuck).x_mirr.dx;
    corr.MI.wsm(ichuck).y_mirr.dy = intermediate_results.MI.Calib_MI_wsm(ichuck).y_mirr.dy;
      
end 

if options.susd_control
    IFO_chuck_index = [1 1 2 2];
    for icorr_IFO = 1:length(options.IFO_scan_direction)
        corr.SUSD(icorr_IFO).TranslationY = options.IFO_scan_direction(icorr_IFO)*intermediate_results.SUSD.Calib_SUSD(IFO_chuck_index(icorr_IFO));
    end
end