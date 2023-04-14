function removeTempDir(obj)
% removeTempDir(obj)
%
% DO NOT CALL THIS METHOD EXPLICITLY
%
% This method is called automatically during the teardown stage of the
% test, if the test has created a temporary directory


import BMMO_XY.tools.*

if obj.tempDirCreated
    
    rmpath(obj.testTempDir);
    
    [status, msg] = rmdir(obj.testTempDir, 's');
    
    if status ~= 1
        error(getErrorId('rmdir'), 'Could not remove temporary folder, see: %s', msg);
    end

end

end