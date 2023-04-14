var sourceData691 = {"FileContents":["function test_suite = test_bmmo_pars_to_k_factor_matrix\r","\r","suite = initTestSuite2016(localfunctions);","if nargout==0","    suite.run();","else","    test_suite = suite;","end","\r","\r","% sanity check on data\r","function test_bmmo_pars2kfactors_case1\r","\r","numk = 18;\r","nfield = 89;\r","nmark = 247;\r","UM = 1; % SBPR 20160412: remove scaling\r","\r","for ifield = nfield:-1:1\r","   wafer.field(ifield) = sub_get_pars(ifield * numk);\r","end\r","\r","kmatrix  = bmmo_pars_to_k_factor_matrix(wafer.field, nmark, nfield);\r","\r","[nrow, ncol] = size(kmatrix);\r","assert(nrow == numk);\r","assert(ncol == nfield * nmark);\r","\r","% check that conversion is correct\r","for ik = 3:6\r","    % get the values per field\r","    krow = kmatrix(ik, :)';\r","    krow_fields = reshape(krow, nmark, nfield);\r","    krow_fields = krow_fields(1, :);\r","    \r","    for ifield = 1:nfield\r","       % get the base values of this par per field\r","       ms = (ifield * numk) + 3;\r","       ma = (ifield * numk) + 4;\r","       rs = (ifield * numk) + 5; \r","       ra = (ifield * numk) + 6;\r","       switch ik\r","           case 3\r","               k3 = (ms + ma) * UM;\r","               assert(abs(krow_fields(ifield) - k3) < eps);\r","           case 4\r","               k4 = (ms - ma) * UM;\r","               assert(abs(krow_fields(ifield) - k4) < eps);\r","           case 5\r","               k5 = (-rs -ra) * UM;\r","               assert(abs(krow_fields(ifield) - k5) < eps);\r","           case 6\r","               k6 = (rs - ra) * UM;\r","               assert(abs(krow_fields(ifield) - k6) < eps);\r","       end\r","       \r","    end\r","    \r","end\r","\r","% check that order of fields in remaining matrix is correct\r","% becase of the initialised par values, each row should already be in sorted order \r","for ik = [1:2, 7:18]\r","    sortedrow = sort(kmatrix(ik, :));\r","    assert(isequal(sortedrow, kmatrix(ik, :)));\r","end\r","\r","\r","function pars = sub_get_pars(val)\r","\r","% return a valid parameter structure with all fields filled in with\r","% incremental numbers starting from val + 1\r","\r","parnames = {'K1', 'K2', 'ms', 'ma', 'rs', 'ra', 'K7', 'K8', 'K9', 'K10', ...\r","    'K11', 'K12', 'K14', 'K15', 'K16', 'K17', 'K18', 'K19'};\r","\r","for ik = 1:length(parnames)\r","    pars.(parnames{ik}) = val + ik;\r","end\r","\r"],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[3,4,5,6,7,14,15,16,17,19,20,23,25,26,27,30,32,33,34,36,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,63,64,65,74,77,78],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}