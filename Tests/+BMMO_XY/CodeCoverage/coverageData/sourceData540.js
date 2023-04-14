var sourceData540 = {"FileContents":["function bmmo_add_ADEL_SBC(adelfile1, adelfile2, outfile, factor)\r","% function bmmo_add_ADEL_SBC(adelfile1, adelfile2, outfile)\r","%\r","% Add the correction data in ADEL SBC2 files, keeping header information\r","% from adel file 1, applying scaling factor to adel file 2, writing the \r","% output to a new ADEL SBC2 file\r","%\r","% Input\r","%   adelfile1: full path of valid ADEL SBC2 file\r","%   adelfile2: full path of valid ADEL SBC2 file\r","%   outfile: full path of output file\r","%   factor: scaling factor to apply to adel file 2 data before adding\r","%\r","% 20160321 SBPR Creation\r","% 20190820 SELR Updated for SUSD control\r","\r","if nargin < 4\r","    factor = 1;\r","end\r","\r","sbc1 = bmmo_kt_process_SBC2(adelfile1);\r","sbc2 = bmmo_kt_process_SBC2(adelfile2);\r","\r","% initialize scaling factors: reuse time filtering\r","filter_coefficients = bmmo_get_empty_filter;\r","\r","sbc2 = bmmo_apply_time_filter(sbc2, filter_coefficients, factor);\r","\r","sbc_out = bmmo_add_output_corr(sbc1, sbc2);\r","\r","bmmo_create_ADEL_SBC(adelfile1, outfile, sbc_out);\r",""],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[17,18,21,22,25,27,29,31],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}