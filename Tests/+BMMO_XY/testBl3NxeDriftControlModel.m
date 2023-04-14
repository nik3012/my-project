classdef testBl3NxeDriftControlModel < BMMO_XY.tools.testSuite

    properties (Constant)

        testPath = fileparts(mfilename('fullpath'));
        dataDir = ['private' filesep 'testData_bl3NxeDriftControlModel.mat'];
        refNames = {'SUSDON_KAON_1L', 'SUSDOFF_KAON_1L', 'SUSDON_KAON_2L', 'SUSDOFF_KAON_2L', 'SUSDON_KAON_1L_NCE'};

    end

    properties

        data
        testOut

    end

    methods (TestClassSetup)

        function setup(obj)
            obj.data = load([obj.testPath filesep obj.dataDir]);
            obj.data.mli.info.previous_correction.KA.grid_2dc = bmmo_KA_corr_subset(obj.data.mli.info.previous_correction.KA.grid_2dc);
            obj.data.mli.info.configuration_data.KA_correction_enabled = 1;
            obj.data.mli.info.report_data.cet_residual = bmmo_empty_cet_residual(obj.data.mli);
        end

    end

    methods (Test)

        function verify_SUSDON_KAON_1L(obj)
            obj.data.mli.info.configuration_data.susd_correction_enabled = 1;
            obj.data.mli = bmmo_turn_off_l2(obj.data.mli);

            obj.testOut = bmmo_nxe_drift_control_model(obj.data.mli);
            obj.verifyWithinTol(obj.testOut, obj.data.(obj.refNames{1}), 'type', 'rel', 'tol', 0.01)
        end

        function verify_SUSDOFF_KAON_1L(obj)
            obj.data.mli.info.configuration_data.susd_correction_enabled = 0;
            obj.data.mli = bmmo_turn_off_l2(obj.data.mli);

            obj.testOut = bmmo_nxe_drift_control_model(obj.data.mli);
            obj.verifyWithinTol(obj.testOut, obj.data.(obj.refNames{2}), 'type', 'rel', 'tol', 0.01)
        end

        function verify_SUSDON_KAON_2L(obj)
            obj.data.mli.info.configuration_data.susd_correction_enabled = 1;

            obj.testOut = bmmo_nxe_drift_control_model(obj.data.mli);
            obj.verifyWithinTol(obj.testOut, obj.data.(obj.refNames{3}), 'type', 'rel', 'tol', 0.01)
        end

        function verify_SUSDOFF_KAON_2L(obj)
            obj.data.mli.info.configuration_data.susd_correction_enabled = 0;

            obj.testOut = bmmo_nxe_drift_control_model(obj.data.mli);
            obj.verifyWithinTol(obj.testOut, obj.data.(obj.refNames{4}), 'type', 'rel', 'tol', 0.01)
        end

        function verify_SUSDON_KAON_1L_NCE(obj)
            obj.data.mli_nce.info.configuration_data.susd_correction_enabled = 1;
            obj.data.mli_nce.info.configuration_data.KA_correction_enabled = 1;

            obj.testOut = bmmo_nxe_drift_control_model(obj.data.mli_nce);
            obj.verifyWithinTol(obj.testOut, obj.data.(obj.refNames{5}), 'type', 'rel', 'tol', 0.01)
        end

    end

end