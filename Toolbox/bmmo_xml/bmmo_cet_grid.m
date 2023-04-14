function [xg, yg] = bmmo_cet_grid()

% indices of ovl_create_dummy marklayout structure
X_SPAN = 1;
Y_SPAN = 2;
X_MARKS = 3;
Y_MARKS = 4;
MM = 1e-3;

options = bmmo_default_options_structure;

x_row = (linspace(0, options.CET_marklayout(X_SPAN), options.CET_marklayout(X_MARKS)) - (options.CET_marklayout(X_SPAN) / 2)) * MM;
y_col = (linspace(0, options.CET_marklayout(Y_SPAN), options.CET_marklayout(Y_MARKS)) - (options.CET_marklayout(Y_SPAN) / 2)) * MM;

[xg, yg] = ndgrid(x_row, y_col);