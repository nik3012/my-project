var sourceData760 = {"FileContents":["function cet_residual = bmmo_random_cet_residual(input_struct)\r","\r","cet_residual = bmmo_empty_cet_residual(input_struct);\r","\r","rng(123);\r","SCALING = 1e-10;\r","\r","for i_wafer = 1:numel(cet_residual.wafer)\r","    cet_residual.wafer(i_wafer).dx = randn(size(cet_residual.wafer(i_wafer).dx)) * SCALING;\r","    cet_residual.wafer(i_wafer).dy = randn(size(cet_residual.wafer(i_wafer).dx)) * SCALING;\r","end\r","\r",""],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[3,5,6,8,9,10],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0]}}