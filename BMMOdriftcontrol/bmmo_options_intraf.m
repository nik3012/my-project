function options = bmmo_options_intraf(options_in, order)
%function options = bmmo_options_intraf(options_in, order)
%
% This function will update intrafield model options to match the model
% order. If not provided, the model order in options_in is used.
% if not then defaults to 5th order.
% NOTE: It does change/set the options.INTRAF values used in for example
% outlier removal and fixing of NaN.
%
% Input 
% options_in :  existing options structure
% order :       intrafield model order (3 or 5)
%
% Ouput 
% options:      parsed options structure with updated intraf parameters

if nargin<2
    if isfield(options_in, 'intraf_actuation_order')
       order = options_in.intraf_actuation_order ;
    else
       order = 5;
    end
end

options = options_in;
options.intraf_actuation_order = order;

if order == 3
    % Following option values are all for third order actuation modelling
    % CET parameters are 18par, which is full 20par minus 'd3', 'flw3y'
    options.intraf_CETpar.name = {'tx','ty','mx','my','rx','ry','d2','k8','k9','k10',...
        'bowxf','bowyf','mag3y','accx','accy','cshpx','cshpy','flw3x'};
    options.intraf_CETpar.scaling = [ 1e1*ones(1,6) 1e3*ones(1,6) 1e5*ones(1,6)];  % FP Scaling to make the matrix elements to be O(10^(-1))~O(1)
    % all 20parameters
    options.intraf_CETparfull.name = {'tx','ty','mx','my','rx','ry','d2','k8','k9','k10',...
        'bowxf','bowyf','d3','mag3y','accx','accy','cshpx','cshpy','flw3x','flw3y'};
    % field name for model_results.(Intra_NCE fields).INTRAF_18par_NCE
    options.intraf_nce_modelresult.name = 'INTRAF_18par_NCE';
    % field name for kpi.Intra_18par_NCE.(fields)
    options.intraf_nce_kpi.name = 'Intra_18par_NCE';
    % field name for kpi.correction.(fields).intra_18_par 
    options.intraf_corr_par.name = 'intra_18_par';
    % model name for use with bmmo_fit_model
    options.intraf_fitmodel = '18par';
    options.intraf_fitmodel_all = '20par';
    % k-factors to report in hoc_pi_structure (k7-k20)
    options.intraf_hoc_pi.kfactors = {'d2','k8','k9','k10','bowxf','bowyf',...
        'd3','mag3y','accx','accy','cshpx','cshpy','flw3x','flw3y'};
elseif order == 5
    % Following option values are all for fifth order actuation modelling
    % CET parameters are 33par, which is full 35par minus 'd3', 'flw3y'
    options.intraf_CETpar.name = {'tx','ty','mx','my','rx','ry','d2','k8','k9','k10',...
        'bowxf','bowyf','mag3y','accx','accy','cshpx','cshpy','flw3x','k22',...
        'k24','k25','k26','k27','k29','k32','k34','k36','k37','k39','k41','k46','k48','k51'};
    options.intraf_CETpar.scaling = [ 1e1*ones(1,6) 1e3*ones(1,6) 1e5*ones(1,6) 1e7*ones(1,6) ...
        1e9*ones(1,6) 1e11*ones(1,3)];  % FP Scaling to make the matrix elements to be O(10^(-1))~O(1)
    % all 35 parameters
    options.intraf_CETparfull.name = {'tx','ty','mx','my','rx','ry','d2','k8','k9','k10',...
        'bowxf','bowyf','d3','mag3y','accx','accy','cshpx','cshpy','flw3x','flw3y','k22',...
        'k24','k25','k26','k27','k29','k32','k34','k36','k37','k39','k41','k46','k48','k51'};
    % field name for model_results.(Intra_NCE fields).INTRAF_18par_NCE
    options.intraf_nce_modelresult.name = 'INTRAF_33par_NCE';
    % field name for kpi.Intra_18par_NCE.(fields)
    options.intraf_nce_kpi.name = 'Intra_33par_NCE';
    % field name for kpi.correction.(fields).intra_33_par 
    options.intraf_corr_par.name = 'intra_33_par';
    % model name for use with bmmo_fit_model
    options.intraf_fitmodel = '33par';
    options.intraf_fitmodel_all = '35par';
    % k-factors to report in hoc_pi_structure (k7-k20)
    options.intraf_hoc_pi.kfactors = {'d2','k8','k9','k10','bowxf','bowyf',...
        'd3','mag3y','accx','accy','cshpx','cshpy','flw3x','flw3y','k22',...
        'k24','k25','k26','k27','k29','k32','k34','k36','k37','k39','k41','k46','k48','k51'};
else
    error('Intrafield corrections order provided is not valid: %s. Supported orders are 3 and 5.', num2str(order))
end
