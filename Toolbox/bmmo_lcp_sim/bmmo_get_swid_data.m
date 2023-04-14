function [ml_wid_up, ml_wid_down, kt_struct] = bmmo_get_swid_data(wafers_in, kt_struct)
% function [ml_wid_up, ml_wid_down] = bmmo_get_swid_data(wafers_in)
%
% Get two ml structures with the WID_UP and WID_DOWN marks from a
% KT_wafers_in file
%
% Input: 
%   wafers_in: full path of KT_wafers_in file
%
% Output:
%   ml_wid_up: ml structure with WID_UP marks encoding SWID per wafer
%   ml_wid_down: ml structure with WID_DOWN marks encoding SWID per wafer
%
% 20160331 SBPR Creation

% options for bmmo_KT_2_ml
USE_LAYOUT = 0; % don't use an input layout
ROUNDING = 7;   % round marks to nearest 1e-7 m to get layout

% map marks in KT_wafers_in to layout
% layout derived by rounding input to nearest 1e-7
% offsets are difference with layout
if nargin < 2
    [ml_marks, kt_struct] = bmmo_KT_2_ml(wafers_in, USE_LAYOUT, ROUNDING, 'BMMO_WID', 'NVSM-X');
else
    [ml_marks, kt_struct] = bmmo_KT_2_ml(wafers_in, USE_LAYOUT, ROUNDING, 'BMMO_WID', 'NVSM-X', kt_struct);
end
    
% Separate the up and down marks into two structures
ml_wid_up = sub_get_ml_subset(ml_marks, ml_marks.wd.yw > 0);
ml_wid_down = sub_get_ml_subset(ml_marks, ml_marks.wd.yw < 0);


function mlo = sub_get_ml_subset(mli, index)

mlo = mli;

mlo.wd.xw = mli.wd.xw(index);
mlo.wd.yw = mli.wd.yw(index);
mlo.wd.yf = mli.wd.yf(index);
mlo.wd.xf = mli.wd.xf(index);
mlo.wd.xc = mli.wd.xc(index);
mlo.wd.yc = mli.wd.yc(index);

mlo.nfield = length(unique([mlo.wd.xc mlo.wd.yc], 'rows'));

for iw = 1:mli.nwafer
   mlo.layer.wr(iw).dx = mli.layer.wr(iw).dx(index);
   mlo.layer.wr(iw).dy = mli.layer.wr(iw).dy(index);
   
   % replace zero dx with NaNs: will prevent writing unnecessary marks to
   % ADELmetrology
   zero_dx = mlo.layer.wr(iw).dx == 0;
   mlo.layer.wr(iw).dx(zero_dx) = NaN;
   mlo.layer.wr(iw).dy(zero_dx) = NaN;
end

