function [figs, wdms] = correctionsAndResiduals(wdmXmlPath, scale)

import BMMO_XY.populationTooling.plots.waferDataMapPlot

% Input argument handeling
if ~exist('scale', 'var')
    scale = 0;
end

% Process the xml file
wdms = bmmo_convert_wdm_to_ml(wdmXmlPath, 0, 1, 1);

% Plot the corrections
figs = waferDataMapPlot(wdms.total_filtered_TotalSBCcorrection, 'Total SBC Correction', 'subTitle', 'Chuck', 'scale', scale);

% Plot the self correct residuals
figs = [figs, waferDataMapPlot(ovl_add(wdms.total_unfiltered_TotalSBCcorrection(1), wdms.uncontrolled_meas(1)), 'Self correct residual', 'subTitle', 'Chuck 1', 'scale', scale)];
figs = [figs, waferDataMapPlot(ovl_add(wdms.total_unfiltered_TotalSBCcorrection(2), wdms.uncontrolled_meas(2)), 'Self correct residual', 'subTitle', 'Chuck 2', 'scale', scale)];

end
