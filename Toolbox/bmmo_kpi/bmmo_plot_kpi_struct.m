function bmmo_plot_kpi_struct(kpi_struct, xvec, kpiname)
% function bmmo_plot_kpi_struct(kpi_struct, xvec)
%
% Recursively traverse a BMMO-NXE KPI structure, plotting each vector element

ov_category =  {'997', 'max', 'm3s', '3std'};
bao_category = {'translation', 'intra', 'wafer'};
mi_category = {'ytx_997', 'xty_997', 'ytx_max', 'xty_max', 'ytx_m3s', 'xty_m3s'};


fn = fieldnames(kpi_struct);

plotted_indices = false(size(fn));
struct_indices = plotted_indices;

if any(strcmp(fn, 'ovl_chk1_997_x'))
   plotted_indices = plotted_indices | bmmo_plot_ovl_category_struct(kpi_struct, fn, xvec, kpiname, ov_category); 
end

if any(strcmp(fn, 'ovl_translation_x_chk1_delta'))
   plotted_indices = plotted_indices | bmmo_plot_ovl_category_struct(kpi_struct, fn, xvec, kpiname, bao_category); 
end

if any(strcmp(fn, 'ovl_exp_ytx_max_full_chk1'))
   plotted_indices = plotted_indices | bmmo_plot_ovl_category_struct(kpi_struct, fn, xvec, kpiname, mi_category); 
end

if any(strcmp(fn, 'ovl_k13_chk1') | strcmp(fn, 'ovl_k13_chk1_compare_delta'))
    plotted_indices = plotted_indices | bmmo_plot_hoc_struct(kpi_struct, fn, xvec, kpiname);
end

for ii = 1:length(struct_indices)
   struct_indices(ii) = isstruct(kpi_struct(1).(fn{ii}));
end

still_to_plot = ~struct_indices & ~plotted_indices;
if any(still_to_plot)
    % plot the vector components of the struct array
    bmmo_plot_vector_struct(kpi_struct, fn(still_to_plot), xvec, kpiname);
end

struct_fields = reshape(find(struct_indices), 1, []);
for istruct = struct_fields     
   bmmo_plot_kpi_struct([kpi_struct.(fn{istruct})], xvec, [kpiname '.' strrep(fn{istruct}, '_', ' ')]);               
end
