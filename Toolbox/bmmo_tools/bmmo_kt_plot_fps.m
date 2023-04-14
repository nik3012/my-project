function bmmo_kt_plot_fps(mli, sbc_corr)
% function bmmo_kt_plot_fps(mli, sbc_corr)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%
fp = bmmo_kt_apply_SBC(mli, sbc_corr);

fp_name = fieldnames(fp);



options.chuck_usage.chuck_id = [1 2 1 2 1 2];
options.chuck_usage.chuck_id = options.chuck_usage.chuck_id(1:mli.nwafer);
options.chuck_usage.chuck_id_used = [1 2];


for ifield = 1:length(fp_name)
   chuck_fp{ifield} = bmmo_average_chuck(fp.(fp_name{ifield}), options); 
end

for ic = 1:2
    close all;
    for ifield = 1:length(fp_name)
        sub_plot_individual_fp(ifield, fp_name{ifield}, chuck_fp{ifield}(ic));
    end

    slidetitle = ['BMMO Correctibles chuck ' num2str(ic)];
    newslide(slidetitle);
    
    for i = 1:length(fp_name)
        figppt(i, [2 3 i], 'bitmap_hd'); 
    end
end

close all;

function sub_plot_individual_fp(fig, name, fp)

if ~strcmp(name, 'INTRAF')
    figure,ovl_plot(ovl_remove_edge(fp), 'scale',0, 'pcolor', 'colormap', 'jet', 'fontsize', 14,'prc', 2,name, 'legend', 'cust');
else
    figure,ovl_plot(fp, 'fieldavg','scale',0, 'pcolor', 'colormap', 'jet','fontsize', 14, 'prc', 2,name, 'legend', 'cust');
end