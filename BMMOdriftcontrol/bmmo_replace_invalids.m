function mlo = bmmo_replace_invalids(mli, invalidation_data, val)
% function mlo = bmmo_replace_invalids(mli, invalidation_data, val)
%
% This function is used to replace invalid marks from a given mli structure
% with value from input val.
%
% Input:
%  mli: ml structure to invalidate marks
%  invalidation_data: data with x and y location of invalidated marks
%
% Optional input:
%  val: Numeric value to replace the invalid marks in mli. If not provided
%  val is set to NaN by default
%
% Output:
%  mlo: mli with invalids replaced by val

if nargin <3
    val = NaN;
end

mlo = mli;

for iw = 1:mli.nwafer
    x = reshape(invalidation_data(iw).x, [], 1);
    y = reshape(invalidation_data(iw).y, [], 1);
    
    if ~isempty(x) || ~isempty(y)
        I = knnsearch([mli.wd.xw mli.wd.yw], [x y]); 
        mlo.layer.wr(iw).dx(I) = val;
        mlo.layer.wr(iw).dy(I) = val;
    end
end

