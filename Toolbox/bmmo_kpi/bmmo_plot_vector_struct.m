function bmmo_plot_vector_struct(struct_in, fname, xvec, figtitle)
% function bmmo_plot_vector_struct(struct_in, xvec)
%
% plot a struct containing n vectors as a line plot with n lines
%
% Input:
%   struct_in: length m Matlab structure array
%   fname: length n cell array of field names which contain double values
%   xvec: length m vector of values for x axis of plot
%   figtitle: figure title
%
% 20170906 SBPR Creation

close all;
newslide('KPI data', figtitle);

marker{1} = '-o';
marker{2} = '-x';

numplots = length(fname);
markerid = zeros(size(fname));
mid_idx = floor(numplots / 2);
if mid_idx < numplots
    markerid(1:mid_idx) = 1;
    markerid((mid_idx+1):end) = 2;
else
    markerid(1:end) = 1;
end
    
figure; 
hold on;
for ii = 1:numplots
   plot(xvec, [struct_in.(fname{ii})], marker{markerid(ii)}); 
end

title(figtitle);


fixed_fname = strrep(fname, '_', ' ');
legend(fixed_fname, 'Location', 'bestoutside');

figppt(1, [1 1 1], 'fit');