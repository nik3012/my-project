function bmmo_ADELmetrology_2L_to_1L(adel_metro_path_2L, zip_path_1L, name, MachineID)
% function bmmo_ADELmetrology_2L_to_1L(adel_metro_path_2L, zip_path_1L, name, MachineID)
%
% Converts a 2L ADELmetrology into a 1L ADELmetrology.
%
% Input: 
%   adel_metro_path: path to the 2L ADELmetrology file
%   zip_path_1L: BMMO zip with 1L ADELmetrology
%   name: name to give the ADELmetrology file
%   MachineID: YS MachineID to write in the ADELmetrology generated
%
% Output:
%   1L ADELmetrology generated in current working directory


input_struct_1L = bmmo_read_lcp_zip(zip_path_1L);
mlo = bmmo_process_adelmetrology(adel_metro_path_2L);

data =  strcmp({mlo.targetlabel}, 'LS_OV_RINT');

dummy_metro = ovl_combine_linear(mlo(data), NaN);
dummy_input = ovl_combine_linear(input_struct_1L, 0);
ml_metro_1L = bmmo_map_layouts(dummy_input, dummy_metro, 12);

ind = ~isnan(ml_metro_1L.layer.wr(1).dx);
fn = fieldnames(mlo.wd);
for ii = 1:length(fn)
    mlo(data).wd.(fn{ii}) = mlo(data).wd.(fn{ii})(ind);
end

for iw = 1:mlo(data).nwafer
    mlo(data).layer.wr(iw).dx = mlo(data).layer.wr(iw).dx(ind);
    mlo(data).layer.wr(iw).dy = mlo(data).layer.wr(iw).dy(ind);
end

for i=1:length(mlo)
    targetlabels{i} = mlo(i).targetlabel;
end

bmmo_write_adelmetrology(mlo, targetlabels, name, MachineID);
