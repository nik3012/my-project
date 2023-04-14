function [mlo, sbc] = bmmo_undo_sbc_correction(mli, options)
% function [mlo, sbc] = bmmo_undo_sbc_correction(mli, options)
%
% This function removes the sbc correction applied during exposure of
% monitor lot, for calculation of uncontrolled KPI
%
% Input:
% mli:      YieldStar measurement translated by LCP Java SW layer. mli also
%           includes additional scanner data that is needed during modeling
% options:  bmmo-nxe default options structure
%
% Output:
% mlo:       Same structure as mli, with corrections during exposure reverted
% sbc:       structure containing the following fields:
%   KA:  KA fingerprint
%   MI:  MI fingerprint
%   BAO: BAO fingerprint
%   INTRAF: INTRAF fingerprint
%   WH: WH fingerprint
%   SUSD: SUSD fingerprint
% 
% For details of the model and definitions of in/out interfaces, refer to
% D000810611 EDS BMMO NXE drift control model

mlo = mli;
pc = options.previous_correction;

% pc.ffp contains the real inlineSDM fingerprint. Convert this directly to
% the input layout
intraf = bmmo_ffp_to_ml_simple(pc.ffp, mli, options);

% get measurement layout
intraf = ovl_combine_linear(mli, 0, intraf, 1);

% use WH fp per wafer for de-correction
options.WH.use_input_fp_per_wafer = 1;

% use ADELwafergrid KA for de-correction (BL3)
if options.bl3_model
    if isfield(options, 'KA_act_corr')
        pc.KA = rmfield(pc.KA, 'grid_2de');
        pc.KA.act_corr = options.KA_act_corr;
    else
        warning('KA_act_corr field obtained from ADELwaferGridResidualReportProtected is missing, generating KA fingerprint using configured options instead')
    end
end

sbc = bmmo_get_sbc_fingerprints(intraf, options, pc);

mlo = ovl_sub(mlo, sbc.TotalSBCcorrection);
