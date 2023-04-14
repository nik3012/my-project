function [mlo, params] = bmmo_apply_KA(ml_KA, ml_layout, varargin)
% function [mlo, params] = bmmo_apply_KA(ml_KA, ml_layout, varargin)
%
% Created from gxy_mc_apply_KA where the type hardcoded to 'expose'. The
% function does 6par per field actuation of the given KA grid .
%
% Inputs:
%  ml_KA        : ml structure containing KA map to be applied
%  ml_layout  : ml structure containing layout to which KA map should
%                 be applied (dx & dy values are not used)
% Options:
%  img_size     : 2-element vector describing the size of the exposed field
%                 (not relevant if type is 'readout' or 'alignment')
%                 if not specified, it will be guessed based on 'type'
%
% Output:
%  mlo          : ml structure containing the correction applied based on
%                 supplied map. mlo contains as many (identical) wafers
%                 as present in layout_tlg, but applied to only one layer.
% params          parmeters per mark/field determined from ml_KA and
%                 applied to mlo

% options
options.img_size               = 'guess';
options.params                 = 'guess';
[options, args]                = getopts_r12(options, varargin{:});

% guessing
if isstr(options.img_size) & strcmp(options.img_size, 'guess')
    options.img_size       = [26 33] * 1e-3;
end
if isstr(options.params) & strcmp(options.params, 'guess')
    options.params         = {'tx', 'ty', 'ms', 'ma', 'rs', 'ra'}; % but will fallback if too little data is available (wafer edge)
end
% more validation
% validateattributes(options.img_size, {'numeric'}, {'size', [1 2]});
if ~isnumeric(options.img_size)
    error('options.img_size should be numeric');
elseif ~isequal(size(options.img_size),[1 2])
    error('options.img_size size should be [1 2]');
end

% initialize outputs
mlo                            = ovl_metro_get_subset(ml_layout, 1, 1);
mlo.layer.wr.dx                = mlo.layer.wr.dx * 0;
mlo.layer.wr.dy                = mlo.layer.wr.dy * 0;
mlo.tlgname                    = ['KA actuation - expose'];

% precompute unique values to avoid performance hit in point loop
ml_KA.xu                       = unique(ml_KA.wd.xw);
ml_KA.yu                       = unique(ml_KA.wd.yw);

% calculate the parameters per mark/field
for ifield = 1:mlo.nfield
    index = mlo.nmark * (ifield-1);
    params.field(ifield) = sub_determine_2dc_correction(ml_KA, mlo.wd.xc(index + 1), mlo.wd.yc(index + 1), options.img_size, options.params);
end

% apply the parameters to mlo
params = bmmo_add_field_positions_to_parlist(params, mlo);
mlo = ovl_model(mlo, 'apply', params);


%% ==== SUB FUNCTIONS =====================================================

function par = sub_determine_2dc_correction(ka_tlg, x, y, img_size, fitparams)

border_size = 5e-3;
grid_dist   = 5e-3;

par.tx = 0;
par.ty = 0;
par.ms = 0;
par.ma = 0;
par.rs = 0;
par.ra = 0;

xu = ka_tlg.xu; % precomputed
yu = ka_tlg.yu;
xyf = [ka_tlg.wd.xw ka_tlg.wd.yw];

% Define area of interest
xmin = x - img_size(1)/2 - border_size;
xmax = x + img_size(1)/2 + border_size;
ymin = y - img_size(2)/2 - border_size;
ymax = y + img_size(2)/2 + border_size;

xi = find(xu<=xmax & xu>=xmin);
yi = find(yu<=ymax & yu>=ymin);

if length(xi)==0 | length(yi)==0, return; end
xyi = find(xyf(:,1) >= xu(xi(1)) & xyf(:,1) <= xu(xi(end)) & ...
    xyf(:,2) >= yu(yi(1)) & xyf(:,2) <= yu(yi(end)));

