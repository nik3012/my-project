function plotted_indices = bmmo_plot_ovl_struct(struct_in, fname, xvec, figtitle)
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

category = {'997', 'max', 'm3s', '3std'};

plotted_indices = bmmo_plot_ovl_category_struct(struct_in, fname, xvec, figtitle, category);

