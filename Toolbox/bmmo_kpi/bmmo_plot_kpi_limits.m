function bmmo_plot_kpi_limits(kpi_struct, limits, xvec, kpiname)
% function bmmo_plot_kpi_struct(kpi_struct, xvec)
%
% Recursively traverse a BMMO-NXE KPI limits structure, plotting each vector element

fn = fieldnames(limits(1));

plotted_indices = false(size(fn));
struct_indices = plotted_indices;

for ii = 1:length(struct_indices)
   struct_indices(ii) = isstruct(kpi_struct(1).(fn{ii}));
end

still_to_plot = ~struct_indices & ~plotted_indices;
if any(still_to_plot)
    % plot the vector components of the struct array
    bmmo_plot_vector_struct_limits(kpi_struct, limits, fn(still_to_plot), xvec, kpiname);
end

struct_fields = reshape(find(struct_indices), 1, []);
for istruct = struct_fields     
   bmmo_plot_kpi_limits([kpi_struct.(fn{istruct})], [limits.(fn{istruct})], xvec, [kpiname '.' strrep(fn{istruct}, '_', ' ')]);               
end
