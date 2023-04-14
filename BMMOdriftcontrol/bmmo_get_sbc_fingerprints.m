function fps = bmmo_get_sbc_fingerprints(intraf, options, sbc, ff_6p)
% function fps = bmmo_get_sbc_fingerprints(intraf, options, sbc, ff_6p)
%
% This function removes the sbc correction applied during exposure of
% monitor lot, for calculation of uncontrolled KPI
%
% Input:
%   intraf:     intrafield correction in full wafer full
%               field layout. The layout will also be used as a template for the other
%               corrections
%   options:    options structure
%   sbc:        sbc corrections structure
% Optional input:
%   ff_6p:      feed forward BAO
%
% Output:
%   mlo:        Same structure as intraf, with corrections during exposure reverted
%   fps:        structure containing the following fields:
%   KA:  KA fingerprint
%   MI:  MI fingerprint
%   BAO: BAO fingerprint
%   INTRAF: INTRAF fingerprint
%   WH: WH fingerprint
%   SUSD: SUSD fingerprint    
%   TotalSBCcorrection: Total correction including ff 6par fingerprint
% 
% For details of the model and definitions of in/out interfaces, refer to
% D000810611 EDS BMMO NXE drift control model

fps.TotalSBCcorrection = ovl_combine_linear(intraf, 0);

if options.bl3_model && isfield(sbc.KA, 'act_corr') 
fps.KA =  sbc.KA.act_corr; %actuated KA from ADELwfrgrid 
else
fps.KA = bmmo_KA_SBC_fingerprint(intraf, sbc.KA.grid_2de, options);
end

fps.TotalSBCcorrection = ovl_add(fps.TotalSBCcorrection, fps.KA);

fps.MI = bmmo_MI_SBC_fingerprint(intraf, sbc.MI.wse, options);
fps.TotalSBCcorrection = ovl_add(fps.TotalSBCcorrection, fps.MI);

fps.BAO = bmmo_BAO_SBC_fingerprint(intraf, sbc.BAO, options);
fps.TotalSBCcorrection = ovl_add(fps.TotalSBCcorrection, fps.BAO);

fps.INTRAF = intraf;
fps.TotalSBCcorrection = ovl_add(fps.TotalSBCcorrection, fps.INTRAF);

fps.WH= bmmo_WH_SBC_fingerprint(intraf, options);
fps.TotalSBCcorrection = ovl_add(fps.TotalSBCcorrection, fps.WH);

fps.SUSD= bmmo_SUSD_SBC_fingerprint(intraf, sbc.SUSD, options);
fps.TotalSBCcorrection = ovl_add(fps.TotalSBCcorrection, fps.SUSD);

% the BAO ff par should have the opposite sign to the others
if nargin < 4
	ff_6p = bmmo_ff_6par_fingerprint(intraf, sbc.MI.wsm, sbc.KA.grid_2dc, options);
end


fps.TotalSBCcorrection = ovl_sub(fps.TotalSBCcorrection, ff_6p); % NB ovl_sub
end
