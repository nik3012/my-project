function wdmsFromJobZips(zipPaths, pptTitle, pptName, pptPath)

import BMMO_XY.populationTooling.PPT
import BMMO_XY.populationStudy.wdm.*

% Initialize the PPT
ppt = PPT(pptName, pptPath);
ppt.setTitle(pptTitle);

for jobIndex = 1 : length(zipPaths)
    
    % Process the job zip
    [inputStruct, ~, sbcOut, jobReport, ~, wdmXml] = bmmo_read_lcp_zip(which(zipPaths{jobIndex}));
    jobDate             = jobReport.Results.JobIssued;
    jobType             = jobReport.Input.JobType;
    numberOfInputWafers = inputStruct.nwafer;
    
    % Get the corrections and residuals from the job zip
    [figs, ~] = correctionsAndResiduals(wdmXml, 2);
    
    % Get the input and actuated correction
    figs = [figs, inputAndActuatedCorrections(inputStruct, sbcOut, 2)];
    
    % Insert the figures into the PPT
    subTitle = [jobDate ' ' jobType];
    ppt.insertChapter(subTitle);
    ppt.insertFigures('Total SBC correction', subTitle, figs(1 : 2));
    ppt.insertFigures('Self correct residual', subTitle, figs(3 : 4));    
    for waferIndex = 1 : 2 : numberOfInputWafers
        ppt.insertFigures('Controlled overlay', subTitle, figs(4 + waferIndex : 5 + waferIndex));
    end    
    ppt.insertFigures('NXE:3600D SP19 Actuated SBC correction', subTitle, figs((end - 1) : end));

    % Cleanup
    close(figs);
    clear figs
    
end

end
