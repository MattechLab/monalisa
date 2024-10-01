function readouts = bmSiemensReadRawData(obj, flagSS, flagExcludeSI)
% varargout = bmSiemensReadRawData(obj)
% 
% This function extracts the raw data from the ISMRM raw data file. 
% Optional filtering is enabled with the flags:
% flagSS: filter out the non steady state shots (obj.acquisitionParams.nShot_off)
% flagExcludeSI: filter out the SI projections 
%
% Authors:
%   Bastien Milani
%   adapted by: Mauro Leidi
%   MattechLab 2024
%
% Parameters:
%   obj (mleSiemensReader): The object that to handle radata.
%   flagSS (Logical): Flag; Filter out non steady state shots if true.
%   flagExcludeSI (Logical): Flag; Filter out SI projections if true.
%
% Returns:
%   readouts: the extracted raw data in [nCh, N, nSeg*nShot] format.
    argFile = obj.argFile;
    acquisitionParams = obj.acquisitionParams;
    nCh = acquisitionParams.nCh;
    N = acquisitionParams.N;
    nSeg = acquisitionParams.nSeg;
    nShot = acquisitionParams.nShot;
    nEcho = acquisitionParams.nEcho;
    nShot_off = acquisitionParams.nShot_off;
    % Siemens-specific data extraction logic
    myTwix = mapVBVD_JH_for_monalisa(argFile);
    if iscell(myTwix)
        myTwix = myTwix{end};
    end
    % unsorted() returns the unsorted data as an array [N, nCh, nSeg*nShot]
    readouts   = myTwix.image.unsorted();
    % Reshape readouts to our convention shape: 
    if nEcho == 1
        % Change structure to [nCh, N, nLine] and seperate nLine into nSeg and
        % nShot
        readouts   = permute(readouts, [2, 1, 3]);
        readouts   = reshape(readouts, [nCh, N, nSeg, nShot]);
        if flagSS
            if nShot_off > 0
                readouts(:, :, :, 1:nShot_off) = [];
                nShot = nShot - nShot_off;
            end
        end
        if flagExcludeSI
            readouts(:, :, 1, :) = [];
            nSeg = nSeg - 1;
        end
        % Reshape the output to [nCh, N, nSeg*nShot]
        readouts  = reshape(readouts, [nCh, N, nSeg*nShot]);
    
    elseif nEcho == 2
        error('bmTwix_data : nEcho == 2, case not implemented, yet.');
        
    else
        error('bmTwix_data : case not implemented. ');
    end
end

    