% load existing disto set (mli)
load('\\asml.com\eu\shared\nl011052\BMMO_NXE_TS\01-Functional\102-Study_items\BMMO_inlineSDM\data_temp\test1\mli');
mli_new = mli;

% set dx to 2.0 nm + tilt of 0.1nm per grid point in x-direction 
% set dy to 3.0 nm + tilt of 0.1nm per grid point in y-direction 
for iy=1:19
  for ix=1:13
     iyz = iy-1;
     ixz = ix-1;
     if (mod(iy,2) ~= 0)
        % odd y-lines from left to right
        mli_new.layer.wr.dx((iyz*13) + ix) = 2E-9 + (ixz * 1E-10);
        mli_new.layer.wr.dy((iyz*13) + ix) = 3E-9 + (iyz * 1E-10) ;
     else
        % even y-lines from right to left
        mli_new.layer.wr.dx((iyz*13) + ix) = 2E-9 + ((13-ix) * 1E-10);
        mli_new.layer.wr.dy((iyz*13) + ix) = 3E-9 + (iyz * 1E-10); 
     end
  end
end

% plot disto
figure; ovl_plot(mli_new,'pcolor','scale',0,'prc',3,'field')

% copy disto to chuck 1 and chuck 2
mli_chk1 = mli_new;
mli_chk2 = mli_new;

% BMMO model
%[par_mc, extra_data, par, KPI, RES, COR]=BMMO_model_inlineSDM(mli_chk1, mli_chk2);
[par_mc, extra_data, par, KPI, RES, COR]=BMMO_model_inlineSDM_v2(mli_chk1, mli_chk2,'LFP',0);
