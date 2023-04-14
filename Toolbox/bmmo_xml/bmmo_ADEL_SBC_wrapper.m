function bmmo_ADEL_SBC_wrapper(input_dir, template_dir, output_dir)
% function bmmo_ADEL_SBC_wrapper(input_dir, template_dir, output_dir)
%
% Wrapper for bmmo_create_ADEL_SBC which is called from automation loop
% shell script
%
% Input:
%   input_dir: directory with injected drift data containing either xml SBC file
%           or sbc correction in Matlab format
%   template_dir: directory containing ADEL SBC file to use as template
%   output_dir: directory to write output file 


% look in input_dir for 
% - ADEL sbc xml file to inject
% - .mat file with sbc correction
files = dir(input_dir);
filenames = {files.name};
sbc = [];
found = 0;
ii = 1;
while found == 0 && ii <= length(filenames) 
    [a, b, c] = fileparts(filenames{ii});
    if strcmp(c, 'xml')
       try
           sbc = bmmo_kt_process_SBC2(filenames{ii});
           disp('Found valid XML ADEL SBC drift file %s', filenames{ii});
           found = 1;
       catch err
           sbc = [];
       end
    elseif strcmp(c, 'mat')
        matlist = whos('-file', filenames{ii});
        matnames = {matlist.name};
        sbcind = find(strcmp(matnames, 'sbc'));
        if ~isempty(sbcind)
            sbc = load(filenames{ii}, matnames{sbcind});
            disp('Found SBC drift file %s', filenames{ii});
        end
    end
    ii = ii + 1;
end


% look in template dir for ADEL sbc xml file
sbcfile = bmmo_find_adel_SBC_xml(template_dir);
if ~isempty(sbcfile)
    disp('Found valid XML ADEL SBC template file %s', sbcfile);
else
    error('No valid XML template SBC file found');
end

% Initialize the output filename
outfilename = [output_dir filesep 'ADELsbcOverlayDriftControlNxe.xml'];

% create the ADEL SBC file
bmmo_create_ADEL_SBC(sbcfile, outfilename, sbc);

