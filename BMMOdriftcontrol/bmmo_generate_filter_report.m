function filter = bmmo_generate_filter_report(options)
% function filter = bmmo_generate_filter_report(options)
%
% Generate report of time filter coefficients
%
% Input:
%   options: BMMO/BL3 default options structure
%
% Output: 
%   filter: out.report.filter output as defined in D000810611

report_out = {'WH', 'SUSD_c1', 'SUSD_c2', 'MI_c1', 'MI_c2', 'KA_c1', 'KA_c2', 'Intra_c1', 'Intra_c2', 'BAO_c1', 'BAO_c2'};
filter_in = {'WH', 'SUSD', 'SUSD', 'MI', 'MI', 'KA', 'KA', 'INTRAF', 'INTRAF', 'BAO', 'BAO'};

for ii = 1:length(report_out)
   filter.(report_out{ii}) = options.filter.coefficients.(filter_in{ii}); 
end
