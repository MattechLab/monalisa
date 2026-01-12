classdef mleSiemensReader < mleRawDataReader
% Overload of the RawDataReader for Siemens raw data files. 
% NB: createRawDataReader() acts as a Factory Pattern to initiate the 
% correct subclass. Never instanciate readerclasses in other ways. 
% Author: Mauro Leidi    
    methods
        % Constructor calls the superclass constructor
        function obj = mleSiemensReader(filepath, autoFlag)
            obj@mleRawDataReader(filepath, autoFlag);  % Call parent constructor
        end
        % overload of the abstract function of the RawDataReader class

        % readParam: parse the metadata, returns an object of the
        % class bmMriAcquisitionParam
        function myMriAcquisition_node = readMetaData(obj)
            myMriAcquisition_node = dhSiemensReadMetaData(obj);
        end
        % getRedouts: extract the readouts, returns a complex array
        % containing the data
        function rawdata = readRawData(obj, flagSS, flagExcludeSI)
            %READRAWDATA  Read raw data with optional filtering.
            %
            %   rawdata = readRawData(obj)
            %   rawdata = readRawData(obj, flagSS)
            %   rawdata = readRawData(obj, flagSS, flagExcludeSI)
            %
            %   INPUTS:
            %     obj           - Reader object containing acquisition parameters
            %                     and the raw file handle.
            %
            %     flagSS        - (logical, optional) If true, the initial
            %                     non–steady-state readouts are filtered out.
            %                     Default = false.
            %
            %     flagExcludeSI - (logical, optional) If true, the SI projection
            %                     readouts (self-navigation lines) are excluded
            %                     from the output. Default = false.
            if nargin < 2
                flagSS = false;  % If true the non steady state readouts are filtered out
            end
            if nargin < 3
                flagExcludeSI = false;  % If true the SI projection are filtered out
            end
            % Pass the arguments to siemens_getReadouts function
            rawdata = bmSiemensReadRawData(obj,flagSS, flagExcludeSI);
        end
    end
end


