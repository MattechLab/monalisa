classdef mleRawDataReader
% The idea behind the RawData reader is that it acts as an intermediary
% with a clear interface between rawData and the rest of the code. This is
% necessary to abstract away the file format (Siemens, ismrmRD, etc.) from
% the rest of the code. For each file format a subclass is defined. To
% initialize a reader you need to use the createRawDataReader() that acts
% as a Factory Pattern to initiate the correct subclass based on the raw
% data file extension. Refer to createRawDataReader() for usage examples.
% Author: Mauro Leidi
    properties
        argFile   % Filepath to the raw data
        autoFlag   % Whether manual interaction is allowed or not
        acquisitionParams   % Stores the result of _ReadParam
    end
    
    methods
        % Constructor
        function obj = mleRawDataReader(filepath, autoFlag)
            obj.argFile = filepath;
            obj.autoFlag = autoFlag;
            % Automatically run _ReadParam and store the result
            obj.acquisitionParams = obj.readMetaData();
        end
        
        % Abstract methods to be implemented by subclasses
        function myMriAcquisition_node = readMetaData(obj)
            error('readMetaData must be implemented by the subclass');
        end

        % Abstract method to be implemented by subclasses
        function readouts = readRawData(obj, flagSS, flagNoSI)
            error('readRawData must be implemented by the subclass');
        end
    end
end

