function bmmo_add_ADEL_SBC(adelfile1, adelfile2, outfile, factor)
% function bmmo_add_ADEL_SBC(adelfile1, adelfile2, outfile)
%
% Add the correction data in ADEL SBC2 files, keeping header information
% from adel file 1, applying scaling factor to adel file 2, writing the 
% output to a new ADEL SBC2 file
%
% Input
%   adelfile1: full path of valid ADEL SBC2 file
%   adelfile2: full path of valid ADEL SBC2 file
%   outfile: full path of output file
%   factor: scaling factor to apply to adel file 2 data before adding
%
% 20160321 SBPR Creation
% 20190820 SELR Updated for SUSD control

if nargin < 4
    factor = 1;
end

sbc1 = bmmo_kt_process_SBC2(adelfile1);
sbc2 = bmmo_kt_process_SBC2(adelfile2);

% initialize scaling factors: reuse time filtering
filter_coefficients = bmmo_get_empty_filter;

sbc2 = bmmo_apply_time_filter(sbc2, filter_coefficients, factor);

sbc_out = bmmo_add_output_corr(sbc1, sbc2);

bmmo_create_ADEL_SBC(adelfile1, outfile, sbc_out);
