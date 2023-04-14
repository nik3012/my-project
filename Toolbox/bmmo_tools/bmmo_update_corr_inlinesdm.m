function [corr_out, res_out] = bmmo_update_corr_inlinesdm(corr_in, options)
% function [corr_out, res_out] = bmmo_update_corr_inlinesdm(corr_in)
%
% Update sbc intrafield correction with inlineSDM model
%
% Input: corr_in: BMMO-NXE SBC2 correction structure
%
% Output: corr_out: BMMO-NXE SBC2 correction structure after inline SDM
%            residual removed
%         res_out: modelled inline SDM residual
%
% 20200710 JIMI Update intrafield actuation with cet model type in existing
% bmmo_update_corr_inlinesdm

if nargin < 2
    options = bmmo_default_options_structure;
end

mld = ovl_average_fields(ovl_create_dummy('13X19', 'nlayer', 1, 'nwafer', 2));
corr_out = corr_in;
flds = bmmo_ffp_to_ml(corr_in.ffp, mld);

if options.intraf_actuation_order == 3
    [~, ~, ~, ~, res] = bmmo_model_inlineSDM(ovl_get_wafers(flds, 1), ...
        ovl_get_wafers(flds, 2), 'LFP', 0, 'CET_model', '');
elseif options.intraf_actuation_order == 5
    [~, ~, ~, ~, res, ~]= bmmo_model_inlineSDM(ovl_get_wafers(flds, 1), ...
        ovl_get_wafers(flds, 2), 'LFP', 0, 'CET_model', 'ovo3');
else
    error('Wrong inline SDM options');
end
I = knnsearch([mld.wd.xf mld.wd.yf], [corr_out.ffp(1).x corr_out.ffp(1).y]);
for jj = 1:2
    res_out(jj).dx = res.TotalRes(jj).dx(I);
    res_out(jj).dy = res.TotalRes(jj).dy(I);
    res_out(jj).x = corr_out.ffp(jj).x;
    res_out(jj).y = corr_out.ffp(jj).y;
    corr_out.ffp(jj).dx = corr_out.ffp(jj).dx - res_out(jj).dx;
    corr_out.ffp(jj).dy = corr_out.ffp(jj).dy - res_out(jj).dy;
end
