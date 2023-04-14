function figs = inputAndActuatedCorrections(inputStruct, sbcOut, scale)

import BMMO_XY.populationTooling.plots.waferDataMapPlot

% Input argument handeling
if ~exist('scale', 'var')
    scale = 0;
end

% Process the input struct
[mlo, options] = bmmo_process_input(inputStruct);

% Calculate the NXE:3600D SP19 actuated SBC fingerprint
[fp_struct, ~] = bmmo_apply_SBC_to_ml_inline_SDM(ovl_combine_wafers(mlo, 1:2), sbcOut, 1, options);

% Plot the input
figs = waferDataMapPlot(mlo, 'Controlled overlay', 'scale', scale);

% Plot the actuated corrections
figs = [figs, waferDataMapPlot(fp_struct.TotalSBCcorrection, 'NXE:3600D actuated SBC fingerprint', 'subTitle', 'Chuck', 'scale', scale)];

end
