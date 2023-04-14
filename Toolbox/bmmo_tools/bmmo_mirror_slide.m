function mirror_slide(mirror_maps, mirror_legend, slidetitle)
% function mirror_slide(mirror_maps, mirror_legend, slidetitle)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%
close all;
axis_limits = [-0.15, 0.15 -0.8e-9 0.8e-9];

mirror_figs(mirror_maps, mirror_legend, axis_limits);
newslide(slidetitle);

for ifig = 1:4
    figppt(ifig, [2 2 ifig], 'fit');
end


