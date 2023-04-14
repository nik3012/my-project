var sourceData230 = {"FileContents":["function [mlOut, sbcFps] = applySbcToMl(mlIn, corr, correctionFactor, ADELler, intrafieldOrder)\r","% function [mlOut, sbcFps] = applySbcToMl(mlIn, corr, correctionFactor, ADELler, intrafieldOrder)\r","%\r","% This function takes a parsed SBC correction set, an ml structure from an \r","% OPO ADELmetrology as obtained by ovl_read_adelmetrology and the ADELler from the OPO lot. \r","% Optionally, it is possible to specify the order of intrafield corrections\r","% using intrafieldOrder.\r","% It then applies the fingerprint of the SBC correction set to the ml\r","% structure using the provided correction factor.\r","%\r","% Inputs:\r","% - mlIn        = parsed ADELmetrology containing overlay measurements as produced by\r","%                 ovl_read_adelmetrology\r","% - corr        = parsed SBC correction set as produced by\r","%                 bmmo_kt_process_SBC2 / bmmo_kt_process_SBC2rep\r","% - correctionFactor\r","%               = factor to use when applying SBC fingerprint to ml\r","%                 structure. 1 corresponds to correction, -1 corresponds to\r","%                 decorrection.\r","% - ADELler     = filepath of OPO ADELLer or xml_loaded ADELler\r","%\r","% Optional inputs:\r","% - intrafieldOrder\r","%                 = order of intrafield corrections fit to the SBC correction\r","%                 set. Possible values are 3 (18 par) and 5 (33 par). 5th\r","%                 order is the default.\r","%\r","% Outputs:\r","% - mlOut      = (de)corrected ml structure in exposure order\r","% - sbcFps     = SBC fingerprint on OPO ml layout\r","% \r","% Relevant KT: D001217927 PSA KT BL3 OPO (De)correction Tooling\r","\r","import BMMO_XY.tools.OPO.*\r","\r","% Check intrafieldOrder input\r","if ~exist('intrafieldOrder', 'var')\r","    intrafieldOrder = 5;\r","end\r","\r","% Append ADELler info to ml-struct\r","mlInfoAppended = appendInfoToMl(mlIn, ADELler);\r","\r","% (de)apply the correction\r","[mlOut, sbcFps] = applySbcToMlCore(mlInfoAppended, corr, correctionFactor, intrafieldOrder);\r","\r","% Cleanup\r","mlOut      = rmfield(mlOut, {'expinfo', 'info'});\r","mlOut.info = mlIn.info;\r","\r","end\r","\r",""],"CoverageData":{"CoveredLineNumbers":[],"UnhitLineNumbers":[37,38,42,45,48,49],"HitCount":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}}