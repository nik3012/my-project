function plotted_indices = bmmo_plot_ovl_category_struct(struct_in, fname, xvec, figtitle, category)
% function bmmo_plot_ovl_struct(struct_in, xvec)
%
% plot kpi overlay structure, separating the stats
%
% Input:
%   struct_in: length m Matlab structure array
%   fname: length n cell array of field names which contain double values
%   xvec: length m vector of values for x axis of plot
%   figtitle: figure title
%
% 20170906 SBPR Creation


plotted_indices = false(size(fname));

for ii = 1:length(category)
    
     to_plot = ~cellfun(@isempty, (strfind(fname, category{ii})));
     bmmo_plot_vector_struct(struct_in, fname(to_plot), xvec, figtitle);
     plotted_indices = plotted_indices | to_plot;
end