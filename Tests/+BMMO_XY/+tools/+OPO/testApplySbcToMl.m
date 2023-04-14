classdef testApplySbcToMl < BMMO_XY.tools.testSuite
    % This test uses applySbcToMl to apply and/or subtract SBC
    % corrections from OPO data. It does not look at whether the loaded
    % SBCs should be used for the correction or decorrection. Therefore,
    % one should be careful with using this test as an example for using
    % this function. Instead, see the relevant KT: D001217927 PSA KT BL3 OPO (De)correction Tooling
    properties

        paths
        zip
        T1OpoBl3
        T2BmmoBl3
        T3BmmoBmmoNxe
        T4OpoBmmoNxe

    end

    methods (TestClassSetup)

        function setWarnings(obj)
            warning('off','all');
        end

        function setupTestData(obj)
            obj.paths.folder = [fileparts(mfilename('fullpath')) filesep 'private' filesep];
            obj.createTempDir();

            %% Setup paths of input data
            % Test 1: T1OpoBl3
            obj.T1OpoBl3.data = [obj.paths.folder 'referenceDataT1OpoBl3.mat'];
            obj.T1OpoBl3.zip.ADELmetro = [obj.paths.folder 'ADELmetrology_applySbcToMl_T1OpoBl3.zip'];
            obj.T1OpoBl3.zip.ADELler = [obj.paths.folder 'ADELler_applySbcToMl_T1OpoBl3.zip'];
            obj.T1OpoBl3.zip.ADELsbcRep = [obj.paths.folder 'ADELsbcOverlayDriftControlNxerep_applySbcToMl_T1OpoBl3.zip'];

            % Test 2: T2BmmoBl3
            obj.T2BmmoBl3.data = [obj.paths.folder 'referenceDataT2BmmoBl3.mat' ];
            obj.T2BmmoBl3.zip.ADELmetro = [obj.paths.folder 'ADELmetrology_applySbcToMl_T2BmmoBl3.zip'];
            obj.T2BmmoBl3.zip.ADELler = [obj.paths.folder 'ADELler_applySbcToMl_T2BmmoBl3.zip'];
            obj.T2BmmoBl3.zip.ADELsbcRep = [obj.paths.folder 'ADELsbcOverlayDriftControlNxerep_applySbcToMl_T2BmmoBl3.zip'];

            % Test 3: T3BmmoBmmoNxe
            obj.T3BmmoBmmoNxe.data = [obj.paths.folder 'referenceDataT3BmmoBmmoNxe.mat'];
            obj.T3BmmoBmmoNxe.zip.ADELmetro = [obj.paths.folder 'ADELmetrology_applySbcToMl_T3BmmoBmmoNxe.zip'];
            obj.T3BmmoBmmoNxe.zip.ADELler = [obj.paths.folder 'ADELler_applySbcToMl_T3BmmoBmmoNxe.zip'];
            obj.T3BmmoBmmoNxe.zip.ADELsbc = [obj.paths.folder 'ADELsbcOverlayDriftControlNxe_applySbcToMl_T3BmmoBmmoNxe.zip'];

            % Test 4: T4OpoBmmoNxe
            obj.T4OpoBmmoNxe.data = [obj.paths.folder 'referenceDataT4OpoBmmoNxe.mat'];
            obj.T4OpoBmmoNxe.zip.ADELmetro = [obj.paths.folder 'ADELmetrology_applySbcToMl_T4OpoBmmoNxe.zip'];
            obj.T4OpoBmmoNxe.zip.ADELler = [obj.paths.folder 'ADELler_applySbcToMl_T4OpoBmmoNxe.zip'];
            obj.T4OpoBmmoNxe.zip.ADELsbc = [obj.paths.folder 'ADELsbcOverlayDriftControlNxe_applySbcToMl_T4OpoBmmoNxe.zip'];



            %% Unzip the ADELs for the input data

            % Test 1: T1OpoBl3
            obj.T1OpoBl3.paths.ADELmetro = unzip(obj.T1OpoBl3.zip.ADELmetro, obj.testTempDir);
            obj.T1OpoBl3.paths.ADELler = unzip(obj.T1OpoBl3.zip.ADELler, obj.testTempDir);
            obj.T1OpoBl3.paths.ADELsbcRep = unzip(obj.T1OpoBl3.zip.ADELsbcRep, obj.testTempDir);

            % Test 2: T2BmmoBl3
            obj.T2BmmoBl3.paths.ADELmetro = unzip(obj.T2BmmoBl3.zip.ADELmetro, obj.testTempDir);
            obj.T2BmmoBl3.paths.ADELler = unzip(obj.T2BmmoBl3.zip.ADELler, obj.testTempDir);
            obj.T2BmmoBl3.paths.ADELsbcRep = unzip(obj.T2BmmoBl3.zip.ADELsbcRep, obj.testTempDir);

            % Test 3: T3BmmoBmmoNxe
            obj.T3BmmoBmmoNxe.paths.ADELmetro = unzip(obj.T3BmmoBmmoNxe.zip.ADELmetro, obj.testTempDir);
            obj.T3BmmoBmmoNxe.paths.ADELler = unzip(obj.T3BmmoBmmoNxe.zip.ADELler, obj.testTempDir);
            obj.T3BmmoBmmoNxe.paths.ADELsbc = unzip(obj.T3BmmoBmmoNxe.zip.ADELsbc, obj.testTempDir);

            %T4
            obj.T4OpoBmmoNxe.paths.ADELmetro = unzip(obj.T4OpoBmmoNxe.zip.ADELmetro, obj.testTempDir);
            obj.T4OpoBmmoNxe.paths.ADELler = unzip(obj.T4OpoBmmoNxe.zip.ADELler, obj.testTempDir);
            obj.T4OpoBmmoNxe.paths.ADELsbc = unzip(obj.T4OpoBmmoNxe.zip.ADELsbc, obj.testTempDir);



            %% Process the inputdata

            % Test 1: T1OpoBl3
            obj.T1OpoBl3.ADELmetro = ovl_read_adelmetrology(obj.T1OpoBl3.paths.ADELmetro{1}, 'ignoretargetname');
            obj.T1OpoBl3.ADELsbcRepCor = bmmo_kt_process_SBC2rep(obj.T1OpoBl3.paths.ADELsbcRep{1});

            % Test 2: T2BmmoBl3
            obj.T2BmmoBl3.ADELmetro = ovl_read_adelmetrology(obj.T2BmmoBl3.paths.ADELmetro{1}, 'targetname', 'LS_OV_RINT');
            obj.T2BmmoBl3.ADELsbcRepCor = bmmo_kt_process_SBC2rep(obj.T2BmmoBl3.paths.ADELsbcRep{1});

            % Test 3: T3BmmoBmmoNxe
            obj.T3BmmoBmmoNxe.ADELmetro = ovl_read_adelmetrology(obj.T3BmmoBmmoNxe.paths.ADELmetro{1}, 'targetname', 'LS_OV_RINT');
            obj.T3BmmoBmmoNxe.ADELsbcCor = bmmo_kt_process_SBC2(obj.T3BmmoBmmoNxe.paths.ADELsbc{1});

            % Test 4: T4OpoBmmoNxe
            obj.T4OpoBmmoNxe.ADELmetro = ovl_read_adelmetrology(obj.T4OpoBmmoNxe.paths.ADELmetro{1}, 'ignoretargetname');
            obj.T4OpoBmmoNxe.ADELsbcCor = bmmo_kt_process_SBC2(obj.T4OpoBmmoNxe.paths.ADELsbc{1});

        end

        function setupRefData(obj)

            %% Load in the reference data

            % Test 1: T1OpoBl3
            load([obj.paths.folder, 'referenceDataT1OpoBl3.mat']);
            obj.T1OpoBl3.ref.corrected = corrOpo;
            obj.T1OpoBl3.ref.decorrected = decorrOpo;

            % Test 2: T2BmmoBl3
            load([obj.paths.folder 'referenceDataT2BmmoBl3.mat']);
            obj.T2BmmoBl3.ref.corrected = corrBMMO;
            obj.T2BmmoBl3.ref.decorrected = decorrBMMO;

            % Test 3: T3BmmoBmmoNxe
            load([obj.paths.folder 'referenceDataT3BmmoBmmoNxe.mat']);
            obj.T3BmmoBmmoNxe.ref.corrected = corrBMMO;
            obj.T3BmmoBmmoNxe.ref.decorrected = decorrBMMO;

            % Test 4: T4OpoBmmoNxe
            load([obj.paths.folder 'referenceDataT4OpoBmmoNxe.mat']);
            obj.T4OpoBmmoNxe.ref.corrected = corrOpo;
            obj.T4OpoBmmoNxe.ref.decorrected = decorrOpo;

        end
    end

    methods (Test)

        function doT1OpoBl3(obj)
            obj.T1OpoBl3.intrafOrder = 5; % Set intrafield order
            obj.T1OpoBl3.Result.decorrected = BMMO_XY.tools.OPO.applySbcToMl(obj.T1OpoBl3.ADELmetro, obj.T1OpoBl3.ADELsbcRepCor, -1, obj.T1OpoBl3.paths.ADELler{1}, obj.T1OpoBl3.intrafOrder);
            obj.T1OpoBl3.Result.corrected = BMMO_XY.tools.OPO.applySbcToMl(obj.T1OpoBl3.ADELmetro, obj.T1OpoBl3.ADELsbcRepCor, 1, obj.T1OpoBl3.paths.ADELler{1}, obj.T1OpoBl3.intrafOrder);
            obj.verifyMlWithinTol(obj.T1OpoBl3.Result.decorrected, obj.T1OpoBl3.ref.decorrected);
            obj.verifyMlWithinTol(obj.T1OpoBl3.Result.corrected, obj.T1OpoBl3.ref.corrected);
        end

        function doT2BmmoBl3(obj)
            obj.T2BmmoBl3.intrafOrder = 5; % Set intrafield order
            obj.T2BmmoBl3.Result.decorrected = BMMO_XY.tools.OPO.applySbcToMl(obj.T2BmmoBl3.ADELmetro, obj.T2BmmoBl3.ADELsbcRepCor, -1, obj.T2BmmoBl3.paths.ADELler{1}, obj.T2BmmoBl3.intrafOrder);
            obj.T2BmmoBl3.Result.corrected = BMMO_XY.tools.OPO.applySbcToMl(obj.T2BmmoBl3.ADELmetro, obj.T2BmmoBl3.ADELsbcRepCor, 1, obj.T2BmmoBl3.paths.ADELler{1}, obj.T2BmmoBl3.intrafOrder);
            obj.verifyMlWithinTol(obj.T2BmmoBl3.Result.decorrected, obj.T2BmmoBl3.ref.decorrected);
            obj.verifyMlWithinTol(obj.T2BmmoBl3.Result.corrected, obj.T2BmmoBl3.ref.corrected);
        end

        function doT3BmmoBmmoNxe(obj)
            obj.T3BmmoBmmoNxe.intrafOrder = 3; % Set intrafield order
            obj.T3BmmoBmmoNxe.Result.decorrected = BMMO_XY.tools.OPO.applySbcToMl(obj.T3BmmoBmmoNxe.ADELmetro, obj.T3BmmoBmmoNxe.ADELsbcCor, -1, obj.T3BmmoBmmoNxe.paths.ADELler{1}, obj.T3BmmoBmmoNxe.intrafOrder);
            obj.T3BmmoBmmoNxe.Result.corrected = BMMO_XY.tools.OPO.applySbcToMl(obj.T3BmmoBmmoNxe.ADELmetro, obj.T3BmmoBmmoNxe.ADELsbcCor, 1, obj.T3BmmoBmmoNxe.paths.ADELler{1}, obj.T3BmmoBmmoNxe.intrafOrder);
            obj.verifyMlWithinTol(obj.T3BmmoBmmoNxe.Result.decorrected, obj.T3BmmoBmmoNxe.ref.decorrected);
            obj.verifyMlWithinTol(obj.T3BmmoBmmoNxe.Result.corrected, obj.T3BmmoBmmoNxe.ref.corrected);
        end

        function doT4OpoBmmoNxe(obj)
            obj.T4OpoBmmoNxe.intrafOrder = 3; % Set intrafield order
            obj.T4OpoBmmoNxe.Result.decorrected = BMMO_XY.tools.OPO.applySbcToMl(obj.T4OpoBmmoNxe.ADELmetro, obj.T4OpoBmmoNxe.ADELsbcCor, -1, obj.T4OpoBmmoNxe.paths.ADELler{1}, obj.T4OpoBmmoNxe.intrafOrder);
            obj.T4OpoBmmoNxe.Result.corrected = BMMO_XY.tools.OPO.applySbcToMl(obj.T4OpoBmmoNxe.ADELmetro, obj.T4OpoBmmoNxe.ADELsbcCor, 1, obj.T4OpoBmmoNxe.paths.ADELler{1}, obj.T4OpoBmmoNxe.intrafOrder);
            obj.verifyMlWithinTol(obj.T4OpoBmmoNxe.Result.decorrected, obj.T4OpoBmmoNxe.ref.decorrected);
            obj.verifyMlWithinTol(obj.T4OpoBmmoNxe.Result.corrected, obj.T4OpoBmmoNxe.ref.corrected);
        end

    end

    methods (TestClassTeardown)
        function resetWarnings(obj)
            warning('on','all');
        end
    end

end