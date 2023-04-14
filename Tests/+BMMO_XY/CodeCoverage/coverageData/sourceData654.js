var sourceData654 = {"FileContents":["%% history \r","%   2015-09-22 SBPR  creation\r","\r","function test_suite = test_bmmo_flatten_cell\r","suite = initTestSuite2016(localfunctions);","if nargout==0","    suite.run();","else","    test_suite = suite;","end","\r","% 1 heavily nested cell array\r","function test_flatten_cell_nested % ok<DEFNU>\r","\r","cell1 = {'one'};\r","cell2 = {cell1, 'two', 'three'};\r","cell4 = {'five', 'six'};\r","cell3 = {cell2, 'four', cell4};\r","cell5 = {cell3, 'seven'};\r","cell6 = {'zero', cell5};\r","\r","cellout = {'zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven'};\r","\r","test_cellout = bmmo_flatten_cell(cell6);\r","bmmo_assert_equal(cellout, test_cellout);\r","\r","% 2 practical case\r","function test_flatten_cell_practical % ok<DEFNU>\r","\r","cell1 = {'tx', 'ty', 'rwa', 'rws', 'mwa', 'mws'};\r","cell2 = {'xonly', cell1};\r","\r","cellout = {'xonly', 'tx', 'ty', 'rwa', 'rws', 'mwa', 'mws'};\r","\r","test_cellout = bmmo_flatten_cell(cell2);\r","bmmo_assert_equal(cellout, test_cellout);\r","\r","\r","% 3 already flat cell array\r","function test_flatten_cell_flat % ok<DEFNU>\r","\r","cell1 = {'tx', 'ty', 'rwa', 'rws', 'mwa', 'mws'};\r","\r","test_cellout = bmmo_flatten_cell(cell1);\r","bmmo_assert_equal(cell1, test_cellout);\r","\r","\r","\r","% 3 already flat cell array\r","function test_flatten_cell_empty % ok<DEFNU>\r","\r","cell1 = {};\r","\r","test_cellout = bmmo_flatten_cell(cell1);\r","bmmo_assert_equal(cell1, test_cellout);\r","\r","\r"],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[5,6,7,8,9,15,16,17,18,19,20,22,24,25,30,31,33,35,36,42,44,45,52,54,55],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}