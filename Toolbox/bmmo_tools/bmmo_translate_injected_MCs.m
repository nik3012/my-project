function corr = bmmo_translate_injected_MCs(injected_mcs)
% function corr = bmmo_translate_injected_MCs(injected_mcs)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%
% Copy MI directly
corr.MI = injected_mcs.MI;

% Copy SDM tlgs into ffp
for ic = 1:2
    corr.ffp(ic).x = injected_mcs.SDM_tlg{ic}.wd.xf;
    corr.ffp(ic).y = injected_mcs.SDM_tlg{ic}.wd.yf;
    corr.ffp(ic).dx = injected_mcs.SDM_tlg{ic}.layer(1).wr.dx;
    corr.ffp(ic).dy = injected_mcs.SDM_tlg{ic}.layer(1).wr.dy;
end

% Resample KA to 61x61 grid
% create zeroed KA grid using defined KA pitch
parmc = ovl_metro_par_mc('KA_pitch',0.0050);
corr.KA.grid_2de = parmc.KA.raw.grid_2de;

x_grid_in = reshape(injected_mcs.KA.raw.grid_2de(1).x, 301, 301);
y_grid_in = reshape(injected_mcs.KA.raw.grid_2de(1).y, 301, 301);
x_grid_out = reshape(corr.KA.grid_2de(1).x, 61, 61);
y_grid_out = reshape(corr.KA.grid_2de(2).y, 61, 61);


for ic = 1:2
    
    dxin = reshape(injected_mcs.KA.raw.grid_2de(ic).dx, 301, 301);
    dyin = reshape(injected_mcs.KA.raw.grid_2de(ic).dy, 301, 301);
    
    dxout = interp2(x_grid_in, y_grid_in, dxin, x_grid_out, y_grid_out);
    dyout = interp2(x_grid_in, y_grid_in, dyin, x_grid_out, y_grid_out);
    
    corr.KA.grid_2de(ic).dx = dxout(:);
    corr.KA.grid_2de(ic).dy = dyout(:);
end


%Convert BAO to new format
for ic = 1:2
    corr.BAO(ic) = bmmo_10par_to_BAO(injected_mcs.BAO.raw(ic));
end

% Add WH correction

% Ir2EUV is given
corr.IR2EUV = 0.3;


