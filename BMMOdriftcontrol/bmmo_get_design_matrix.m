function C = bmmo_get_design_matrix(wd, options, varargin)
% function C = bmmo_get_design_matrix(wd, options, varargin)
%
% This function returns a design matrix based on the input
%
% Input:
%  wd: wafer mark coordinate structure
%        options: options containing parlist
%
% Optional Input:
%  varargin: a variable number of options and parameter names, 
%            including the following
%           'xonly': construct only x matrix (default is to construct both)
%           'yonly': construct only y matrix
%           '10par': construct 10par matrix 
%           '6par': construct 6par matrix
%           '18par': construct 18par matrix
%           '20par': construct 20par matrix (default)
%           '33par': construct 33par matrix
%           '35par': construct 35par matrix
%           'tx', 'ty' etc: parameter names
% Output:
%  C: Design matrix
%
% NB Make sure to call this function with valid parameter lists!
% NO checking is done on parameter order, duplication or validity

% create parlist if not created already
if ~isfield(options, 'parlist')
    options.parlist = bmmo_parlist;
end
    
% parse the input arguments
local_options = sub_parse_varargs(wd, options, varargin);
    
numpars = length(local_options.parlist);
C = zeros(local_options.ovl_len, numpars);

xend = 0;
if(local_options.do_x)
    xstart = 1;
    xend = length(wd.xc);
end
if(local_options.do_y)
    ystart = xend + 1;
    yend = local_options.ovl_len;
end

for ipar = 1:numpars
   if(local_options.do_x)
       C(xstart:xend, ipar) = feval(local_options.parlist{ipar}.dxfun, wd, local_options.parlist{ipar}.args);
   end
   if(local_options.do_y)
       C(ystart:yend, ipar) = feval(local_options.parlist{ipar}.dyfun, wd, local_options.parlist{ipar}.args);
   end
end


function local_options = sub_parse_varargs(wd, options, varlist)

% first, some global defaults
local_options.do_x = 1;
local_options.do_y = 1;
local_options.parlist = {};
local_options.ovl_len = length(wd.xc) + length(wd.yc);

% flatten the cell array
varlist = bmmo_flatten_cell(varlist);

nvarargs = length(varlist);
if nvarargs == 0
    % set some defaults for no input arguments
    % default is full 10par
    local_options.numargs = 10;
    local_options.parlist = sub_10parlist(options);
else
    for ivar = 1:nvarargs
        % parse the arguments
        % NB We don't check for duplicates!
        switch(lower(varlist{ivar}))
            case 'xonly'
                local_options.do_y = 0;
                local_options.do_x = 1; % in case someone sets 'yonly' too
                local_options.ovl_len = length(wd.xc);
            case 'yonly'
                local_options.do_y = 1;
                local_options.do_x = 0;
                local_options.ovl_len = length(wd.yc);
            case '10par'
                local_options.parlist = sub_10parlist(options);
            case '6par'
                local_options.parlist = sub_6parlist(options);
            case '18par'
                local_options.parlist = sub_18parlist(options);
            case '20par'
                local_options.parlist = sub_20parlist(options);
            case '33par'
                local_options.parlist = sub_33parlist(options);
            case '35par'
                local_options.parlist = sub_35parlist(options);
            otherwise
                local_options.parlist = horzcat(local_options.parlist,  {options.parlist.(lower(varlist{ivar}))});
        end
    end
    local_options.numargs = length(local_options.parlist);
end


function tenparlist = sub_10parlist(options)

tenparlist = {options.parlist.tx, options.parlist.ty, options.parlist.rs, options.parlist.ra, options.parlist.ms, ...
    options.parlist.ma, options.parlist.rws, options.parlist.rwa, options.parlist.mws, options.parlist.mwa};

function sixparlist = sub_6parlist(options)

sixparlist = {options.parlist.tx, options.parlist.ty, options.parlist.rws, ...
    options.parlist.rwa, options.parlist.mws, options.parlist.mwa};

%'18par'                 = 'tx,ty,mx,my,rx,ry,d2,k8,k9,k10,bowxf,bowyf,mag3y,accx,accy,cshpx,cshpy,flw3x'

function eighteenparlist = sub_18parlist(options)

eighteenparlist = {options.parlist.tx, options.parlist.ty, options.parlist.mx, options.parlist.my, ...
    options.parlist.rx, options.parlist.ry, options.parlist.d2, options.parlist.k8, options.parlist.k9, ...
    options.parlist.k10, options.parlist.bowxf, options.parlist.bowyf, options.parlist.mag3y, ...
    options.parlist.accx, options.parlist.accy, options.parlist.cshpx, options.parlist.cshpy, ...
    options.parlist.flw3x};

function twentyparlist = sub_20parlist(options);

twentyparlist = horzcat(sub_18parlist(options), {options.parlist.d3}, {options.parlist.flw3y});

%'33par' = 'k1,k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,k13,k14,k15,k16,k17,k18,k19,k20,k22,k24,k25,k26,k27,k29,k32,k34,k36,k37,k39,k41,k46,k48,k51'
%        = 18par + 'k22,k24,k25,k26,k27,k29,k32,k34,k36,k37,k39,k41,k46,k48,k51'
function thirtythreeparlist = sub_33parlist(options)

thirtythreeparlist = {options.parlist.tx, options.parlist.ty, options.parlist.mx, options.parlist.my, ...
    options.parlist.rx, options.parlist.ry, options.parlist.d2, options.parlist.k8, options.parlist.k9, ...
    options.parlist.k10, options.parlist.bowxf, options.parlist.bowyf, options.parlist.mag3y, ...
    options.parlist.accx, options.parlist.accy, options.parlist.cshpx, options.parlist.cshpy, ...
    options.parlist.flw3x, options.parlist.k22, options.parlist.k24, options.parlist.k25, ...
    options.parlist.k26, options.parlist.k27, options.parlist.k29, options.parlist.k32, ...
    options.parlist.k34, options.parlist.k36, options.parlist.k37, options.parlist.k39, ...
    options.parlist.k41, options.parlist.k46, options.parlist.k48, options.parlist.k51 };

function thirtyfiveparlist = sub_35parlist(options);

thirtyfiveparlist = horzcat(sub_33parlist(options), {options.parlist.d3}, {options.parlist.flw3y});
