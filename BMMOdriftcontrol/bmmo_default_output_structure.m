function out = bmmo_default_output_structure(options)
% function out = bmmo_default_output_structure(options)
%
% Default output structure for the BMMO-NXE/BL3 drift control model
%
% Input: 
% options:  options structure as defined in bmmo_default_options_structure
%           or bl3_default_options_structure to obtain bl3_default_output_structure
%
% Output: 
% out:      initialized output structure
%
% For details of the model and definitions of in/out interfaces, refer to
% D000810611 EDS BMMO NXE drift control model
 
parmc = ovl_metro_par_mc('KA_pitch',options.KA_pitch,'KA_bound',abs(options.KA_start),'KA_radius',abs(options.KA_start));
parmc_meas = ovl_metro_par_mc('KA_pitch',options.KA_pitch,'KA_bound',abs(options.KA_meas_start),'KA_radius',abs(options.KA_meas_start));

dummy_wafer = ovl_create_dummy('marklayout',options.intrafield_reticle_layout);
dummy_field = ovl_get_fields(dummy_wafer,1);
out.corr.IR2EUV                     = 0;
out.corr.MI                         = parmc.MI.raw;
for ic = 1:2
    out.corr.MI.wse(ic).x_mirr = rmfield(out.corr.MI.wse(ic).x_mirr, 'dx_drift');
    out.corr.MI.wse(ic).y_mirr = rmfield(out.corr.MI.wse(ic).y_mirr, 'dy_drift');
    out.corr.MI.wsm(ic).x_mirr = rmfield(out.corr.MI.wsm(ic).x_mirr, 'dx_drift');
    out.corr.MI.wsm(ic).y_mirr = rmfield(out.corr.MI.wsm(ic).y_mirr, 'dy_drift');
end
for ic=1:2
    parmc.KA.raw.grid_2de(ic).dx = parmc.KA.raw.grid_2de(ic).dx;
    parmc.KA.raw.grid_2de(ic).dy = parmc.KA.raw.grid_2de(ic).dy;
    parmc_meas.KA.raw.grid_2dc(ic).dx = parmc_meas.KA.raw.grid_2dc(ic).dx;
    parmc_meas.KA.raw.grid_2dc(ic).dy = parmc_meas.KA.raw.grid_2dc(ic).dy;
end
out.corr.KA.grid_2de                = parmc.KA.raw.grid_2de;
out.corr.KA.grid_2dc                = parmc_meas.KA.raw.grid_2dc;
out.corr.BAO(1)                     = struct('TranslationX',0,'TranslationY',0,'Magnification',0,'AsymMagnification',0,...
                                         'Rotation',0,'AsymRotation',0,'ExpansionX',0,'ExpansionY',0, ...
                                         'InterfieldRotation',0,'NonOrtho',0);
out.corr.BAO(2)                     = out.corr.BAO(1);
for icorr_IFO = 1:length(options.IFO_scan_direction)
    out.corr.SUSD(icorr_IFO)            = struct('TranslationX',0,'TranslationY',0,'Magnification',0,'AsymMagnification',0,...
                                         'Rotation',0,'AsymRotation',0);
end
out.corr.ffp(1)                     = struct('x',[],'y',[],'dx',[],'dy',[]);
out.corr.ffp(1).x                   = dummy_field.wd.xf;
out.corr.ffp(1).y                   = dummy_field.wd.yf;
out.corr.ffp(1).dx                  = zeros(size(dummy_field.wd.xf));
out.corr.ffp(1).dy                  = zeros(size(dummy_field.wd.yf));
out.corr.ffp(2)                     = out.corr.ffp(1);