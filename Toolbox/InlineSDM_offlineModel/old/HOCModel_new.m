function [mlHocRes, mlFieldHocCorr, mlHocFad, mlHocResSRR] = HOCModel_new(mlDisto, SDMModel)

% new version using model structure; not backward compatible (yet)
% exports fading instead of hoc parameters
% input arguments:
% SDMModel.filter       : 'none', '33par', 'order5', 'spline'
% SDMModel.actuation    : '3600D', '3600DES', '3400C', '3400B', 'PLAYBACK'
% SDMModel.poly2spline  : 1, 0 (true, false)
% SDMModel.playback     : 1, 0 (true, false)
% mlDisto               : ffp for one chuck, in ml format, system part only
%


if nargin<2
    SDMModel.filter      = 'spline';
    SDMModel.actuation   = '3600D';
    SDMModel.poly2spline = 0;
    SDMModel.playback    = 0;
end

switch SDMModel.filter
    case 'spline'
        mlDistoFiltered = ovl_cet_model(mlDisto, 'VERSION_4', 'return_corrections',true, 'actuation_model', 'spline(4,4)', 'intra_constr_max_order',2, 'bnd_constr_order',[]);
        mlResfilter     = ovl_sub(mlDisto, mlDistoFiltered);
    case 'order5uc'
        mlDistoFiltered = ovl_cet_model(mlDisto, 'FIFTH_ORDER', 'return_corrections',true,'unicom_compensation', true);
        mlResfilter     = ovl_sub(mlDisto, mlDistoFiltered); 
    case 'order5'
        mlDistoFiltered = ovl_cet_model(mlDisto, 'FIFTH_ORDER', 'return_corrections',true);
        mlResfilter     = ovl_sub(mlDisto, mlDistoFiltered);     
    case '33par'
        options = bl3_default_options_structure;
        [mlResfilter, intra_par_HOC] = ovl_model(mlDisto, options.CET33par.name, 'perwafer', 'perfield');
        mlDistoFiltered = ovl_sub(mlDisto, mlResfilter);
    case 'none'
        mlDistoFiltered = mlDisto;
    otherwise
        disp('Warning : no valid filter type supplied.');
        mlDistoFiltered = mlDisto;
end

switch SDMModel.actuation  
    case '3600DES'
        [mlHocResSRR, cs] = ovl_cet_model(mlDistoFiltered, 'VERSION_3');
        CetModel = 'VERSION_3';
        if SDMModel.poly2spline
            cs = cs.poly2spline();
        end
    case '3600D'
        [mlHocResSRR, cs] = ovl_cet_model(mlDistoFiltered, 'VERSION_5');
        CetModel = 'VERSION_5';
        if SDMModel.poly2spline
            cs = cs.poly2spline();
        end
    case '3400C'
        [mlHocResSRR, cs] = ovl_cet_model(mlDistoFiltered, 'FIFTH_ORDER');
        CetModel = 'FIFTH_ORDER';
        if SDMModel.poly2spline
            cs = cs.poly2spline();
        end    
    case '3400B'
        [mlHocResSRR, cs] = ovl_cet_model(mlDistoFiltered, 'THIRD_ORDER');
        CetModel = 'THIRD_ORDER';
        if SDMModel.poly2spline
            cs = cs.poly2spline();
        end
        % note: not sure if mlHocFad contains other data than 0 
        % VERSION_5 is fading aware, not sure about others models.
    otherwise
       disp('error : the actuation model type does not exist.');   
end

if SDMModel.playback
    [mlHocRes, ~, mlHocFad] = ovl_cet_model(mlDisto, cs, 'PLAYBACK');
else
    [mlHocRes, ~, mlHocFad] = ovl_cet_model(mlDisto, cs, CetModel);
end

mlFieldHocCorr = ovl_sub(mlDisto, mlHocRes);

