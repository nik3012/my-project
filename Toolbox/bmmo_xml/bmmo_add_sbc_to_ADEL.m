function bmmo_add_sbc_to_ADEL(adelfile, sbc, outfile)
% function bmmo_add_sbc_to_ADEL(adelfile, sbc, outfile)
%
% Add a Matlab SBC Correction to an ADEL SBC recipe, keeping the header
% information from the latter
%
% Input: adelfile : full path of ADEL SBC recipe xml file. This file will provide the header information
%        sbc : Injected SBC correction in Matlab format
% 	   outfile : full path of output ADEL xml file
%
% 20170321 SBPR Creation

sbc_in = bmmo_kt_process_SBC2(adelfile);
sbc_new = bmmo_add_output_corr(sbc_in, sbc);
bmmo_create_ADEL_SBC(adelfile, outfile, sbc_new);