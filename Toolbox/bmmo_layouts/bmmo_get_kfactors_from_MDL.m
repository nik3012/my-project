
function [mlo, pars] = bmmo_get_kfactors_from_MDL(mdlpath, ml)
% function kfactors = bmmo_get_kfactors_from_MDL(mdlpath, ml)
%
% Given an MDL with k-factor information, extract the k_factors in
% BMMO-NXE format
%
% Input
%   mdlpath: full path of MDL file
%   ml: overlay structure 
%
% Output:
%   mlo: ml output containing (in mlo.info.report_data) the relevant WH information
%   from the MDL file in BMMO-NXE input format
%
% 20160916 SBPR Creation

mlo = ml;

pars = ovl_whc_get_parameters_from_mdl(mdlpath);
mdl_KG_exp_in  = mdl_read_nxe(mdlpath,'tag','KG-EA01');

pars_WHC = pars;
% remove rexpose fields from kfactors
reexp = zeros(size(pars_WHC.kfactors));
for ir = 1:length(pars_WHC.kfactors)
    if strcmp(mdl_KG_exp_in{ir}.dat.is_reexpose_scan, 'TRUE')
        reexp(ir) = 1;
    end
end

reexp = logical(reexp);
pars_WHC.kfactors = pars_WHC.kfactors(~reexp);


% remove the WH fingerprint before input if whc has not been applied
% if pars_WHC.kg_iwhc == 0
%     error('WH fingerprint not already removed from data');
%     %mlo = ovl_add(mlo, ml_wh_fp);
% end

kf = pars_WHC.kfactors_all(~logical(pars_WHC.kg_input.is_reexpose));
        
%exclude k13 and k20
Numfield = length(kf) / ml.nwafer; % this might be greater than the number of fields in the wafer

K_list={'k1','k2','k3','k4','k5','k6','k7','k8','k9','k10','k11','k12','k13', 'k14','k15','k16','k17','k18','k19', 'k20'};

for iwaf = 1:ml.nwafer
    for ifield=1:ml.nfield
        for j=[1:12 14:19]
            kfactors.wafer(iwaf).field(ifield).(K_list{j})=kf{Numfield*(iwaf-1)+ifield}(j);
        end
    end
end

mlo.info.report_data.WH_K_factors = bmmo_k_factors_to_xml(kfactors, mlo.nwafer, mlo.nfield);
mlo.info.report_data.t =  pars_WHC.Twaf;
mlo.info.report_data.r =  pars_WHC.Rwaf;
mlo.info.report_data.Tret =  pars_WHC.Tret;
mlo.info.report_data.Pdgl =  pars_WHC.Pdgl;
mlo.info.report_data.SLIP =  pars_WHC.Peuv / 0.026;
mlo.info.report_data.Rir2uev = pars_WHC.IR2EUV_old;
