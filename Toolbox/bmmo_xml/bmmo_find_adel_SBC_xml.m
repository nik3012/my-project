
function sbcfile = bmmo_find_adel_SBC_xml(dirname)
% function sbcfile = bmmo_find_adel_SBC_xml(dirname)
%
% Find an ADELsbcOverlayDriftControlNxe file in the given directory

files = dir(dirname);
filenames = {files.name};
found = 0;
sbcfile = [];
ii = 1;
while found == 0 && ii <= length(filenames) 
    [a, b, c] = fileparts(filenames{ii});
    if strcmp(c, 'xml')
       try
           sbc = bmmo_kt_process_SBC2(filenames{ii});
           sbcfile = filenames{ii};
           found = 1;
       catch err
           sbc = [];
       end
    end
    ii = ii + 1;
end