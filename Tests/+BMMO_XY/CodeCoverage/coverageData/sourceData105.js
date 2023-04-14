var sourceData105 = {"FileContents":["function filter = bmmo_generate_filter_report(options)\r","% function filter = bmmo_generate_filter_report(options)\r","%\r","% Generate report of time filter coefficients\r","%\r","% Input:\r","%   options: BMMO/BL3 default options structure\r","%\r","% Output: \r","%   filter: out.report.filter output as defined in D000810611\r","\r","report_out = {'WH', 'SUSD_c1', 'SUSD_c2', 'MI_c1', 'MI_c2', 'KA_c1', 'KA_c2', 'Intra_c1', 'Intra_c2', 'BAO_c1', 'BAO_c2'};\r","filter_in = {'WH', 'SUSD', 'SUSD', 'MI', 'MI', 'KA', 'KA', 'INTRAF', 'INTRAF', 'BAO', 'BAO'};\r","\r","for ii = 1:length(report_out)\r","   filter.(report_out{ii}) = options.filter.coefficients.(filter_in{ii}); \r","end\r",""],"CoverageData":{"CoveredLineNumbers":[12,13,15,16],"UnhitLineNumbers":[],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,122,122,0,122,1342,0,0]}}