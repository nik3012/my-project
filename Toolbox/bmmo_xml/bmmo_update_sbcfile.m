function bmmo_update_sbcfile(sbcfile, sbc_corr)
% function bmmo_update_sbcfile(sbcfile, sbc_corr)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%

sbc = bmmoADELSBC();
sbc.read(sbcfile);
sbc.set_corr(sbc_corr);
sbc.write(['ADELsbcOverlayDriftControlNxe_' sbc.xml_data.Header.DocumentId '.xml'] );