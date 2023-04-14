function mlo = bmmo_construct_wh_fp(mli, options)
% function mlo = bmmo_construct_wh_fp(mli, options)
% 
% This function calculates the Wafer heating(WH) fingerprint from given K
% factors(k1~k20 except k13 and k20) per field. 
% 
% Input: 
% mli : input ml struct 
% options : BMMO/BL3 default options structure 
%
% Output:
%  mlo : WH fingerprint converted from the given K-factors. Single layer and
%  single wafer. The number of wafers, fields, marks should agree
%  with those in the input ml struct, mli. 
%
% For details of the model and definitions of in/out interfaces, refer to
% D000810611 EDS BMMO NXE drift control model

if isfield(options, 'WH') & isfield(options.WH, 'use_input_fp') & options.WH.use_input_fp   
    
    % use the input wh fp data
    mlo = options.WH.fp;
else

    % Get a field from the input layout to supply intrafield coordinates
    ml = ovl_get_fields(ovl_get_wafers(ovl_get_layers(mli, 1),1),1);
    x_f = ml.wd.xf;
    y_f = ml.wd.yf; 

    % Build 18par design matrices for x and y
    D_x =[ones(size(x_f)), x_f, y_f, x_f.^2, x_f.*y_f, y_f.^2, x_f.^2.*y_f, x_f.*y_f.^2, y_f.^3];
    D_y =[ones(size(y_f)), y_f, x_f, y_f.^2, y_f.*x_f, x_f.^2, y_f.^3, y_f.^2.*x_f, y_f.*x_f.^2];             
    D_x = repmat(D_x, mli.nfield, 1);
    D_y = repmat(D_y, mli.nfield, 1);

    % Specify which Kfactors apply to x and y
    x_factors = [1:2:11 14:2:18]; % Odd K-numbers except K13
    y_factors = [2:2:12 13:2:17]; % Even K-numbers except K20

    mlo = ovl_get_wafers(mli, []);
    mlo_tmp = ovl_get_wafers(mli, 1);
    for iwafer = 1:mli.nwafer

       % Get a matrix of the K-factor values for this wafer
       Kmatrix = bmmo_pars_to_k_factor_matrix(options.WH_K_factors.wafer(iwafer).field, mli.nmark, mli.nfield);
       
       % Set all NaNs to zero: they will contaminate the entire wafer
       % otherwise
       Kmatrix(isnan(Kmatrix)) = 0;
       
       % Kmatrix is now an 18 X (nmark * nfield) matrix
       % Reshape to two (nmark * nfield) X 9 matrices for X and Y
       x_Kfactors = Kmatrix(x_factors, :)';
       y_Kfactors = Kmatrix(y_factors, :)';

       % multiply
       mlo_tmp.layer.wr.dx = sum(D_x .* x_Kfactors, 2);
       mlo_tmp.layer.wr.dy = sum(D_y .* y_Kfactors, 2);

       %mlo_tmp = ovl_remove_edge(mlo_tmp, options.edge_clearance);
       mlo = ovl_combine_wafers(mlo, mlo_tmp);  
    end
    
end  
