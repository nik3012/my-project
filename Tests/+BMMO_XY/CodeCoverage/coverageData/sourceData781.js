var sourceData781 = {"FileContents":["function createTempDir(obj)\r","% createTempDir(obj)\r","%\r","% This method creates a temporary directory that can be used by the the\r","% test and will automatically be cleaned up and removed after the test has\r","% completed.\r","\r","\r","import BMMO_XY.tools.*\r","\r","obj.testTempDir = tempname(tempdir);\r","\r","[status, msg] = mkdir(obj.testTempDir);\r","\r","if status ~= 1\r","    error(getErrorId('mkdir'), 'Could not create temporary folder, see: %s', msg);\r","end\r","\r","addpath(obj.testTempDir);\r","\r","obj.tempDirCreated = true;\r","\r","end"],"CoverageData":{"CoveredLineNumbers":[11,13,15,19,21],"UnhitLineNumbers":16,"HitCount":[0,0,0,0,0,0,0,0,0,0,2,0,2,0,2,0,0,0,2,0,2,0,0]}}