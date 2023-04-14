function [corr_out, res_out] = bmmo_update_corr_18par(corr_in)
% function [corr_out, res_out] = bmmo_update_corr_18par(corr_in)
%
% Update sbc intrafield correction with 18par model
%
% Input: corr_in: BMMO-NXE SBC2 correction structure
%   
% Output: corr_out: BMMO-NXE SBC2 correction structure after 18par
%            residual removed
%         res_out: modelled 18par residual


mld = ovl_average_fields(ovl_create_dummy('13X19', 'nlayer', 1, 'nwafer', 2));
corr_out = corr_in;
flds = bmmo_ffp_to_ml(corr_in.ffp, mld);

res = ovl_model(flds, '18par', 'perwafer');

for jj = 1:2
    res_out(jj).dx = res.layer.wr(jj).dx;
    res_out(jj).dy = res.layer.wr(jj).dy;
    res_out(jj).x = corr_out.ffp(jj).x;
    res_out(jj).y = corr_out.ffp(jj).y;
    corr_out.ffp(jj).dx = corr_out.ffp(jj).dx - res.layer.wr(jj).dx;
    corr_out.ffp(jj).dy = corr_out.ffp(jj).dy - res.layer.wr(jj).dy;
end