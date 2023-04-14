function info = bmmo_getADELmetroinfo(ml, machineId)
% function info = bmmo_getADELmetroinfo(ml, machineId)
% <help_update_needed>
%
% <short description>
% input:
% output:
%
%

    if nargin < 2
        machineId = '1000';
    end

    % Header
    if ~isfield(ml, 'tlgname')
        ml.tlgname = 'unknown';
    end
    info.Header.Title                = ml.tlgname;
    info.Header.MachineID                = '0000';
  
    info.Header.MachineType          = 'unknown';
    info.Header.SoftwareRelease      = 'unknown';
    info.Header.CreatedBy            = 'Matlab (bmmo_getADELmetroinfo)';

   
    start_time = now;
    info.Header.CreateTime           = datestr(start_time,'yyyy-mm-ddTHH:MM:SS');
    info.Header.Comment             = ['Created from file ' ml.tlgname];
    info.Header.DocumentId          = datestr(start_time,'yyyy-mm-dd-T-HH-MM-SS');
    info.Header.DocumentType        = 'ADELmetrology';
    info.Header.DocumentTypeVersion = 'v2.4';

    % Input
    info.Input.ProcessJobReportId = ml.tlgname;
    info.Input.LotId              = ml.tlgname;
    info.Input.ControlJobId       = ml.tlgname;

    info.Input.RecipeInformation.Name = 'unknown';
    info.Input.RecipeInformation.RecipeId = '0';
    info.Input.RecipeInformation.LayerId = '0';
    info.Input.RecipeInformation.ProductId = 'unknown';
    info.Input.RecipeInformation.Comment = '';
    info.Input.RecipeInformation.WaferDiameter.val = '300';
    info.Input.RecipeInformation.WaferDiameter.unit = 'mm';
    info.Input.RecipeInformation.WaferType = 'WaferEdgeTypeNotch';
    info.Input.RecipeInformation.WaferLoadOrientation.val = '0';
    info.Input.RecipeInformation.WaferLoadOrientation.unit = 'deg';
     
    info.Input.RecipeInformation.GridList.Grid.Name = 'grid';
    info.Input.RecipeInformation.GridList.Grid.FieldSize.Width.val = '26.000000';
    info.Input.RecipeInformation.GridList.Grid.FieldSize.Height.val = '33.000000';
    info.Input.RecipeInformation.GridList.Grid.FieldSize.Width.unit = 'mm';
    info.Input.RecipeInformation.GridList.Grid.FieldSize.Height.unit = 'mm';
 
    xca = abs(ml.wd.xc); xcm = min(xca); xci = find(xca == xcm);
    yca = abs(ml.wd.yc); ycm = min(yca); yci = find(yca == ycm);
    grid_offset = [ml.wd.xc(xci(1)) ml.wd.yc(yci(1))];
    info.Input.RecipeInformation.GridList.Grid.Offset.X.val = num2str(1e3.*grid_offset(1),'%1.6f');
    info.Input.RecipeInformation.GridList.Grid.Offset.Y.val = num2str(1e3.*grid_offset(2),'%1.6f');
    info.Input.RecipeInformation.GridList.Grid.Offset.X.unit = 'mm';
    info.Input.RecipeInformation.GridList.Grid.Offset.Y.unit = 'mm';
    
    info.Input.RecipeInformation.OverlaySignConvention = 'Measured';
    
    info.Input.RecipeInformation.LastVersionId = '1';
    info.Input.RecipeInformation.LastModifiedTime = datestr(start_time - 1,'yyyy-mm-ddTHH:MM:SS.0Z');
    info.Input.RecipeInformation.LastModifiedBy = 'unknown';
    
    info.Input.RecipeInformation.MeasurementRecipeInformationList.MeasurementRecipeInformation.Name = 'unknown';
    info.Input.RecipeInformation.MeasurementRecipeInformationList.MeasurementRecipeInformation.Id = '0';
    info.Input.RecipeInformation.MeasurementRecipeInformationList.MeasurementRecipeInformation.VersionId = '0';
    info.Input.RecipeInformation.MeasurementRecipeInformationList.MeasurementRecipeInformation.ChangedTime = datestr(start_time - 1,'yyyy-mm-ddTHH:MM:SS.0Z');
    info.Input.RecipeInformation.MeasurementRecipeInformationList.MeasurementRecipeInformation.ChangedBy = 'unknown';
    info.Input.RecipeInformation.MeasurementRecipeInformationList.MeasurementRecipeInformation.OverlayProfile.MeasurementMethod = 'Standard';
    
    info.Input.ExposureInformation.ExposureMachineId = machineId;
    info.Input.ExposureInformation.ExposureMachineType = 'Unknown';
    
    % Conditions
    info.Conditions.MeasurementPeriod.StartTime = datestr(start_time + 0.001,'yyyy-mm-ddTHH:MM:SS.0Z');
    info.Conditions.MeasurementPeriod.EndTime   = datestr(start_time + 0.001*(ml.nwafer+3),'yyyy-mm-ddTHH:MM:SS.0Z');


