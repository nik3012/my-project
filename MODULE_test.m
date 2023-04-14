function allTestsPassed = MODULE_test(varargin)

% Get the root of this module
moduleRoot = fileparts(mfilename('fullpath'));

% Process input arguments
inputArguments = processInputArguments(varargin);

% Determine which tests to perform
switch inputArguments.whichTests
    case 'all'
        testsToExecute = {[moduleRoot filesep 'testSuite' filesep 'testCases']; ...
                          [moduleRoot filesep 'testSuite' filesep 'testCasesExt']; ...
                          [moduleRoot filesep 'testSuite' filesep 'testCasesWindows']; ...
                          'BMMO_XY'};
    case 'base'
        testsToExecute = {[moduleRoot filesep 'testSuite' filesep 'testCases']; ...
                          'BMMO_XY'};
    case 'extended'
        testsToExecute = {[moduleRoot filesep 'testSuite' filesep 'testCases']; ...
                          [moduleRoot filesep 'testSuite' filesep 'testCasesExt']; ...
                          'BMMO_XY'};
    case 'windows'
        testsToExecute = {[moduleRoot filesep 'testSuite' filesep 'testCasesWindows']};
    case 'none'
        disp('Dry-run, no tests will be executed.');
        testsToExecute = {};
    otherwise
        error('Tests incorrectly specified');
end

% Create input arguments for runtests
runtestsOptions = {'IncludeSubPackages', true, 'UseParallel', inputArguments.useParallel};

% Disable warnings
warning('off', 'all');

% Isolate Module
module.IsolatedModule(moduleRoot);

% Include the test directories
modConf  = MODULE_conf();
testDirs = cellfun(@(x) replace(x, '.', moduleRoot), modConf.testDir, 'UniformOutput', false);
cellfun(@(x) addpath(x), testDirs);

% Run the tests
allTestsPassed = true;
for index = 1 : length(testsToExecute)
    try
        testsPassed = xunit_runtests(testsToExecute{index}, '-verbose');
    catch
        testsResults = runtests(testsToExecute{index}, runtestsOptions{:});
        testsPassed  = all(arrayfun(@(x) x.Passed, testsResults));
    end
    allTestsPassed = allTestsPassed && testsPassed;
end

% Reenable warnings
warning('on', 'all');

end


function inputArguments = processInputArguments(inargs)

p = inputParser;

validationFunctionText    = @(x) ischar(x);
validationFunctionlogical = @(x) isa(x, 'logical');

defaultWhichTests  = 'base';
defaultUseParallel = false;

p.addParameter('whichTests', defaultWhichTests, validationFunctionText);
p.addParameter('useParallel', defaultUseParallel, validationFunctionlogical);

p.parse(inargs{:});

inputArguments = p.Results;

end
