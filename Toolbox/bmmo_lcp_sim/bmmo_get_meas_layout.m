function mlo =  bmmo_get_meas_layout(mli)
% function mlo =  bmmo_get_meas_layout(mli)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%
% Remove the edge from ml structure such that the number valids is same
% as in the measurement layout (same as customer data)
%
% Input:
% mli: ml structure
%
% Output:
% mlo: ml structure with edge removed such that valids for 2L is 7762 &
% 1L is 6126 (before WEC & outlier removal)


MEAS_LAYOUT_RADIUS = 0.148;
mlo = ovl_remove_edge(mli, MEAS_LAYOUT_RADIUS);

end