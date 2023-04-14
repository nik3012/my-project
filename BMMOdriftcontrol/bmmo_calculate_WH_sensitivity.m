function drdl = bmmo_calculate_WH_sensitivity(options)
% function drdl = bmmo_calculate_WH_sensitivity(options)
%
% Given the report data and the empirical constants in options, calculate
% the wafer heating sensitivity drdl
%
% Input:
%   options: structure containing the following fields (all type double):
%       WH.tret:        Reticle Transmission Factor
%       WH.rir:         Wafer IR reflectance
%       WH.tir:         Wafer IR transmittance
%       WH.pdgl:        DGL Power (W)
%       WH.slip:        W/m
%       WH.a            empirical constants
%       WH.b
%        and the following structure:
%       WH.c_mapping
%           WH.c_mapping.Peuv: 1*n vector of Peuv values (double)
%           WH.c_mapping.cP:   1*n vector of c values (double)
%
% Output:
%   drdl: WH sensitivity value

tret = options.WH.tret;
rwaf = options.WH.rir;
twaf = options.WH.tir;
pdgl = options.WH.pdgl;
peuv = options.WH.slip * 0.026; % Peuv at wafer level for 100% reflective reticle
a = options.WH.a;
b = options.WH.b;
IR2EUV_old = options.Rir2euv;


% Find c from the lookup table
c = sub_get_c(options);

drdl = 1/(1-rwaf) * ((1-rwaf)*IR2EUV_old + 1/(1-twaf+c*twaf) * (b * pdgl/peuv + a * tret));


% End of main function, subfunctions below
function c = sub_get_c(options)

if options.WH.slip < options.WH.c_mapping.slip(1)
    c = options.WH.c_mapping.c(1);
elseif options.WH.slip > options.WH.c_mapping.slip(end)
    c = options.WH.c_mapping.c(end);
else
    c = interp1(options.WH.c_mapping.slip, options.WH.c_mapping.c, options.WH.slip);
end

