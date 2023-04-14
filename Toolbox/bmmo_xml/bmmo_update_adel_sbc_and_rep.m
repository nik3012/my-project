function bmmo_update_adel_sbc_and_rep(corrfile, repfile, injected_sbc)
% function bmmo_update_adel_sbc_and_rep(corrfile, repfile, injected_sbc)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%

adelsbc = bmmoADELSBC();
adelsbc.read(corrfile);
adelsbc.set_corr(injected_sbc);
adelsbc.write(corrfile);

bmmo_create_ADEL_SBCrep(repfile, repfile, injected_sbc)