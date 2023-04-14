function options = bmmo_get_xy_shift(mli, options)
%function options = bmmo_get_xy_shift(mli, options)
%
% This function determines the field shifts (ml -> expinfo) for field 
% reconstruction
%
% Input :
% mli    : input ml structure
% options: existing options structure
%
% Output :
% options: input options structure containing the shifts found in mli

%[xc xf; xc xf]
options.x_shift = [0, 0; 0, 0];
%[yc yf; yc yf]
options.y_shift = [0, 0; 0, 0];

options.WH.l1_shift_x = 0;
options.WH.l1_shift_y = 0;
options.WH.l2_shift_x = -0.12e-3;
options.WH.l2_shift_y = 0.36e-3;

% build target layouts per layer
mlo = bmmo_construct_layout_from_ml(mli, options);

for ilayer = 1:length(mlo)
    options.x_shift(ilayer,2) = round(mean(unique(mli.wd.xf) - unique(mlo(ilayer).wd.xf))*1e6)/1e6;
    options.y_shift(ilayer,2) = round(mean(unique(mli.wd.yf) - unique(mlo(ilayer).wd.yf))*1e6)/1e6;
end