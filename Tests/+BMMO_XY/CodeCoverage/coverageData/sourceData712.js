var sourceData712 = {"FileContents":["function test_suite = test_bmmo_validate_input\r","\r","suite = initTestSuite2016(localfunctions);\r","if nargout==0\r","    suite.run();\r","else\r","    test_suite = suite;\r","end\r","\r","\r","% verify function with valid input struct (one mark many fields)\r","function test_bmmo_validate_input_case1\r","\r","ml = bmmo_default_input;\r","\r","bmmo_validate_input(ml);\r","\r","bmmo_validate_input(bmmo_add_random_noise(ml, 'mark'));\r","\r","% verify error is thrown for invalid input (wrong field names)\r","function test_bmmo_validate_input_case2\r","\r","ml_wrong_shallow = bmmo_default_input;\r","ml_wrong_shallow = rmfield(ml_wrong_shallow, 'nmark');\r","noerror = false;\r","\r","try\r","    bmmo_validate_input(ml_wrong_shallow);\r","    noerror = true;\r","catch \r","    txt = lasterr;\r","    assert(length(strfind(txt, 'Fieldnames of ml struct are not as defined in EDS')) > 0);  \r","end\r","\r","if noerror\r","    error('test failed');\r","end\r","\r","% verify error is thrown for invalid input (wrong field names)\r","function test_bmmo_validate_input_case3\r","\r","ml_wrong_deep = bmmo_default_input;\r","ml_wrong_deep.info.M.chuck_id = [1 2 1 2 1 2];\r","noerror = false;\r","\r","try\r","    bmmo_validate_input(ml_wrong_deep);\r","    noerror = true;\r","catch \r","    txt = lasterr;\r","    assert(length(strfind(txt, 'info.M fieldnames not as defined in EDS')) > 0);  \r","end\r","\r","if noerror\r","    error('test failed');\r","end\r","\r","% verify error is thrown for invalid input (duplicates)\r","function test_bmmo_validate_input_case4\r","\r","ml_wrong_i = bmmo_default_input;\r","newfields = ovl_get_fields(ml_wrong_i, 1:4);\r","ml_wrong_i = ovl_combine_fields(ml_wrong_i, newfields);\r","noerror = false;\r","\r","try\r","    bmmo_validate_input(ml_wrong_i);\r","    noerror = true;\r","catch \r","    txt = lasterr;\r","    assert(length(strfind(txt, 'Duplicate mark coordinates found in input')) > 0);  \r","end\r","\r","if noerror\r","    error('test failed');\r","end\r","\r","% verify error is thrown for invalid input (inconsistent)\r","function test_bmmo_validate_input_case5\r","\r","ml_wrong_i = bmmo_default_input;\r","ml_wrong_i.nmark = 34;\r","ml_wrong_i.nfield = 244;\r","noerror = false;\r","\r","try\r","    bmmo_validate_input(ml_wrong_i);\r","    noerror = true;\r","catch \r","    txt = lasterr;\r","    assert(length(strfind(txt, 'Inconsistent definition of ml.nmark, ml.nfield')) > 0);  \r","end\r","\r","if noerror\r","    error('test failed');\r","end\r","\r","% verify that configurable_options are ignored\r","% verify error is thrown for invalid input (wrong field names)\r","function test_bmmo_validate_input_case6\r","\r","ml_config = bmmo_default_input;\r","ml_config.configurable_options = 1;\r","\r","bmmo_validate_input(ml_config);"],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[3,4,5,6,7,14,16,18,23,24,25,27,28,29,30,31,32,35,36,42,43,44,46,47,48,49,50,51,54,55,61,62,63,64,66,67,68,69,70,71,74,75,81,82,83,84,86,87,88,89,90,91,94,95,102,103,105],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}