ka_dx = ka_tlg.layer.wr.dx(xyi);
ka_dy = ka_tlg.layer.wr.dy(xyi);
ka_x  = ka_tlg.wd.xw(xyi);
ka_y  = ka_tlg.wd.yw(xyi);
idx_ka_nan = find(isnan(ka_dx)); % should not happen since 2DC 3300 always extrapolates and fills holes...

rel_pos     = xyf(xyi,:)-repmat([x y],size(xyi));
abs_rel_pos = abs(rel_pos);

ind_inner_x = find(abs_rel_pos(:,1) - repmat(img_size(1)/2, size(rel_pos, 1), 1) <= 0);
ind_inner_y = find(abs_rel_pos(:,2) - repmat(img_size(2)/2, size(rel_pos, 1), 1) <= 0);
ind_outer_x = find(abs_rel_pos(:,1) - repmat(img_size(1)/2, size(rel_pos, 1), 1) > 0);
ind_outer_y = find(abs_rel_pos(:,2) - repmat(img_size(2)/2, size(rel_pos, 1), 1) > 0);

dist_from_img_border(ind_outer_x,1) = abs_rel_pos(ind_outer_x,1) - img_size(1)/2;
dist_from_img_border(ind_outer_y,2) = abs_rel_pos(ind_outer_y,2) - img_size(2)/2;
dist_from_img_border(ind_inner_x,1) = 0;
dist_from_img_border(ind_inner_y,2) = 0;

% apply weighting factors
weight = prod((border_size-dist_from_img_border)/border_size, 2);

%Ex = max(xu(xi)) - min(xu(xi));
%Ey = max(yu(yi)) - min(yu(yi));

real = find(~isnan(ka_tlg.layer.wr.dx(xyi)) & ~isnan(ka_tlg.layer.wr.dy(xyi)));

% bugfix: calculate Ex and Ey based on valid points only
% (ovl_model_2dc_correction did this wrongly)
Ex = max(ka_x(real)) - min(ka_x(real));
Ey = max(ka_y(real)) - min(ka_y(real));

if length(real) ~= 0
    N = length(real);
    w = weight(real);
    
    % check for parameter fallback
    tol = 1e-8;
    fallback = 0;
    if (Ex < 2*grid_dist-tol) & (Ey < 2*grid_dist-tol)
        fallback = 2;
        fitparams = {'tx', 'ty'}; % translation only
    end
    if (Ex < 2*grid_dist-tol) | (Ey < 2*grid_dist-tol) | (length(real) < 3)
        % fallback to 4par ("sym only")
        if numel(fitparams) > 2
            fallback = 4;
            fitparams = {'tx', 'ty', 'ms', 'rs'};
        end
    end
    
    % construct design matrix
    % TODO use some core OVL linear modeling engine, like ovl_metro_model
    xf = rel_pos(real, 1);
    yf = rel_pos(real, 2);
    
    z = zeros(N,1);
    o = ones(N,1);
    
    %     Tx      Ty      Ms       Ma         Rs        Ra
    A = [[o; z] [z; o] [xf; yf] [xf; -yf] [-yf; xf] [-yf; -xf]];
    if ~ismember('ra', fitparams)
        A(:,6) = 0;
    end
    if ~ismember('ma', fitparams)
        A(:,4) = 0;
    end
    if ~ismember('rs', fitparams)
        A(:,5) = 0;
    end
    if ~ismember('ms', fitparams)
        A(:,3) = 0;
    end
    
    % Apply weight factors
    A = A .* repmat(w, 2, 6);
    
    dx = ka_tlg.layer.wr.dx(xyi(real)).* w;
    dy = ka_tlg.layer.wr.dy(xyi(real)).* w;
    
    % solve
    parvec = pinv(A) * [dx; dy];
    
    par.tx    = parvec(1);
    par.ty    = parvec(2);
    par.ms    = parvec(3);
    par.ma    = parvec(4);
    par.rs    = parvec(5);
    par.ra    = parvec(6);
end
