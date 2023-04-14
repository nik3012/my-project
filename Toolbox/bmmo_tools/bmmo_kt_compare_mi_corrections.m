function bmmo_kt_compare_mi_corrections(corr1, corr2, name1, name2)
% function bmmo_kt_compare_mi_corrections(corr1, corr2, name1, name2)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%
openppt('new');

% plot the mirror@expose corrections
tmp(1).corr = corr1;
tmp(2).corr = corr2;
bmmo_kt_compare_mirror_plots(tmp, {name1, name2});