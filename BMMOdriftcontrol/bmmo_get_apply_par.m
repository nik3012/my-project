function apply_par = bmmo_get_apply_par(coeff, varargin)
% function apply_par = bmmo_get_apply_par(coeff, varargin)
%
% Assign ovl parameter names to the coefficients (coeff) based on BAO model 
%
% Input:
%  coeff: coefficients generated after fitting (bmmo_fit_parms)
%  
% Optional Inputs:
%   varargin: a variable number (possibly 0) of parameter names and
%            options, including the following:
%           '10par': fit 10par
%           '6par': fit 6par
%           'tx', 'ty', etc: parameters to fit
% Output:
%  apply_par: coeff with parameter names 

varlist = varargin;
varlist = bmmo_flatten_cell(varlist);

parnames = {};
nvarargs = length(varlist);
numpar = 0;

for ivar = 1:nvarargs
    % parse the arguments
    % NB We don't check for duplicates!
    switch(lower(varlist{ivar}))
        case 'xonly'
            %do nothing
        case 'yonly'
            %do nothing
        case '18par'
            parnames = sub_18parlist;
            numpar = 18;
        case '20par'
            parnames = sub_20parlist;
            numpar = 20;
        case '33par'
            parnames = sub_33parlist;
            numpar = 33;
        case '35par'
            parnames = sub_35parlist;
            numpar = 35;  
        case '10par'
            parnames = sub_10parlist;
            numpar = 10;
        case '6par'
            parnames = sub_6parlist;
            numpar = 6;
        otherwise
            parnames{numpar + 1} = lower(varlist{ivar});
            numpar = numpar + 1;
    end
end


for ipar = 1:numpar
    apply_par.(parnames{ipar}) = coeff(ipar);
end


%% below is copied from bmmo_get_design_matrix. TODO make this more rigorous
function eighteenparlist = sub_18parlist

eighteenparlist = {'tx','ty','mx','my','rx','ry','d2','k8','k9','k10','bowxf','bowyf','mag3y','accx','accy','cshpx','cshpy','flw3x'};

function twentyparlist = sub_20parlist

twentyparlist = {'tx','ty','mx','my','rx','ry','d2','k8','k9','k10','bowxf','bowyf','mag3y','accx','accy','cshpx','cshpy','flw3x', 'd3', 'flw3y'};

function thirtythreeparlist = sub_33parlist

thirtythreeparlist = [sub_18parlist() {'k22','k24','k25','k26','k27','k29','k32','k34','k36','k37','k39','k41','k46','k48','k51'}];

function thirtyfiveparlist = sub_35parlist

thirtyfiveparlist = [sub_33parlist() {'d3', 'flw3y'}];

function tenparlist = sub_10parlist

tenparlist = {'tx', 'ty', 'rs','ra','ms', 'ma', 'rws', 'rwa', 'mws', 'mwa'};

function sixparlist = sub_6parlist

sixparlist = {'tx', 'ty', 'rws', 'rwa', 'mws', 'mwa'};

