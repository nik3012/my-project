function ovl = bmmo_calc_KPI3_4_from_zips(job_path)
% function ovl = bmmo_calc_KPI3_4(job_path)
%
% Calculate Overaly monitor Interfield and Intrafield KPIs (DeltaToReference
% and DeltaToPrevious) based on reference, previous and current BMMO
% job zips
%
%Input:
%
% job_path: full path of the folder with reference.zip, previous.zip
%           and current.zip.
%
% Output:
% ovl: Overaly monitor KPIs, ovl.inter and ovl.intra

zip_paths = {[job_path filesep 'reference.zip'], [job_path filesep 'previous.zip'], [job_path filesep 'current.zip']};
for i = 1:length(zip_paths)
    [input_structs(i), ~, sbcs(i)] = bmmo_read_lcp_zip(zip_paths{i});
end

ovl = bmmo_calc_KPI3_4(input_structs, sbcs);

