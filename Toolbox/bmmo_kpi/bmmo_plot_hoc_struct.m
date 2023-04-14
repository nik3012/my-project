function plotted_indices = bmmo_plot_hoc_struct(struct_in, fname, xvec, figtitle)
% function bmmo_plot_hoc_struct(struct_in, xvec)
%
% plot kpi hoc structure, separating the stats
%
% Input:
%   struct_in: length m Matlab structure array
%   fname: length n cell array of field names which contain double values
%   xvec: length m vector of values for x axis of plot
%   figtitle: figure title
%
% 20170906 SBPR Creation


kf_cat{1} = 7:12;   % simple 2nd order k-factors
kf_cat{2} = 14:19;  % complex 2nd order k-factors
kf_cat{3} = [13 20]; % 3rd order k-factors
kf_cat{4} = [22 24 25 26 27 29]; % 35 par extention - part 1/3
kf_cat{5} = [32 34 36 37 39 41]; % 35 par extention - part 2/3
kf_cat{6} = [46 48 51]; % 35 par extention - part 3/3

knum = zeros(size(fname));

for ii = 1:length(fname)
   tmp = strsplit(fname{ii}, '_');
   knum_tst = sscanf(tmp{2}, 'k%d');
   if ~isempty(knum_tst)
    knum(ii) = knum_tst;
   end
end

plotted_indices = false(size(fname));

for ii = 1:length(kf_cat)
     to_plot = ismember(knum, kf_cat{ii});
     if any(to_plot)
        % only plot if there is something to plot 
        % added to prevent empty plots when only 20 par
        bmmo_plot_vector_struct(struct_in, fname(to_plot), xvec, figtitle);
        plotted_indices = plotted_indices | to_plot;
     end
end
    
