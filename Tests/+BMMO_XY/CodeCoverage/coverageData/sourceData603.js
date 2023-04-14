var sourceData603 = {"FileContents":["function [Static_corrZ, ml_field_lens_corr, adj_pob, par]=LensCorrections(ml_dyn_input_dlm,lensdata, szd_LFP, par_lens)\r","\r","options.filterCoeff = par_lens(27);\r","ml_dyndxdy_input_dlm = ovl_average_columns(ml_dyn_input_dlm);  %(13x1)\r","\r","z2_HOCrespart=par_lens(1:13);\r","z3_HOCrespart=par_lens(13+1:13*2);\r","\r","% dx, dy -> Zernikes\r","xs = spline( ml_dyndxdy_input_dlm.wd.xf', ml_dyndxdy_input_dlm.layer.wr.dx', lensdata.X);\r","ys = spline( ml_dyndxdy_input_dlm.wd.xf', ml_dyndxdy_input_dlm.layer.wr.dy', lensdata.X);\r","\r","z2_lenspart=xs * lensdata.Generic.Lens.Factors.dZ2_dX * 1e+09; %[nm]\r","z3_lenspart=ys * lensdata.Generic.Lens.Factors.dZ3_dY * 1e+09; %[nm]\r","lenspart_z2z3.z2=z2_lenspart;\r","lenspart_z2z3.z3=z3_lenspart;\r","\r","z2_dlm_in=z2_lenspart+z2_HOCrespart;\r","z3_dlm_in=z3_lenspart+z3_HOCrespart;\r","\r","%z2_out and z3_out calculated from Dyn_corr, '-' is taken account only for\r","%z2_out and z3_out\r","[z2_out, z3_out, adj_pob, Static_corrZ, Dyn_corrZ, Fad_corr, par]=DLM_model_z2z3(szd_LFP*options.filterCoeff, z2_dlm_in, z3_dlm_in, lensdata);\r","% figure(101);plot(lensdata.X, z2_dlm_in,'.-'); hold on; plot(lensdata.X, z2_out,'r+-'); legend('Input','correction','Location','best'); title('Z2')\r","% figure(102);plot(lensdata.X, z3_dlm_in,'.-'); hold on; plot(lensdata.X, z3_out,'r+-'); legend('Input','correction','Location','best'); title('Z3')\r","\r","dx_corr_line = z2_out / lensdata.Generic.Lens.Factors.dZ2_dX * 10^(-9);\r","dy_corr_line = z3_out / lensdata.Generic.Lens.Factors.dZ3_dY * 10^(-9);\r","\r","% calculate the effect of the LM correction in terms of the avrg disto field\r","ml_field_lens_corr             = ml_dyn_input_dlm;\r","% use spline for the backward translation from 13 points to the measured x positions\r","ml_field_lens_corr.layer.wr.dx = spline( lensdata.X, dx_corr_line, ml_field_lens_corr.wd.xf);\r","ml_field_lens_corr.layer.wr.dy = spline( lensdata.X, dy_corr_line, ml_field_lens_corr.wd.xf);\r","end\r","\r","function [z2_out, z3_out, adj_pob, Corr, Dyn_corr, Fad_corr, par]=DLM_model_z2z3(szd_LFP, z2_in, z3_in, lensdata)\r","\r","% input and output(correctables) are in nm scale (No unit conversion within the file)\r","\r","%% Choose DLM\r","dlm = lm_calc_lens_model(lensdata.Generic, lensdata.DLM.LM(1));\r","\r","% Given Z2/Z3. Subtract LFP ?????\r","szd = zeros(1,13,64);  % field of 64 zernikes, all zeros (1x13x64)\r","szd(:,:,2) = z2_in;\r","szd(:,:,3) = z3_in;\r","\r","% convert to Aber struct (5x13x64)\r","Aber_Meas = lm_calc_aberrations(szd, 1:64);                 \r","Aber_LFP    = lm_calc_aberrations( szd_LFP, 1:64);\r","\r","Aber_dlm_input = Aber_Meas;\r","Aber_dlm_input.Zernikes(:,:,2:3)=Aber_Meas.Zernikes(:,:,2:3) + Aber_LFP.Zernikes(:,:,2:3);  %% Image tuner way - need to check\r","Before_model.Zernikes = Aber_dlm_input.Zernikes;\r","m_before=max(max(abs(Aber_dlm_input.Zernikes),[],2),[],1);\r","\r","%% Calculate the adjustment corresponding to the aberration\r","adj_pob = lm_calc_adjustments(dlm,Aber_dlm_input);    % adj in [um and urad]\r","Corr    = lm_calc_correction( lensdata.Generic, adj_pob);                   % Corr in [nm]\r","\r","After_model.Zernikes = Before_model.Zernikes;\r","for i=1:size(Corr.Zernikes, 3)\r","    After_model.Zernikes(:,:,i) = Before_model.Zernikes(:,:,i) + Corr.Zernikes(:,:,i);\r","end\r","\r","m_after=max(max(abs(After_model.Zernikes),[],2),[],1);\r","% figure(100); plot(reshape(m_before, [],1),'.-');hold on;plot(reshape(m_after, [],1),'r+-')\r","% legend('Before modelling','After modelling','Location','best'); ylabel('[nm]'); xlabel('Zernike number'); title('max of szd')\r","% figure(103); plot(reshape(m_before, [],1),'.-');hold on; plot(reshape(m_after, [],1),'r+-'); ylim([-0.01,0.05]); xlim([0,40])\r","% legend('Before modelling','After modelling','Location','best'); ylabel('[nm]'); xlabel('Zernike number'); title('max of szd(Enlarged view)')\r","par.m_before=m_before;\r","par.m_after=m_after;\r","\r","% Scan integrate lens Correctables of Zernikes and separte Scan integrated\r","% part and fading\r","\r","[Dyn_corr, Fad_corr]=lm_scan_integrate(lensdata.Generic, Corr);    %   Dyn_corr= scan integrate(Corr), Fad_corr=Corr(13x5 :copied in y)-Dyn_corr\r","szd_corr_dyn = (-1)*lm_get_zernikes(Dyn_corr, 1:64);  \r","\r","z2_out = szd_corr_dyn(3,:,2); \r","z3_out = szd_corr_dyn(3,:,3);\r","end\r","\r",""],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[3,4,6,7,10,11,13,14,15,16,18,19,23,27,28,31,33,34,42,45,46,47,50,51,53,54,55,56,59,60,62,63,64,67,72,73,78,79,81,82],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}