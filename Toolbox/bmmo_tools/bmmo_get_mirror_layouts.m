function [x_mirror_layout, y_mirror_layout] = bmmo_get_mirror_layouts(input_struct)
% function [x_mirror_layout, y_mirror_layout] = bmmo_get_mirror_layouts(input_struct)
%
% Given BMMO-NXE input struct, return the layouts used to model mirrors
%
% Input:
%   input_struct: valid BMMO-NXE  input
%
% Output:
%   x_mirror_layout: (1*2) layout used for modelling x mirror
%   y_mirror_layout: (1*2) layout used for modelling y mirror
%
% 20171101 SBPR Creation

[mlp, options] = bmmo_process_input(input_struct);

model_results = bmmo_default_model_result(mlp, options);

for ii = 1:2
    ml_new = model_results.interfield_residual(ii);

    P = polyfit(options.Q_grid.x, options.Q_grid.y, 4);  
    x = ml_new.wd.xf;
    y_shift = polyval(P, x);

    yw_actual = ml_new.wd.yw + y_shift;
    ml_new.wd.yw = yw_actual;


        out_ml_new = bmmo_convert_layout2_7(ml_new,'x', options.fid_intrafield);
        out_ml_new = bmmo_convert_layout2_7(out_ml_new,'y', options.fid_intrafield);


        mli_MIX = bmmo_convert_layout2_7(out_ml_new,'y', options.fid_left_right_edgefield);


        mli_MIY = bmmo_convert_layout2_7(out_ml_new,'x', options.fid_top_bottom_edgefield);


    x_mirror_layout(ii) = mli_MIX;
    y_mirror_layout(ii) = mli_MIY;

end