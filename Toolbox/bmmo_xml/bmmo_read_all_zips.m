function [input_structs, sbcs,  dates, kpis, jobreps] = bmmo_read_all_zips(input_folder)
% function [input_structs, sbcs,  dates, kpis] = bmmo_read_all_zips(input_folder)
%
% Read all LCP/VCP .zip files in a given folder, generating a vector of model
% inputs, SBC corrections,  dates, and KPI data
%
% Input
%   input_folder: folder containing n LCP/VCP .zip files output from BMMO-NXE
%   jobs
%
% Output
%   input_structs: 1xn vector of valid BMMO-NXE input structures, as
%       extracted from the zip files
%   sbcs: 1xn vector of SBC corrections as output by each job
%   dates: 1xn vector of datetime structures
%   kpis: 1xn vector of KPI structures
%
% 20180418 SBPR Added documentation
% 20190222 SELR Added jobreps as output, fixed skipping of invalid zips
% 20200918 ANBZ Kept dates as created time for VCP, since no Jobstarted field present
%               in Job report

zipfiles = dir([input_folder filesep '*.zip']);

if ~isempty(zipfiles)
    zipfilenames = arrayfun(@(x) [x.folder filesep x.name], zipfiles, 'UniformOutput', false);
    
    numfiles = length(zipfilenames);
    
    for ii = 1:numfiles
        try     
            [input_structs(ii), ~, sbcs(ii), jobreps(ii)] = bmmo_read_lcp_zip(zipfilenames{ii});
            % case: VCP job_report
            if strcmp(jobreps(ii).Header.DocumentType, 'ADELbmmoOverlayJobReport')
                dates(ii) = bmmo_parse_adel_timestamp(jobreps(ii).Header.CreateTime);
                kpis(ii) = bmmo_parse_lcp_report(jobreps(ii));
            % case: LCP job_report
            else
                dates(ii) = bmmo_parse_adel_timestamp(jobreps(ii).Input.WaferMapping(1).elt.ExposureContext.LotStart);
                kpis(ii) = bmmo_parse_lcp_report(jobreps(ii));
            end
            
        catch
            warning(['Invalid BMMO-NXE zip file, skipping.... ' zipfilenames{ii}]);
        end
        
        
        
        
    end
else
    error('No .zip files found in folder');
end