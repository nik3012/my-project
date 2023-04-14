
function mirror_figs(mirror_maps, fig_legend, axis_limits)
% function mirror_figs(mirror_maps, fig_legend, axis_limits)
%
% Plot the given per-chuck x-mirror and y_mirror maps, superimposed. This
% creates 4 figures:
%  1. chuck 1 x mirror
%  2. chuck 1 y mirror
%  3. chuck 2 x mirror
%  4. chuck 2 y mirror
%
% Input: 
%   mirror maps: 1 x n cell array of 1x2 mirror maps, as output by
%       get_MI_mirror_data
%   fig_legend: 1 x n cell array of strings, figure legend
%   axis_limits: input for axis function
%
% 20160714 SBPR Creation

num_maps = length(mirror_maps);
x_int = 7;
y_int = 9;
line_width = 2;

for ic = 1:2
    figure; plot(mirror_maps{1}(ic).x_mirr.y, mirror_maps{1}(ic).x_mirr.dx, 'LineWidth',line_width); hold;
    for il = 2:num_maps
        plot(mirror_maps{il}(ic).x_mirr.y, mirror_maps{il}(ic).x_mirr.dx, 'LineWidth',line_width);
    end
    sub_plot_grid(axis_limits, x_int, y_int);

    title(['X Mirror chuck ' num2str(ic)]);
    legend(fig_legend);
    xlabel('y(m)');
    ylabel('dx(m)');
    axis(axis_limits);

    figure; plot(mirror_maps{1}(ic).y_mirr.x, mirror_maps{1}(ic).y_mirr.dy, 'LineWidth',line_width); hold;
    for il = 2:num_maps
        plot(mirror_maps{il}(ic).y_mirr.x, mirror_maps{il}(ic).y_mirr.dy, 'LineWidth',line_width);
    end
    sub_plot_grid(axis_limits, x_int, y_int);

    title(['Y Mirror chuck ' num2str(ic)]);
    legend(fig_legend);
    xlabel('x(m)');
    ylabel('dy(m)');
    axis(axis_limits);
end

function sub_plot_grid(axis_limits, x_int, y_int)

xline = linspace(axis_limits(1), axis_limits(2), x_int);
yline = linspace(axis_limits(3), axis_limits(4), y_int);

[xg, yg] = meshgrid(xline, yline);
plot(xg, yline, 'k:');
plot(xline, yg, 'k:');
