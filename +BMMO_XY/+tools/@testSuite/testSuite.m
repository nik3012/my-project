classdef testSuite < matlab.unittest.TestCase
    %testSuite: A wrapper around "matlab.unittest.TestCase" that provides
    %           additional tailor made functionality
    %
    %           See "doc matlab.unittest.TestCase" for comprehensive
    %           documentation on the underlying test framework.
    %
    %           testSuite also includes the following methods:
    %
    %            - createTempDir
    %            - verifyWithinTol
    %            - verifyMlWithinTol
    %            - createSUT
    %
    %           See their respective documentation for more details,
    %           for example:
    %               
    %           "help BMMO_XY.tools.testSuite/createTempDir"
    
    
    properties
        
        testTempDir
                
    end
    
    properties (Hidden)
        
        tempDirCreated
        mlWdTol = 5e-10;
        
    end
    
    methods 

        createTempDir(obj)

        verifyWithinTol(obj, actual, expected, varargin)
                
        verifyMlWithinTol(obj, actual, expected, varargin)
        
        createSUT(obj, functionString)

    end
    
    methods (Static)
        
        inputArguments = getComparisonSettings(inargs)

    end
       
    methods (TestClassTeardown)
        
        removeTempDir(obj)
        
    end
end