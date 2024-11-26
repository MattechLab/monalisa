function reader = createRawDataReader(filepath, autoFlag)
% Factory patterns for RawDataReader. 
% Example usage:
% myreader = createRawDataReader('my/path/to/file.ext', false)
% metadata = myreader.ReadMetaData() to get metadata
% y = myreader.mleReadRawData() to get the rawdata
% Supported file formats: Siemens (.dat), ISMRMRD (.mrd).
% Author: Mauro Leidi
    % Extract file extension
    [~, ~, ext] = fileparts(filepath);
    
    % Determine reader subclass based on the extension
    % at initialization we want run the metadata extraction
    switch lower(ext)
        case '.mrd'
            reader = mleIsmrmrdReader(filepath, autoFlag);

        case '.dat'
            reader = mleSiemensReader(filepath, autoFlag);

        otherwise
            error('Unsupported file extension: %s', ext);
    end
end

