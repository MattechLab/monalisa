function readouts = dhIsmrmrdReadRawData(obj, flagSS, flagExcludeSI)
% varargout = dhIsmrmrdReadRawData(obj)
% 
% This function extracts the raw data from the ISMRM raw data file. 
% Optional filtering is enabled with the flags:
% flagSS: filter out the non steady state shots (obj.acquisitionParams.nShot_off)
% flagExcludeSI: filter out the SI projections 
%
% Authors:
%   Dominik Helbing
%   adapted by: Mauro Leidi
%   MattechLab 2024
%
% Parameters:
%   obj (mleIsmrmrdReader): The object that to handle radata.
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
    nLine = acquisitionParams.nLine;
    nShot_off = acquisitionParams.nShot_off;
    % Initialize readouts
    readouts = complex(zeros([N, nCh, nLine]));

    %% Get raw data
    % Read struct containing the data from ISMRMRD file
    myData = h5read(argFile, '/dataset/data');
    % Extract data
    raw_data = myData.data;
    for i = 1:nLine
        acq = raw_data{i};
        acq = reshape(acq, [2, N, nCh]); % [complex, N, nCh]
        readouts(:,:,i) = squeeze(acq(1,:,:) + 1i * acq(2,:,:));
    end
    
    % Change data to single precision
    readouts = single(readouts);
    
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
        error('bmTwix_data : nEcho == 2, case not implemented, yet. But we have to do it for Giulia''s data ! ');
        
    else
        error('bmTwix_data : case not implemented. ');
    end
end

    
