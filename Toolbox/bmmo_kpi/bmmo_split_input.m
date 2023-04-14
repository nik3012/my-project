function ml3 = bmmo_split_input(mli)
% function ml3 = bmmo_split_input(mli)
%
% Split BMMO-NXE input structure into several one-wafer-per-chuck
% components
%

current = 1;
for jj = 1:length(mli)
    nsplit = mli(jj).nwafer/2;
    for ii = 1:nsplit
        ml3(current) = bmmo_get_wafers(mli(jj), [1 2] + (2 * (ii-1)));
        current = current + 1;
    end
end