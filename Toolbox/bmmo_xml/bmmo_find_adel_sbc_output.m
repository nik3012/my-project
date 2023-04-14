function adelsbc = bmmo_find_adel_sbc_output(dir_name)
% function adelsbc = bmmo_find_adel_sbc_output(dir_name)
%
% Given a directory containing ADEL files, find the ADEL sbc report with
% the most recent date

dir_list = dir(fullfile(dir_name, '*.xml'));

% Lazy version = just look for filenames

allfiles = {dir_list.name};

% find the xml job report
adeljobreport = [dir_name filesep allfiles{strncmp('ADELlpcJobReport', allfiles, length('ADELlpcJobReport'))}];

if ~isempty(adeljobreport)
    jobdata = xml_load(adeljobreport);
    docs_out = [jobdata.Results.DocumentList.Document];

    sbc_data = docs_out(strcmp({docs_out.Type}, 'ADELsbcOverlayDriftControlNxe'));

    if ~isempty(sbc_data)
        sbcfile = [sbc_data.Type '_' sbc_data.Name '.xml'];
        % check that the constructed file name is in the directory
        if ~any(strcmp(sbcfile, allfiles))
            error(['File ' sbcfile ' not found in directory ' dir_name]);
        else
            disp(['Using ' sbcfile ' as SBC output']);
        end
            
        adelsbc = [dir_name filesep sbcfile]; 
    else
        error('ADEL SBC output not found in LCP job report');
    end
else
    error(['No LCP job report found in directory ' dir_name]);
end