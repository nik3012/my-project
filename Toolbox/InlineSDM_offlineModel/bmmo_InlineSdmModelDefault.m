classdef bmmo_InlineSdmModelDefault < bmmo_InlineSdmModel
    %% bmmo_InlineSdmModelDefault BMMO & BL3 NXE inline SDM model.
    %
    % This class calculates the KPIs correction & residuals of the inline
    % SDM model. For details on the model see the EDS (D000347979)
    %
    % bmmo_InlineSdmModelDefault Properties:
    %   mlDistoIn       - SBC ffp in ml format, on XPA positions
    %   mlWaferIn       - Wafers to apply inline SDM correction on
    %   lensModel       - bmmo_LensModel object
    %   hocModel        - bmmo_HocModel object
    %   report          - inline SDM report with KPIs & reported residuals
    %   mlChuckCorr     - inline SDM correction per chuck
    %   mlWaferResidual - Residual of mlWaferIn after inline SDM correction
    %                       applied
    %
    % bmmo_InlineSdmModelDefault Methods:
    %   calcReport    - Calculate inline SDM report 
    %   calcActuation - Calculate inline SDM correction
    %   run           - Calculate inline SDM report & correction
    %
    % See also:
    %   bmmo_InlineSdmModel
    
    properties
        % SBC ffp in ml format, on XPA positions
        mlDistoIn = ovl_average_fields(ovl_create_dummy(...
            '13x19', 'nlayer', 1, 'nwafer', 2));
        % Wafers to apply inline SDM correction on
        mlWaferIn = bmmo_process_input(bmmo_default_input);
    end
    
    properties (SetAccess = private)
        mlChuckCorr % Correction per chuck
        mlWaferResidual % Residual of mlWaferIn
        report % KPIs & reported residuals
    end
    
    methods
        function obj = bmmo_InlineSdmModelDefault(configuration, ...
                mlDisto, mlWafer)
            % bmmo_InlineSdmModelDefault constructs object
            %
            % Usage
            %
            %   obj = bmmo_InlineSdmModelDefault(configuration)
            %       Constructs the object, the inputs mlDisto & mlWafer can
            %       be set at a later time
            %
            %   obj = bmmo_InlineSdmModelDefault(configuration, mlDisto)
            %       Constructs the object with the mlDisto input. The
            %       report can be immediately generated from the object.
            %
            %   obj = bmmo_InlineSdmModelDefault(configuration, mlDisto, mlWafer)
            %       Constructs the object with both inputs. The
            %       correction & report can then be immediately generated
            %       from the object.
            %
            % Inputs
            %
            %   configuration   bmmo_Configuration object
            %   mlDisto         ml structure with 2 wafers & 1 field per wafer
            %          SBC ffp in ml format
            %          Default: all-zeros
            %   mlWaferIn       valid ml structure
            %          Wafers to apply the inline SDM correction on
            %          Default: bmmo_process_input(bmmo_default_input)
            %
            % Outputs
            %
            %   obj    created object
            %
            
            obj@bmmo_InlineSdmModel(configuration);
            
            switch nargin
                case 3
                    obj.mlDistoIn = mlDisto;
                    obj.mlWaferIn = mlWafer;
                case 2
                    obj.mlDistoIn = mlDisto;
            end
        end
        
        function run(obj)
            % bmmo_InlineSdmModelDefault method run
            %
            % Usage
            %
            %   obj.run()
            %       Run the inline SDM model and populate all the
            %       properties with model outputs
 
            obj.calcActuation();
            obj.calcReport();
        end
        
        function calcActuation(obj)
            % bmmo_InlineSdmModelDefault method calcActuation
            %
            % Usage
            %
            %   obj.calcActuation()
            %       Calculates and populates mlChuckCorr & mlWaferResidual
            %       properties 

            obj.lensModel.calcActuation();
            obj.hocModel.calcActuation();
            obj.mlChuckCorr = ...
                ovl_add(obj.hocModel.actuationOutput.mlHocChuckCorr, obj.lensModel.mlWaferOut);
            obj.mlWaferResidual = ...
                ovl_add(obj.mlWaferIn, obj.mlChuckCorr);
        end
        
        function calcReport(obj)
            % bmmo_InlineSdmModelDefault method calcReport
            %
            % Usage
            %
            %   obj.calcReport()
            %       Calculates the inline SDM report structure

            obj.lensModel.calcReport();
            obj.hocModel.calcReport();
            obj.report.lens = obj.lensModel.report;
            obj.report.hoc  = obj.hocModel.report;
            obj.report.res = ovl_add(obj.hocModel.report.mlHocRes, ...
                obj.lensModel.mlRes);
            obj.report.cor = ovl_add(obj.report.hoc.mlHocCorr, ...
                obj.lensModel.mlOut);
            
            for ic =  1:obj.report.cor.nwafer
                obj.report.Kpi.maxTotalCorr(ic).dx = ...
                    max((abs(obj.report.cor.layer.wr(ic).dx)));
                obj.report.Kpi.maxTotalCorr(ic).dy = ...
                    max((abs(obj.report.cor.layer.wr(ic).dy)));
                
                obj.report.Kpi.maxTotalRes(ic).dx = ...
                    max((abs(obj.report.res.layer.wr(ic).dx)));
                obj.report.Kpi.maxTotalRes(ic).dy = ...
                    max((abs(obj.report.res.layer.wr(ic).dy)));

            end
        end
    end
    
    methods (Static)
        function ffp = mlToFfp(ml)
            for i=1:ml.nwafer
                ffp(i).x =  ml.wd.xf;
                ffp(i).y =  ml.wd.yf;
                ffp(i).dx = ml.layer.wr(i).dx ;
                ffp(i).dy = ml.layer.wr(i).dy ;
            end
        end
    end
    
    methods % setters/getters
        function set.mlDistoIn(obj, val)
            obj.mlDistoIn           = val;
            obj.hocModel.mlDistoIn  = val;
            obj.lensModel.mlIn      = ovl_average(val);
        end
        
        function set.mlWaferIn(obj, val)
            obj.mlWaferIn          = val;
            obj.hocModel.mlWaferIn = val;
            obj.lensModel.mlWaferIn = val;
        end
    end
end
