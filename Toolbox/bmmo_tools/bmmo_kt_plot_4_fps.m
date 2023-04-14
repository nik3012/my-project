function bmmo_kt_plot_4_fps(fp, name, options)
% function bmmo_kt_plot_4_fps(fp, name, options)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%
close all;

if isempty(strfind(name, 'INTRAF'))
    arg1 = 'noarrows';
else
    arg1 = 'fieldavg';
end  

for ic = options.chuck_usage.chuck_id_used

    base = (ic-1) * 2;
    chuckstr = num2str(ic);

    figtitle = [name, ' chuck ', chuckstr, ' dx'];
    figure(base + 1),ovl_plot(fp(ic), arg1, 'scale', 2, 'pcolor', 'dx', 'colormap', 'jet', figtitle);
    figtitle = [name,' chuck ', chuckstr, ' dy'];
    figure(base + 2),ovl_plot(fp(ic), arg1, 'scale', 2, 'pcolor', 'dy', 'colormap', 'jet',figtitle);

end
slidetitle = name;

newslide(slidetitle);
numfigs = 4;
for i=1:numfigs;figppt(i,[2,2,i],'bitmap_hd');end