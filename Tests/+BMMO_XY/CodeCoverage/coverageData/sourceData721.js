var sourceData721 = {"FileContents":["function tests = testRerunTsActuation\r","tests = functiontests(localfunctions);\r","end\r","\r","% Input1: JW71 BMMO OTAS input, recover job, non zero prev correction\r","% Input 2: JW71 BL3 LIS input, control job, non zero prev correction\r","function test_bmmo_bl3_inputs(tc)\r","\r"," load([bmmo_testdata_root filesep  'testRerunTsActuation_1']);\r","\r"," % Define job config\r"," jobConfig.platform =  'LIS';\r"," jobConfig.susd_correction_enabled =  1;\r"," jobConfig.KA_correction_enabled = 1;\r"," jobConfig.bl3_model = 1;\r"," jobConfig.intraf_actuation = 5;\r"," jobConfig.KA_actuation= 'HOC';\r"," % Define TS actuation config\r"," tsActuationConfig = @bl3_3600D_model_configuration; %Spline actuation with Spline filter\r","\r","obj = bmmo_RerunTsActuation(in);% define rerun object\r","obj.jobConfig = jobConfig; % Set re-run BL3 job config\r","obj.tsActuationConfig = tsActuationConfig; % set actuation config for re-correction\r","obj.timeFilter = 'DEFAULT';\r","obj.recoveryOnFirstInput = true; % Do recovery on First input with zero SBC correction\r","\r","% Do re-run\r","obj.run;\r","\r","% assert recorrection properties\r","bmmo_assert_equal(obj.recorrect.tsActuationConfig, tsActuationConfig);\r","bmmo_assert_equal(obj.recorrect.kaFpActuationBaseliner3, 'VERSION_5');\r","\r","% assert if job config is present in re-corrected inputs\r","for i =1:length(in)\r","    bmmo_assert_equal(obj.rerunOutput(i).bmmoInputsRecorrected.info.configuration_data, jobConfig);\r","end\r","% test rerun outputs: recorrected inputs, sbcs, kpis\r","bmmo_assert_equal(testRerunOutput, obj.rerunOutput);\r","\r","% check recovery on first input (zero BL3 corrrection)\r","default_output = bmmo_default_output_structure(bl3_default_options_structure);\r","bmmo_assert_equal(obj.rerunOutput(1).bmmoInputsRecorrected.info.previous_correction, default_output.corr);\r","end\r","\r","\r","function test_bmmo_bl3_inputs_with_time_filter(tc)\r","TIME_FILTER_ENABLED = 1;\r","TIME_FILTER_DISABLED = 0;\r","load([bmmo_testdata_root filesep  'testRerunTsActuation']);\r","\r","in_time_filter(1) = in(2);\r","in_time_filter(2) = in(1);\r","obj = bmmo_RerunTsActuation(in_time_filter);\r","obj.timeFilter = 'ENABLED';\r","obj.recoveryOnFirstInput = true; \r","% Do re-run\r","obj.run;\r","\r","% check time filter is disabled for first re-corrected input (due to recovery)\r","% and enabled for re-corrected second input\r","    bmmo_assert_equal(obj.rerunOutput(1).bmmoInputsRecorrected.info.report_data.time_filtering_enabled, TIME_FILTER_DISABLED)\r","    bmmo_assert_equal(obj.rerunOutput(2).bmmoInputsRecorrected.info.report_data.time_filtering_enabled, TIME_FILTER_ENABLED)\r","end\r","\r","function testSelfCorrectTsActuation(tc)\r"," load([bmmo_testdata_root filesep  'testRerunTsActuation_1']);\r"," % Define job config\r"," jobConfig.platform =  'LIS';\r"," jobConfig.susd_correction_enabled =  1;\r"," jobConfig.KA_correction_enabled = 1;\r"," jobConfig.bl3_model = 1;\r"," jobConfig.intraf_actuation = 5;\r"," jobConfig.KA_actuation= 'HOC';\r"," % Define TS actuation config\r","tsActuationConfig = @bl3_3600D_model_configuration;\r","testInput = in(1);\r","\r","% DEFINE SELF-CORRECTION OBJECT\r","obj = bmmo_SelfCorrectTsActuation(testInput);% define self-correction object\r","obj.jobConfig = jobConfig; % Set self-correction BL3 job config\r","obj.tsActuationConfig = tsActuationConfig; % set actuation config for Ts residuals\r","% Do self-correction\r","obj.run;\r","\r","% DEFINE RE-RUN OBJECT\r","obj1 = bmmo_RerunTsActuation(testInput);% define re-run object\r","obj1.jobConfig = jobConfig; % Set re-run BL3 job config\r","obj1.tsActuationConfig = tsActuationConfig; % set actuation config for Ts residuals\r","obj1.recoveryOnFirstInput = true; % do recover job to compare with Self-correction\r","% Do re-run\r","obj1.run;\r","\r","% make changes to outputs to keep same field names and assert only relevant\r","% fields\r","selfCorrectOutputs = obj.selfCorrectOutput;\r","selfCorrectOutputs.bmmoInputsDecorrected.info = rmfield(selfCorrectOutputs.bmmoInputsDecorrected.info, 'report_data');% to remove NCE NaN mismatch\r","rerunOutputs = obj1.rerunOutput;\r","rerunOutputs.bmmoInputsDecorrected = rerunOutputs.bmmoInputsRecorrected;\r","rerunOutputs = rmfield(rerunOutputs, 'bmmoInputsRecorrected');\r","rerunOutputs.bmmoInputsDecorrected.info = rmfield(rerunOutputs.bmmoInputsDecorrected.info, 'report_data');% to remove NCE NaN mismatch\r","\r","% Compare self-correction outputs with re-run outputs \r","bmmo_assert_equal(selfCorrectOutputs, rerunOutputs)\r","end"],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[2,9,12,13,14,15,16,17,19,21,22,23,24,25,28,31,32,35,36,39,42,43,48,49,50,52,53,54,55,56,58,62,63,67,69,70,71,72,73,74,76,77,80,81,82,84,87,88,89,90,92,96,97,98,99,100,101,104],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}