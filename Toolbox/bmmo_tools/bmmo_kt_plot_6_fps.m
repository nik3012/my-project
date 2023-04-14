function bmmo_kt_plot_6_fps(fp1, fp2, name1, name2, options)
% function bmmo_kt_plot_6_fps(fp1, fp2, name1, name2, options)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%
close all

if isempty(strfind(name1, 'INTRAF'))
    arg1 = 'noarrows';
else
    arg1 = 'fieldavg';
end   

if isfield(options, 'sum')
    do_sum = 1;
else
    do_sum = 0;
end

scale = bmmo_kt_get_scale(fp1, fp2, options);

for ic = options.chuck_usage.chuck_id_used

    base = (ic-1) * 3;
    chuckstr = num2str(ic);

    figtitle = [name1, ' chuck ', chuckstr];
    figure(base + 1),ovl_plot(fp1(ic), arg1, 'scale', scale, 'pcolor', 'colormap', 'jet', 'prc', 2, figtitle);
    figtitle = [name2,' chuck ', chuckstr];
    figure(base + 2),ovl_plot(fp2(ic), arg1, 'scale', scale, 'pcolor', 'colormap', 'jet', 'prc', 2, figtitle);
    
    if do_sum
        figtitle = ['Sum chuck ', chuckstr];
        figure(base + 3),ovl_plot(ovl_add(fp1(ic), fp2(ic)), arg1, 'scale', scale, 'pcolor', 'colormap', 'jet', 'prc', 2, figtitle);
    else
        figtitle = ['Difference chuck ', chuckstr];
        figure(base + 3),ovl_plot(ovl_sub(fp1(ic), fp2(ic)), arg1, 'scale', scale, 'pcolor', 'colormap', 'jet', 'prc', 2, figtitle);
    end        
    
end
slidetitle = name1;

newslide(slidetitle)
numfigs = 6;
for i=1:numfigs;figppt(i,[2,3,i],'bitmap_hd');end