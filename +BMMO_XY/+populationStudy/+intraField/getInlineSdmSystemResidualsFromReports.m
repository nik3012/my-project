function [partitionedSystemResiduals, partitionedDates] = getInlineSdmSystemResidualsFromReports(inlineSdmReports, lotDates)
% [partitionedSystemResiduals, partitionedDates] = getInlineSdmSystemResidualsFromReports(inlineSdmReports, lotDates)
%
% Function to extract the system residuals from the inlineSDM report for
% chuck 1 and chuck 2. The residuals and the job dates are partitioned in sets separated by setup actions.
%
% Input arguments: 
% - inlineSdmReports           [ array of structs ]   Array of structs containing the
%                                                       inlineSdmReports for the
%                                                       respective mls.
% - lotDates                   [ array of datetimes ] Dates of the jobs
%
% Output arguments:
% - partitionedSystemResiduals [ array of structs ]   Array of structs
%                                                       containing the system residuals of the inlineSdm reports of the
%                                                       respective mls. The data is partitioned in sets in between setup actions.
% - partitionedDates           [ array of datetimes ] Array of datetimes containing the dates of the
%                                                       jobs partitioned between setup actions.
%
%

import BMMO_XY.populationTooling.tools.*
import BMMO_XY.populationStudy.intraField.getInlineSdmReportsFromMls

% Extract the KPIs
systemKpi = extractInlineSdmSystemOvlKpis(inlineSdmReports);

% Get setup lotDates
[~, setupIndexChk1] = estimateSetupActionDatesFromKpis({systemKpi.chk1.x, systemKpi.chk1.y}, lotDates, 8);
[~, setupIndexChk2] = estimateSetupActionDatesFromKpis({systemKpi.chk2.x, systemKpi.chk2.y}, lotDates, 8);
setupIndex          = unique(sort([setupIndexChk1, setupIndexChk2]));

% Extract the system residual per chuck
systemResiduals     = extractArrayFromStruct(inlineSdmReports, 'hoc.mlHocRes');
systemResidualsChk1 = arrayfun(@(x) ovl_combine_wafers(systemResiduals(x), 1), 1 : length(systemResiduals));
systemResidualsChk2 = arrayfun(@(x) ovl_combine_wafers(systemResiduals(x), 2), 1 : length(systemResiduals));

% Partition the system residual data
[partitionedSystemResidualsChk1, partitionedDatesChk1] = partitionDataSetupActionDates(systemResidualsChk1, lotDates, setupIndex);
[partitionedSystemResidualsChk2, partitionedDatesChk2] = partitionDataSetupActionDates(systemResidualsChk2, lotDates, setupIndex);

% Provide the output cell arrays
partitionedSystemResiduals = {partitionedSystemResidualsChk1, partitionedSystemResidualsChk2};
partitionedDates           = {partitionedDatesChk1, partitionedDatesChk2};

end