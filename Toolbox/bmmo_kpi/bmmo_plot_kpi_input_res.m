function bmmo_plot_kpi_input_res(kpi, dateArray, machineid)
% function bmmo_plot_kpi_input_res(kpi, dateArray, machineid)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%

dataname =  {'ovl_chk1_997_x', 'ovl_chk1_997_y', 'ovl_chk2_997_x', 'ovl_chk2_997_y'};
titlename = {'1 dx', '1 dy', '2 dx', '2 dy'};

for ii = 1:4
    close all;
    figure, plot(dateArray, arrayfun(@(x) x.uncontrolled.overlay.(dataname{ii}), kpi), 'g');
    hold on, plot(dateArray, arrayfun(@(x) x.input.overlay.(dataname{ii}), kpi), 'r-*');
    hold on, plot(dateArray, arrayfun(@(x) x.correction.total_filtered.total.(dataname{ii}), kpi), 'b-o');
    hold on, plot(dateArray, arrayfun(@(x) x.residue.overlay.(dataname{ii}), kpi), 'k-o');
    legend({'Uncontrolled', 'Controlled', 'Total SBC', 'Residual'}, 'Location', 'bestoutside');
    xlabel('Date');
    ylabel('OVL (m)');
    title(['Chuck ' titlename{ii} ' overlay']);
    newslide('Overlay comparison', machineid);
    figppt(1, [1 1 1], 'fit');
end

