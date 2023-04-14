var sourceData57 = {"FileContents":["function FP_INTRAF = bmmo_construct_FPS_INTRAF(ml, options)\r","% function FP_INTRAF = bmmo_construct_FPS_INTRAF(ml, options)\r","%\r","% The function generates the raw INTRAF fingerprint for the combined model\r","%\r","% Input:\r","%  ml: input ml structure\r","%  options: structure containing the fields \r","%           INTRAF.name: 1xN cell array of intrafield parameter names\r","%           INTRAF.scaling: 1xN double vector of scaling factors\r","%\r","% Output: \r","%  FP_INTRAF: INTRAF fingerprint (1xN cell array of ml structs}\r","\r","FP_INTRAF = bmmo_construct_FPS_parlist(ml, options.INTRAF.name, options.INTRAF.scaling, options);\r","\r",""],"CoverageData":{"CoveredLineNumbers":15,"UnhitLineNumbers":[],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,158,0,0]}}