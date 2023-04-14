function createTempDir(obj)
% createTempDir(obj)
%
% This method creates a temporary directory that can be used by the the
% test and will automatically be cleaned up and removed after the test has
% completed.


import BMMO_XY.tools.*

obj.testTempDir = tempname(tempdir);

[status, msg] = mkdir(obj.testTempDir);

if status ~= 1
    error(getErrorId('mkdir'), 'Could not create temporary folder, see: %s', msg);
end

addpath(obj.testTempDir);

obj.tempDirCreated = true;

end