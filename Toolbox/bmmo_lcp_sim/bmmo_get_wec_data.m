function list = bmmo_get_wec_data(ml)
% function list = bmmo_get_wec_data(ml)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%
list = arrayfun(@sub_get_element, ml.wd.xw, ml.wd.yw, ml.layer(1).wr(1).dx, ml.layer(1).wr(1).dy);


function list = sub_get_element(x, y, dx, dy)

list.elt.NominalPosition.X = sprintf('%.7f', x * 1e3);
list.elt.NominalPosition.Y = sprintf('%.7f', y * 1e3);

if ~isnan(dx) && ~isnan(dy)
    list.elt.PositionError.X = sprintf('%.3f', dx * 1e9);
    list.elt.PositionError.Y = sprintf('%.3f', dy * 1e9);
    list.elt.ErrorValidity.X = 'true';
    list.elt.ErrorValidity.Y = 'true';
else
    list.elt.PositionError.X = '0.000';
    list.elt.PositionError.Y = '0.000';
    list.elt.ErrorValidity.X = 'false';
    list.elt.ErrorValidity.Y = 'false';
end



