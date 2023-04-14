function kpi_out = bmmo_get_ripple_kpi(ml, options, kpi_in)
% function kpi_out = bmmo_get_ripple_kpi(ml, options, kpi_in)
% This function claculates the uncontrolled ripple KPIs as mentioned in 
% D000810611 EDS BMMO NXE drift control model
%
% Input:
%  ml: controlled input with only Interfield correction (excludes previous
%   Intrafield SBC)
%  options: BMMO/BL3 option structure
%  kpi_in: KPI input structure to include the output of the function 
%
% Output:
%  kpi_out: kpi_in with uncontrolled ripple KPIs

kpi_out = kpi_in;

for ic = 1:2
    chuckstr = num2str(ic);
    wid_this_chuck = find(options.chuck_usage.chuck_id == ic);
    if isempty(wid_this_chuck)
        kpi_out.(['ovl_ripple_3s_chk' chuckstr]) = 0;
    else
        wafers_this_chuck = ovl_average(ovl_get_wafers(ovl_model(ml,'10par','perwafer'),wid_this_chuck));
        field_this_chuck = ovl_average_fields(ovl_get_fields(wafers_this_chuck, options.fid_intrafield));
        avg_col = sub_ovl_average_column(field_this_chuck);
        
        ov_chuck = ovl_calc_overlay(avg_col);
        
        kpi_out.(['ovl_ripple_3s_chk' chuckstr]) = ov_chuck.oy3sd;
    end
end

function mlo = sub_ovl_average_column(ml)

for i = 1: ml.nwafer
    mli = ovl_get_wafers(ml,i);
    fld = ovl_average(mli);
    [xc,yc,xf,yf,dxi,dyi] = ovl_concat_wafer_results(fld);
    rowlist = sort_and_collect(yf,1e-4);
    for ii =1: length(rowlist)
        rowlist(ii).dxi = nanmean_r12(dxi(rowlist(ii).id));
        dxi(rowlist(ii).id) = nanmean_r12(dxi(rowlist(ii).id));
        rowlist(ii).dyi = nanmean_r12(dyi(rowlist(ii).id));
        dyi(rowlist(ii).id) = nanmean_r12(dyi(rowlist(ii).id));
    end
    if i == 1
        mlo = ovl_distribute_wafer_results(fld,dxi,dyi);
    else
        mlo = ovl_combine_wafers(mlo,ovl_distribute_wafer_results(fld,dxi,dyi));
    end
end