function bmmo_kt_compare_sbc_corrections(corr1, corr2, name1, name2, factor )
% function bmmo_kt_compare_sbc_corrections(corr1, corr2, name1, name2, factor )
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%


if factor < 0
    name2 = [name2 ' (inverted)'];
end

% first apply the factor to corr2, overloading bmmo_apply_time_filter
options.filter_coefficients.MI = 1;
options.filter_coefficients.KA = 1;
options.filter_coefficients.BAO = 1;
options.filter_coefficients.WH = 1;
options.filter_coefficients.INTRAF = 1;
options.chuck_usage.chuck_id_used = [1 2];

corr2 = bmmo_apply_time_filter(corr2, options, factor);



% plot the mirror@expose corrections
tmp(1).corr = corr1;
tmp(2).corr = corr2;
bmmo_kt_compare_mirror_plots(tmp, {name1, name2});

% plot the KA fingerprints
for ic = 2:-1:1
    ka1(ic) = ovl_convert_ka2tlg(corr1.KA.grid_2de(ic));
    ka2(ic) = ovl_convert_ka2tlg(corr2.KA.grid_2de(ic));
end
bmmo_kt_plot_4_fps(ka1, name1, options);
bmmo_kt_plot_4_fps(ka2, name2, options);

% plot BAO
bmmo_kt_plot_compare_bao(corr1, corr2, name1, name2);


% plot INTRAF
for ic = 2:-1:1
    intra1(ic) = bmmo_kt_intra_fp(corr1, name1, ic);
    intra2(ic) = bmmo_kt_intra_fp(corr2, name2, ic);
end
bmmo_kt_plot_4_fps(intra1, 'INTRAF', options);
bmmo_kt_plot_4_fps(intra2, 'INTRAF', options);


