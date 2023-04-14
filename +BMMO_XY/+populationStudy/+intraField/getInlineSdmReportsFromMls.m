function inlineSdmReports = getInlineSdmReportsFromMls(mls, configuration)
% inlineSdmReports = getInlineSdmReportsFromMls(mls, configuration)
%
% Function to run inlineSdm on a set of mls and obtain the respective
% inlineSdmModel reports.
%
% Input arguments:
% - mls              [ array of structs]      Structs containing the mls of different jobs 
% - configuration    [ function handle ]      configuration of the machine
%                                               for running the inlineSdm model
%
% Output arguments:
% - inlineSdmreports [ array of structs ]      Array of structs containing the
%                                                inlineSdmReports for the
%                                                respective mls


% Get the inlineSDM model
% BEWARE, this is a handle class so don't modify it!
inlineSdmConfiguration = configuration;
inlineSdmModel         = inlineSdmConfiguration.getConfigurationObject('InlineSdmModel');

% Apply inlineSDM
for index = 1 : length(mls)
    inlineSdmModel.mlDistoIn   = mls(index);
    inlineSdmModel.calcReport;
    inlineSdmReports(index)    = inlineSdmModel.report;
end

end 