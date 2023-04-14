function  ovlrep_KPI3_4 = bmmo_parse_KPI3_4_jobrep(jobrep_path)
% function  ovl = bmmo_parse_KPI3_4_jobrep(jobrep)
%
%Parses in the Overaly Monitor job report, such that the structure is same 
%as the output of bmmo_calc_KPI3_4
%
% Input:
% jobrep_path: filepath of the Overaly monitor job report
%
%Output:
%ovlrep_KPI3_4 : Interfield and Intrafield Overaly monitror KPIs

xml_data = xml_load(jobrep_path);

for ic = 1:2
    monitor_kpis(ic) = xml_data.Results.KpisPerClassList(ic).KpisPerClass.MonitorData;
    
    ovlrep_KPI3_4.inter.to_ref(ic) = sub_get_metrics(monitor_kpis(ic).DeltaToReference.InterField);
    ovlrep_KPI3_4.inter.to_prev(ic)= sub_get_metrics(monitor_kpis(ic).DeltaToPrevious.InterField);
    ovlrep_KPI3_4.intra.to_ref(ic) = sub_get_metrics(monitor_kpis(ic).DeltaToReference.IntraField);
    ovlrep_KPI3_4.intra.to_prev(ic)= sub_get_metrics(monitor_kpis(ic).DeltaToPrevious.IntraField);
end


function out = sub_get_metrics(stat)

out.ox100   =   str2double(stat.X.Max.Value)*1e-9;
out.ox997   =   str2double(stat.X.('Max99.7').Value)*1e-9;
out.oxm3s   =   str2double(stat.X.M3s.Value)*1e-9;

out.oy100   =   str2double(stat.Y.Max.Value)*1e-9;
out.oy997   =   str2double(stat.Y.('Max99.7').Value)*1e-9;
out.oym3s   =   str2double(stat.Y.M3s.Value)*1e-9;