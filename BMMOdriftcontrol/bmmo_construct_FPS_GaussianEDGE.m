function FP_Edge = bmmo_construct_FPS_GaussianEDGE(ml, options)
% function FP_Edge = bmmo_construct_FPS_GaussianEDGE(ml, options)
%
% The function generates the raw Clamp edge fingerprint for the combined model
%
% Input:    
%  ml: input ml structure
%  options: BL3 options
%
% Output: 
%  FP_Edge: Gaussian Edge fingerprint (1 x N (=# of nodes) cell array of ml structs}

dummy = ml;

% define coordinates
x = dummy.wd.xw;
y = dummy.wd.yw;
rwn = hypot(x,y);
thwn = atan2( y, x );

for i_base = 1:length(options.GaussianEdge_nodes)
    A_gaussian = phi_gaussian( rwn- options.GaussianEdge_nodes(i_base),options.GaussianEdge_const);
    
    FP_Edge{i_base} = dummy;
    FP_Edge{i_base}.layer.wr.dx = A_gaussian .* cos( thwn )*1e-9;
    FP_Edge{i_base}.layer.wr.dy = A_gaussian .* sin( thwn )*1e-9;
end

function u = phi_gaussian(r, const);       u=exp(-0.5*r/0.150.*r/0.150/(const*const));                  % const = gaussian width
