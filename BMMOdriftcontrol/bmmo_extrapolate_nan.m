function [ml_out] = bmmo_extrapolate_nan(ml_in, type)
%function [ml_out] = bmmo_extrapolate_nan(ml_in, type)
%
% The function extrapolates the NaNs of given ml structure using scatterdInterpolatant
%
% Input:
%  ml_in: ml structure
%
% Optional Input:
% type: type of extrapolation method, default being 'natural'
%
% Output:
%  ml_out: ml_in with extrapolated NaNs

if nargin < 2
    type='natural';
end

ml_out = ml_in;

for lay = 1:ml_in.nlayer
    for waf = 1:ml_in.nwafer
        not_nans = find(~isnan(ml_in.layer(lay).wr(waf).dx));
        nans = find(isnan(ml_in.layer(lay).wr(waf).dx));
        Fx = scatteredInterpolant(ml_in.wd.xw(not_nans), ml_in.wd.yw(not_nans), ml_in.layer(lay).wr(waf).dx(not_nans), type);
        Fy = scatteredInterpolant(ml_in.wd.xw(not_nans), ml_in.wd.yw(not_nans), ml_in.layer(lay).wr(waf).dy(not_nans), type);
        
        ml_out.layer(lay).wr(waf).dx(nans) = Fx(ml_in.wd.xw(nans), ml_in.wd.yw(nans));
        ml_out.layer(lay).wr(waf).dy(nans) = Fy(ml_in.wd.xw(nans), ml_in.wd.yw(nans));
    end
end

end

