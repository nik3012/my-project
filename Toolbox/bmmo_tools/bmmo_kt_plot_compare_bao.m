function bmmo_kt_plot_compare_bao(corr1, corr2, name1, name2)
% function bmmo_kt_plot_compare_bao(corr1, corr2, name1, name2)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%
close all;

slidetitle = ['BAO'];

newslide(slidetitle);

baodata = zeros(2,10);
baonames = fieldnames(corr1.BAO(1));


for ic = 1:2
    % build a vector from bao
    for ib = 1:length(baonames)
        baodata(1, ib) = corr1.BAO(ic).(baonames{ib});
        baodata(2, ib) = corr2.BAO(ic).(baonames{ib});
    end
    figtitle = ['Chuck ' num2str(ic)];
    figure, bar(baodata');
    %barnames(baonames);
    legend({name1, name2});
end

for ic = 1:2
    figppt(ic,[1,2,ic],'bitmap_hd');
end



    
    