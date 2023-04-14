classdef bmmo_ConfigurationParameterFactory < handle
    %% bmmo_ConfigurationParameterFactory
    % Factory object for generating bmmo_ConfigurationParameters
    % The parameter names are:
    % InlineSdmModel, LensModel, Lens, HocModel, CetModel, HocFilter,
    % HocPoly2Spline, HocPlayback.
    % Each parameter has it's own class, listing the possible values e.g.:
    % bmmo_ConfigurationParameterInlineSdmModel.
    % This class should not be called directly, but is used by
    % the bmmo_Configuration object.
    % See also: bmmo_Configuration, bmmo_ConfigurationParameter 
    
    properties
        dictionary = containers.Map();
    end
    
    methods (Access = private)
        function obj = bmmo_ConfigurationParameterFactory()
            % Define a lookup table for all used config parameters
            % When more parameters are added, this table can be extended
            obj.dictionary('InlineSdmModel') = {1, @(x) bmmo_ConfigurationParameterInlineSdmModel(x)};
            obj.dictionary('LensModel')      = {1, @(x) bmmo_ConfigurationParameterLensModel(x)};
            obj.dictionary('Lens')           = {1, @(x) bmmo_ConfigurationParameterLens(x)};
            obj.dictionary('HocModel')       = {1, @(x) bmmo_ConfigurationParameterHocModel(x)};
            obj.dictionary('CetModel')       = {1, @(x) bmmo_ConfigurationParameterCetModel(x)};
            obj.dictionary('HocFilter')      = {1, @(x) bmmo_ConfigurationParameterHocFilter(x)};
            obj.dictionary('HocPoly2Spline') = {1, @(x) bmmo_ConfigurationParameterHocPoly2Spline(x)};
            obj.dictionary('HocPlayback')    = {1, @(x) bmmo_ConfigurationParameterHocPlayback(x)};
			
        end
    end
    
    methods  (Static)    % Pattern for singleton object in Matlab
        function obj = getInstance()
            persistent singletonObj;
            if isempty(singletonObj)
                singletonObj = bmmo_ConfigurationParameterFactory();
            end
            obj = singletonObj;
        end
    end
    
    methods
        function [parameter, evaluation_index] = getParameter(obj, name, value)
            try
                dictionary_entry = obj.dictionary(name);
                par_constructor = dictionary_entry{2};
                evaluation_index = dictionary_entry{1};
                parameter = feval(par_constructor, value);
            catch err
                if strcmp(err.identifier, 'MATLAB:Containers:Map:NoKey')
                    error('Unknown configuration parameter %s', name);
                else
                    rethrow(err);
                end
            end
        end
    end
    
end

