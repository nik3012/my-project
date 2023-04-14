% function  bmmo_ml2ADELmetro(ml,fname,info,varargin)
%
% function to write a ml struct to ADELmetrology.xml file for BMMO-NXE.
% 
% Multilot data will be written in separate files unless 'single_file' specified
%
% inputs:
%   ml      Overlay data in ml struct.
%   fname   Output filename ADEL_<fname>[_lot##].xml
%   info    OPTIONAL info struct used to define ADEL info fields
%           method 1 : output from ovl_getADELmetroinfo
%           method 2 : info.imagesize.x; mm in text format
%                                    .y; mm in text format
%                      info.gridoffset.x; mm in text format
%                                      y; mm in text format
%                      info.ID_tag;
%                      info.LayerID;
%                      info.ProductID;
%           method 3 : when info is not input or empty, then created using the ml as input 
%           to ovl_getADELmetroinfo (use only for non ADELmetrology data!)
% varargin:
% 'single_file'  to place multilot data in a single file: the tlgname will be used as
%                the attributes of the first lot will be used
% 'full_name'    in case fname is the full name of the output file
%
% output:   ADELmetrology_<fname>.xml file written in current directory
%           The output (contained in WaferResult) is given in a
%           cell. Furthermore, all NaNs are excluded in the
%           ADELmetrology.
%
% example:
%    bmmo_ml2ADELmetro(ml,'path_to_file.xml',[],'full_name');
%
% NOTE: in case you run into a Java heap space memory error, then increase the size:
% Preferences - General - Java Heap Memory   (restart needed!)
%
% see also: ovl_getADELmetroinfo and bmmo_getADELmetroinfo


function [metrology_struct2, totalmeasurements] = bmmo_ml2ADELmetro(ml,label, info)


ml1 = ml{1};

totalmeasurements = 0;

% copy info into temporary metrology struct
metrology_struct2.ADELmetrology_colon_MetrologyReport.Header = info.Header;
metrology_struct2.ADELmetrology_colon_MetrologyReport.Input = info.Input;
metrology_struct2.ADELmetrology_colon_MetrologyReport.Conditions = info.Conditions;
 
%% retrieve grid info to be used to store ml info
cellsize_x    = str2num(info.Input.RecipeInformation.GridList.Grid.FieldSize.Width.Text);
cellsize_y    = str2num(info.Input.RecipeInformation.GridList.Grid.FieldSize.Height.Text);
grid_offset_x = str2num(info.Input.RecipeInformation.GridList.Grid.Offset.X.Text);
grid_offset_y = str2num(info.Input.RecipeInformation.GridList.Grid.Offset.Y.Text);


for w=1:ml1.nwafer
        
    % wafer unique part 1: items 1:6 before measurement list
    metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.LoadPort = info.WaferUniqueInfo{w}.wafer_unique.LoadPort;
    metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.CarrierId = info.WaferUniqueInfo{w}.wafer_unique.CarrierId;
    metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.SlotId = info.WaferUniqueInfo{w}.wafer_unique.SlotId;         
    metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.Status = info.WaferUniqueInfo{w}.wafer_unique.Status; 
    metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.OverlayCoarseDetected = info.WaferUniqueInfo{w}.wafer_unique.OverlayCoarseDetected;         
    metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.WaferId = info.WaferUniqueInfo{w}.wafer_unique.WaferId;        
        

    % write actual overlay results to struct
    js = 0; % js = count for selected targets
    
    for ilot = 1:length(ml)
    
        mli = ml{ilot};
        
        disp(['Starting Wafer ' num2str(w) ' of ' num2str(mli.nwafer)])

        for j=1:length(mli.wd.xc)

          if ~isnan(mli.layer.wr(1,w).dx(j,1)*1e9) && ~isnan(mli.layer.wr(1,w).dy(j,1)*1e9)
            js = js + 1;   

            % fill measurement unique, wafer unique info
            metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.SequenceNumber.Text=num2str(j);
            metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.MeasurementNumber.Text=num2str(j);

            metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.Type = info.WaferUniqueInfo{w}.Measurement_generique.Type;
            metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.RecipeTargetId = info.WaferUniqueInfo{w}.Measurement_generique.RecipeTargetId;
            metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.RecipeTargetId.TargetLabel = label{ilot};
            metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.TargetRotation = info.WaferUniqueInfo{w}.Measurement_generique.TargetRotation;
            metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.SampleSchemeName = info.WaferUniqueInfo{w}.Measurement_generique.SampleSchemeName;
            metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.GridInfo.Name=info.WaferUniqueInfo{w}.Measurement_generique.GridInfo.Name;

            metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.GridInfo.Location.Row.Text=num2str(getindex(mli.wd.yc(j,1)*1e3,cellsize_y,grid_offset_y));
            metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.GridInfo.Location.Col.Text=num2str(getindex(mli.wd.xc(j,1)*1e3,cellsize_x,grid_offset_x));

            metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.MeasurementOption = info.WaferUniqueInfo{w}.Measurement_generique.MeasurementOption;
            metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.MeasurementStartTime = info.WaferUniqueInfo{w}.Measurement_generique.MeasurementStartTime;        

            metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.FieldPosition.X.Text=num2str(mli.wd.xc(j,1)*1e3);
            metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.FieldPosition.Y.Text=num2str(mli.wd.yc(j,1)*1e3);       

            metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.FieldPosition.X.Attributes.unit='mm';
            metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.FieldPosition.Y.Attributes.unit='mm';
            metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.TargetPosition.X.Text=num2str(mli.wd.xf(j,1)*1e3);
            metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.TargetPosition.X.Attributes.unit='mm';
            metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.TargetPosition.Y.Text=num2str(mli.wd.yf(j,1)*1e3);
            metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.TargetPosition.Y.Attributes.unit='mm';

            metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.MeasurementProfileName = info.WaferUniqueInfo{w}.Measurement_generique.MeasurementProfileName;
            metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.MeasurementProfileId = info.WaferUniqueInfo{w}.Measurement_generique.MeasurementProfileId;
            metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.DoseFactor = info.WaferUniqueInfo{w}.Measurement_generique.DoseFactor;

            % dx
            if isnan(mli.layer.wr(1,w).dx(j,1)*1e9)
                   metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.OverlayMeasurement.Overlay.X.Text='0.0';
                   metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.OverlayMeasurement.Overlay.X.Attributes.unit='nm';
                   metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.OverlayMeasurement.Sig.X = info.WaferUniqueInfo{w}.Measurement_generique.OverlayMeasurement.Sig.X;
                   metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.OverlayMeasurement.Valid.X.Text='false';
            else
                   metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.OverlayMeasurement.Overlay.X.Text=num2str(mli.layer.wr(1,w).dx(j,1)*1e9,'%6.3f');
                   metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.OverlayMeasurement.Overlay.X.Attributes.unit='nm';
                   metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.OverlayMeasurement.Sig.X = info.WaferUniqueInfo{w}.Measurement_generique.OverlayMeasurement.Sig.X;
                   metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.OverlayMeasurement.Valid.X.Text='true';
             end
             % dy
             if isnan(mli.layer.wr(1,w).dy(j,1)*1e9)
                   metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.OverlayMeasurement.Overlay.Y.Text='0.0';   
                   metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.OverlayMeasurement.Overlay.Y.Attributes.unit='nm';
                   metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.OverlayMeasurement.Sig.Y = info.WaferUniqueInfo{w}.Measurement_generique.OverlayMeasurement.Sig.Y;
                   metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.OverlayMeasurement.Valid.Y.Text='false';
             else
                   metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.OverlayMeasurement.Valid.Y.Text='true';
                   metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.OverlayMeasurement.Overlay.Y.Attributes.unit='nm';
                   metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.OverlayMeasurement.Sig.Y = info.WaferUniqueInfo{w}.Measurement_generique.OverlayMeasurement.Sig.Y;
                   metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.WaferResultList.WaferResult{1,w}.MeasurementList.Measurement{1,js}.OverlayMeasurement.Overlay.Y.Text=num2str(mli.layer.wr(1,w).dy(j,1)*1e9,'%6.3f');

             end
          end
        end

    end
    
    totalmeasurements = totalmeasurements + js;
end % per wafer for loop
%%
metrology_struct2.ADELmetrology_colon_MetrologyReport.Results.Status.Text='ProcessComplete';
%% Attributes
metrology_struct2.ADELmetrology_colon_MetrologyReport.Attributes = info.Attributes;
%%
disp([num2str(totalmeasurements) ' total measurements']);

  
end % end of main function def...


%====================== supportive function definitions =========

%------ Subfunction getindex -------
function idx = getindex(posval,pitch,offset)

    idx =  round((posval - offset)/pitch);

end