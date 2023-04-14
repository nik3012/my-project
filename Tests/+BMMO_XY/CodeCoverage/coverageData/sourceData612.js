var sourceData612 = {"FileContents":["function configuration = bmmo_3600D_ES_model_configuration()\r","% function configuration = bmmo_3600D_model_configuration()\r","%\r","% This function generates a bmmo_Configuration object, with the default\r","% bmmo model settings on a NXE:3600D_ES scanner.\r","% \r","% The configuration object is currently only used for the inline SDM model\r","%\r","% Input:\r","% none\r","%\r","% Output:\r","% configuration:  bmmo_Configuration object\r","%\r","% See also bmmo_Configuration, bmmo_3400B_model_configuration, \r","% bmmo_3400C_model_configuration, bl3_3600D_model_configuration\r","\r","configuration_data = {...\r","    'InlineSdmModel',   'Default'; ...\r","    'LensModel',        'Default'; ...\r","    'HocModel',         'Default'; ...\r","    'CetModel',         'VERSION_3'; ...\r","    'HocFilter',        'None'; ...\r","    'HocPoly2Spline',   'Disabled'; ...\r","    'HocPlayback',      'Enabled'; ...\r","\t'Lens',\t\t\t\t'3400_34'; ...\r","    };\r","    \r","configuration = bmmo_Configuration(configuration_data(:,1), ...\r","    configuration_data(:,2));\r","\r","end"],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[18,29,30],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}