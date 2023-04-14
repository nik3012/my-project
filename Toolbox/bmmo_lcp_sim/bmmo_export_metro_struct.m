function bmmo_export_metro_struct(metrology_struct2, fname, totalmeasurements)
% function bmmo_export_metro_struct(metrology_struct2, fname, totalmeasurements)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%

disp('generating xml output .... please wait');

fname_export = ['ADELmetrology_' fname '.xml'];

%display a progress bar
progbar = char(ones(1,100) + 34);
disp(progbar);

dotcount = floor(totalmeasurements / 100);

%bmmo_struct2xml(metrology_struct2,fname_export, totalmeasurements)
fid = fopen(fname_export, 'W'); % Open ADELmetrology file for buffered write
%fid = stdout;
bmmo_ADELmetro_mat2xml(metrology_struct2, fid, dotcount, 0);
fclose(fid);

fprintf('\nADELmetrology file has been created at: %s\n',fname_export);   