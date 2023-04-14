function bmmo_plot_vector_struct_limits(struct_in, limit_array, fname, xvec, figtitle)
% function bmmo_plot_vector_struct_limits(struct_in, limit_array, fname, xvec, figtitle)
%
% plot a struct containing n vectors as a line plot with n lines and put in
% a presentation
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

for is = 1:length(limit_array)
    limit_vec = ones(1, length(xvec)) * limit_array(is).(fname{1});
    plot(xvec, limit_vec, 'r-', 'LineWidth', 2);
end

title(figtitle);


fixed_fname = strrep(fname, '_', ' ');
fixed_fname = [fixed_fname; 'KPI Limit'];
legend(fixed_fname, 'Location', 'bestoutside');

figppt(1, [1 1 1], 'fit');