function [imask, iloc] = bmmo_wd_ismember(xi, yi, xt, yt, tolerance_exponent)
% function [imask, iloc] = bmmo_wd_ismember(xi, yi, xt, yt, tolerance_exponent)
%
% Map the overlay data in layout (xi,yi) to target layout (xt, yt), given a
% tolerance exponent of difference on the nominal mark positions
%
% Input:
%  xi, yi: input x and y layout
%  xt, yt: target x and y layout
%  tolerance_exponent: (positive) exponent of tolerance to which
%      mark positions will be rounded marks in each structure will be rounded
%      to the nearest (10^(-tolerance_exponent))m before testing for equality
%
% Note: after rounding to the nearest tolerance, the layout marks must
% correspond exactly

exptol = 10^tolerance_exponent;

% round input and output to nearest tolerance;
xi = (round(xi .* exptol)) ./ exptol;
yi = (round(yi .* exptol)) ./ exptol;
xt = (round(xt .* exptol)) ./ exptol;
yt = (round(yt .* exptol)) ./ exptol;


% Get the intersection between the two layouts
xw_yw = xi + 1i*yi;
xwo_ywo = xt + 1i*yt;

% R13 compatibility note:
% in Matlab R13, ismember returns as second argument a vector containing
% the *highest* indices in xwo_ywo for each element in xw_yw that occurs in
% xwo_ywo. Later Matlab versions return the *lowest* indices. However,
% since the marks in xwo_ywo are unique, this does not make a difference.
[imask, iloc] = ismember(xw_yw, xwo_ywo);