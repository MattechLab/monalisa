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
            % Handle default values for optional arguments: if no argument
            % is passed there is no data filtering.
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


