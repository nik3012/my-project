classdef bmmo_HocModelDefault < bmmo_HocModel
    %% bmmo_HocModelDefault BMMO & BL3 NXE HOC model.
    %
    % This class calculates the KPIs correction & residuals for the HOC
    % part of the inline SDM model. For details on the model see the
    % EDS (D000347979)
    %
    % bmmo_HocModelDefault Properties:
    %   mlDistoIn             - SBC ffp in ml format
    %   mlWaferIn             - Wafers to applly HOC correction on
    %   chuckId               - Chuck Id of wafers in mlWaferIn
    %   actuationOutput       - Structure containing correction and residual
    %   report                - Structure with reporitng KPIs & residuals
    %   mlHocInput            - Input to HOC model for reporting, calculated from mlDistoIn
    %   mlHocInputFiltered    - Correctable of mlHocInput after applying HOC filter
    %   mlHocInputAct         - Input to HOC model for actuation, calculated from mlDistoIn
    %   mlHocInputFilteredAct - Correctable of mlHocInputAct after applying HOC filter
    %   cetFieldSize          - Size of CET grid field [x y]
    %   imageShift            - Image shift on wafer level [x y]
    %   imageResol            - Image resolution (nmarks) in x and y direction
    %   adelLer               - filepath of Adeller, updates default y values of
    %                           cetFieldSize & imageShift if provided
    
    %
    % bmmo_HocModelDefault Methods:
    %   calcReport    - Calculate HOC report
    %   calcActuation - Calculate HOC correction
    %   run           - Calculate HOC report & correction
    %
    % See also:
    %   bmmo_HocModel
    
    properties
        % SBC ffp in ml format
        mlDistoIn = ovl_average_fields(ovl_create_dummy(...
            '13x19', 'nlayer', 1, 'nwafer', 2));
        % Wafers to applly HOC correction on
        mlWaferIn = bmmo_process_input(bmmo_default_input);
        chuckId % Chuck Id of wafers in mlWaferIn
        adelLer char
        cetFieldSize = [25.44 33]*1e-3
        imageShift = [0 0]
        imageResol = [13 19]
    end
    
    properties (SetAccess = private)
        actuationOutput % Structure containing correction and residual
        report % Structure with reporting KPIs & residuals
    end
    
    properties (Dependent)
        % Input to HOC model, calculated from mlDistoIn
        mlHocInput struct
        % Correctable of mlHocInput after applying HOC filter
        mlHocInputFiltered struct
        % Actuation used a different grid than reporting on TS
        mlDistoInAct struct
        % Input to HOC model for actuation, calculated from mlDistoIn
        mlHocInputAct struct
        % Correctable of mlHocInputAct after applying HOC filter
        mlHocInputFilteredAct struct
    end
    
    properties (Access = private)
        hocPoly2splineReport
        hocPlaybackReport
        hocFilter
        hocActuation
        hocPoly2spline
        hocPlayback
        mlHocGrid33 = ovl_average_fields(ovl_create_dummy(...
            'marklayout', [25.44 33 13 19], 'nlayer', 1, 'nwafer', 2));
    end
    
    properties (Access = private, Dependent)
        mlChuckTemplate struct
    end
    
    methods
        function obj = bmmo_HocModelDefault(configuration, mlDistoIn, ...
                mlWaferIn, chuckId)
            % bmmo_HocModelDefault constructs object
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
            %   obj = bmmo_InlineSdmModelDefault(configuration, mlDisto, ...
            %           mlWafer)
            %       Constructs the object with both inputs. The
            %       correction & report can then be immediately generated
            %       from the object.
            %   obj = bmmo_InlineSdmModelDefault(configuration, mlDisto, ...
            %           mlWafer, chuckId)
            %       Constructs the object with both inputs. The
            %       correction & report can then be immediately generated
            %       from the object. Use the chuckId input if chuckId is
            %       different from default
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
            %   chuckId         1x(mlWaferIn.nwafer) double
            %          Default: [1, 2, 1, 2, 1, 2]
            %
            % Outputs
            %
            %   obj    created object
            %
            
            obj.hocFilter = ...
                configuration.getConfigurationObject('HocFilter');
            obj.hocActuation = ...
                configuration.getConfigurationObject('CetModel');
            obj.hocPoly2spline = ...
                configuration.getConfigurationObject('HocPoly2Spline');
            obj.hocPlayback = ...
                configuration.getConfigurationObject('HocPlayback');
            obj.hocPoly2splineReport = ...
                bmmo_HocPoly2SplineDisabled.getInstance();
            obj.hocPlaybackReport = ...
                bmmo_HocPlaybackDisabled(configuration);
            getChuckId(obj);
            
            switch nargin
                case 4
                    obj.mlWaferIn = mlWaferIn;
                    obj.chuckId = chuckId;
                    obj.mlDistoIn = mlDistoIn;
                case 3
                    obj.mlWaferIn = mlWaferIn;
                    obj.mlDistoIn = mlDistoIn;
                case 2
                    obj.mlDistoIn = mlDistoIn;
                otherwise
            end
            
        end
        
        function run(obj)
            % bmmo_HocModelDefault method run
            %
            % Usage
            %
            %   obj.run()
            %       Run the Hoc model and populate all the
            %       properties with model outputs
            obj.calcActuation();
            obj.calcReport();
        end
        
        function calcActuation(obj)
            % bmmo_HocModelDefault method calcActuation
            %
            % Usage
            %
            %   obj.calcActuation()
            %       Calculates corrections and residuals and saves it in
            %       the actuationOutput property
            mlChuckIn = obj.mlChuckTemplate;
            mlChuckInXpa =  ovl_create_dummy(mlChuckIn,'marklayout', 'BF-FOXY3-DYNA-13X19');
            mlHocChuckInput = ovl_distribute_field(obj.mlHocInputFilteredAct, ...
                mlChuckInXpa); % HocDisto on CET layout
            [obj.actuationOutput.mlHocChuckResSrr, cs] = ...
                obj.hocActuation.actuationResidue(mlHocChuckInput);
            cs = obj.hocPoly2spline.getOptions(cs);
            [~, mlHocCorr , ~] = ...
                obj.hocPlayback.playbackTrajectories(mlChuckIn, cs);
            % Perwafer correction & residue in measurement layout
            mlHocWaferCorr = ovl_get_wafers(mlHocCorr, obj.chuckId);
            obj.actuationOutput.mlHocChuckCorr = ...
                ovl_combine_linear(mlHocWaferCorr, 1, obj.mlWaferIn, 0);
            obj.actuationOutput.mlWaferResidual = ovl_add(obj.mlWaferIn, mlHocWaferCorr);
            
        end
        
        function calcReport(obj)
            % bmmo_HocModelDefault method calcReport
            %
            % Usage
            %
            %   obj.calcReport()
            %       Calculates the HOC model report structure
            [obj.report.mlHocResSrr, cs] = ...
                obj.hocActuation.actuationResidue(obj.mlHocInputFiltered);
            cs = obj.hocPoly2splineReport.getOptions(cs);
            [obj.report.mlHocRes, obj.report.mlHocCorr, obj.report.mlHocFad] = ...
                obj.hocPlaybackReport.playbackTrajectories(obj.mlHocInput, cs);
            
            for ic =  1:obj.report.mlHocCorr.nwafer
                obj.report.Kpi.maxHOCCorr(ic).dx = ...
                    max((abs(obj.report.mlHocCorr.layer.wr(ic).dx)));
                obj.report.Kpi.maxHOCCorr(ic).dy = ...
                    max((abs(obj.report.mlHocCorr.layer.wr(ic).dy)));
                
                obj.report.Kpi.maxHOCRes(ic).dx = ...
                    max((abs(obj.report.mlHocRes.layer.wr(ic).dx)));
                obj.report.Kpi.maxHOCRes(ic).dy = ...
                    max((abs(obj.report.mlHocRes.layer.wr(ic).dy)));
                
                obj.report.Kpi.FadingMSD(ic).dx = ...
                    max((abs(obj.report.mlHocFad.layer.wr(ic).dx)));
                obj.report.Kpi.FadingMSD(ic).dy = ...
                    max((abs(obj.report.mlHocFad.layer.wr(ic).dy)));
            end
        end
    end
    
    methods(Access = private)
        function getChuckId(obj)
            chuckOrder = [1, 2];
            obj.chuckId = [];
            for i = 1: round(obj.mlWaferIn.nwafer/2)
                obj.chuckId = [obj.chuckId chuckOrder];
            end
            
            if ~iseven(obj.mlWaferIn.nwafer)
                obj.chuckId(end) = [];
            end
        end
        
        function getImageInfo(obj)
            MM = 1e-3;
            ler = xml_load(obj.adelLer);
            imageSettings = ler.Input.WaferSettings.WaferGenericSettings.ImageSettings.ImageSpecificSettingsList(1).elt;
            obj.cetFieldSize(2)  = str2double(imageSettings.ImageSize.Y) * MM;
            obj.imageShift(2)  = str2double(imageSettings.ImageShift.Y) * MM;
        end
    end
    
    methods % setters & getters
        function set.mlWaferIn(obj, val)
            obj.mlWaferIn = val;
            getChuckId(obj)
        end
        
        function set.mlDistoIn(obj, val)
            obj.mlDistoIn = val;
        end
        
        function set.adelLer(obj, val)
            obj.adelLer = val;
            getImageInfo(obj)
        end
        
        function val = get.mlDistoInAct(obj)
            val = obj.mlDistoIn;
            if ~isa(obj.hocFilter, 'bmmo_HocFilterSpline')%32.4 for spline
                val.wd.yf = obj.mlHocGrid33.wd.yf;
                val.wd.yw = obj.mlHocGrid33.wd.yw;
            end
        end
        
        function val = get.mlHocInput(obj)
            mlAvgField = ovl_average(obj.mlDistoIn);
            val = ovl_sub(obj.mlDistoIn, ovl_scan_integrate(mlAvgField));
        end
        
        function val = get.mlHocInputAct(obj)
            mlAvgField = ovl_average(obj.mlDistoInAct);
            val = ovl_sub(obj.mlDistoInAct, ovl_scan_integrate(mlAvgField));
        end
        
        function val = get.mlHocInputFiltered(obj)
            val = obj.hocFilter.filterDistortion(obj.mlHocInput);
        end
        
        function val = get.mlHocInputFilteredAct(obj)
            if ~isa(obj.hocFilter, 'bmmo_HocFilter33Par')
                filteredInput = obj.hocFilter.filterDistortion(obj.mlHocInputAct);
                val = getResampledActInput(obj, filteredInput);
            else
                resampledInput = getResampledActInput(obj, obj.mlHocInputAct);
                val = obj.hocFilter.filterDistortion(resampledInput);
            end
        end
        
        function val = getResampledActInput(obj, mlActInput)
            field_geo.W = obj.cetFieldSize(1);
            field_geo.H = obj.cetFieldSize(2);
            field_geo.x_resol = obj.imageResol(1);
            field_geo.y_resol = obj.imageResol(2);
            image_y_shift = obj.imageShift(2);
            val = bmmo_y_resample(mlActInput, field_geo, image_y_shift);
        end
        
        function val = get.mlChuckTemplate(obj)
            val = ovl_create_dummy(obj.mlWaferIn, 'nwafer', 2);
        end
    end
    
end
