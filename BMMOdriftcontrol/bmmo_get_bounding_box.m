function [bbx, bby] = bmmo_get_bounding_box(ml_intraf)
% function [bbx, bby] = bmmo_get_bounding_box(ml_intraf)
%
% The function returns cornerpoints of two bounding boxes around intrafield
% bb1 at 1*pitch outside provided field
% bb2 at 2*pitch outside provided field
% for a single mark field (1x1) the bounding box returns NaN values
%
% Input:
%  ml_intraf: single field ml structure (eg: FFP processed to ml struct)
%
% Output: 
%  bbx: 8 x coordinates
%  bby: 8 y coordinates
%
% Example field in (f), bb corner points 1...8
%
%    6.............8
%    ...............
%    ..2.........4..
%    ...............
%    ....f.f.f.f....
%    ...............
%    ....f.f.f.f....
%    ...............
%    ....f.f.f.f....
%    ...............
%    ..1.........3..
%    ...............
%    5.............7
%

max_xf = max(ml_intraf.wd.xf);
max_yf = max(ml_intraf.wd.yf);
pitchx = (max(ml_intraf.wd.xf) - min(ml_intraf.wd.xf))/(length(unique(ml_intraf.wd.xf)) - 1);
pitchy = (max(ml_intraf.wd.yf) - min(ml_intraf.wd.yf))/(length(unique(ml_intraf.wd.yf)) - 1);
rx1    = max_xf + pitchx;
rx2    = rx1 + pitchx;
ry1    = max_yf + pitchy;
ry2    = ry1 + pitchy ;
bbx    = [-rx1 -rx1 rx1 rx1 -rx2 -rx2 rx2 rx2];
bby    = [-ry1 ry1 -ry1 ry1 -ry2 ry2 -ry2 ry2];