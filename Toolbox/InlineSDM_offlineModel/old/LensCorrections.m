function [Static_corrZ, ml_field_lens_corr, adj_pob, par]=LensCorrections(ml_dyn_input_dlm,lensdata, szd_LFP, par_lens)

options.filterCoeff = par_lens(27);
ml_dyndxdy_input_dlm = ovl_average_columns(ml_dyn_input_dlm);  %(13x1)

z2_HOCrespart=par_lens(1:13);
z3_HOCrespart=par_lens(13+1:13*2);

% dx, dy -> Zernikes
xs = spline( ml_dyndxdy_input_dlm.wd.xf', ml_dyndxdy_input_dlm.layer.wr.dx', lensdata.X);
ys = spline( ml_dyndxdy_input_dlm.wd.xf', ml_dyndxdy_input_dlm.layer.wr.dy', lensdata.X);

z2_lenspart=xs * lensdata.Generic.Lens.Factors.dZ2_dX * 1e+09; %[nm]
z3_lenspart=ys * lensdata.Generic.Lens.Factors.dZ3_dY * 1e+09; %[nm]
lenspart_z2z3.z2=z2_lenspart;
lenspart_z2z3.z3=z3_lenspart;

z2_dlm_in=z2_lenspart+z2_HOCrespart;
z3_dlm_in=z3_lenspart+z3_HOCrespart;

%z2_out and z3_out calculated from Dyn_corr, '-' is taken account only for
%z2_out and z3_out
[z2_out, z3_out, adj_pob, Static_corrZ, Dyn_corrZ, Fad_corr, par]=DLM_model_z2z3(szd_LFP*options.filterCoeff, z2_dlm_in, z3_dlm_in, lensdata);
% figure(101);plot(lensdata.X, z2_dlm_in,'.-'); hold on; plot(lensdata.X, z2_out,'r+-'); legend('Input','correction','Location','best'); title('Z2')
% figure(102);plot(lensdata.X, z3_dlm_in,'.-'); hold on; plot(lensdata.X, z3_out,'r+-'); legend('Input','correction','Location','best'); title('Z3')

dx_corr_line = z2_out / lensdata.Generic.Lens.Factors.dZ2_dX * 10^(-9);
dy_corr_line = z3_out / lensdata.Generic.Lens.Factors.dZ3_dY * 10^(-9);

% calculate the effect of the LM correction in terms of the avrg disto field
ml_field_lens_corr             = ml_dyn_input_dlm;
% use spline for the backward translation from 13 points to the measured x positions
ml_field_lens_corr.layer.wr.dx = spline( lensdata.X, dx_corr_line, ml_field_lens_corr.wd.xf);
ml_field_lens_corr.layer.wr.dy = spline( lensdata.X, dy_corr_line, ml_field_lens_corr.wd.xf);
end

function [z2_out, z3_out, adj_pob, Corr, Dyn_corr, Fad_corr, par]=DLM_model_z2z3(szd_LFP, z2_in, z3_in, lensdata)

% input and output(correctables) are in nm scale (No unit conversion within the file)

%% Choose DLM
dlm = lm_calc_lens_model(lensdata.Generic, lensdata.DLM.LM(1));

% Given Z2/Z3. Subtract LFP ?????
szd = zeros(1,13,64);  % field of 64 zernikes, all zeros (1x13x64)
szd(:,:,2) = z2_in;
szd(:,:,3) = z3_in;

% convert to Aber struct (5x13x64)
Aber_Meas = lm_calc_aberrations(szd, 1:64);                 
Aber_LFP    = lm_calc_aberrations( szd_LFP, 1:64);

Aber_dlm_input = Aber_Meas;
Aber_dlm_input.Zernikes(:,:,2:3)=Aber_Meas.Zernikes(:,:,2:3) + Aber_LFP.Zernikes(:,:,2:3);  %% Image tuner way - need to check
Before_model.Zernikes = Aber_dlm_input.Zernikes;
m_before=max(max(abs(Aber_dlm_input.Zernikes),[],2),[],1);

%% Calculate the adjustment corresponding to the aberration
adj_pob = lm_calc_adjustments(dlm,Aber_dlm_input);    % adj in [um and urad]
Corr    = lm_calc_correction( lensdata.Generic, adj_pob);                   % Corr in [nm]

After_model.Zernikes = Before_model.Zernikes;
for i=1:size(Corr.Zernikes, 3)
    After_model.Zernikes(:,:,i) = Before_model.Zernikes(:,:,i) + Corr.Zernikes(:,:,i);
end

m_after=max(max(abs(After_model.Zernikes),[],2),[],1);
% figure(100); plot(reshape(m_before, [],1),'.-');hold on;plot(reshape(m_after, [],1),'r+-')
% legend('Before modelling','After modelling','Location','best'); ylabel('[nm]'); xlabel('Zernike number'); title('max of szd')
% figure(103); plot(reshape(m_before, [],1),'.-');hold on; plot(reshape(m_after, [],1),'r+-'); ylim([-0.01,0.05]); xlim([0,40])
% legend('Before modelling','After modelling','Location','best'); ylabel('[nm]'); xlabel('Zernike number'); title('max of szd(Enlarged view)')
par.m_before=m_before;
par.m_after=m_after;

% Scan integrate lens Correctables of Zernikes and separte Scan integrated
% part and fading

[Dyn_corr, Fad_corr]=lm_scan_integrate(lensdata.Generic, Corr);    %   Dyn_corr= scan integrate(Corr), Fad_corr=Corr(13x5 :copied in y)-Dyn_corr
szd_corr_dyn = (-1)*lm_get_zernikes(Dyn_corr, 1:64);  

z2_out = szd_corr_dyn(3,:,2); 
z3_out = szd_corr_dyn(3,:,3);
end

