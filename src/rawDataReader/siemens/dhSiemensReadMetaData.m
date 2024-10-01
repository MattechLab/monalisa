function varargout = dhSiemensReadMetaData(obj)
% varargout = dhSiemensReadMetaData(obj)
% 
% This function extracts the meta data from the ISMRM raw data file. Allows
% for user modification of the meta data if the flag is set to true. The
% code execution is interrupted during the modification.
%
% Authors:
%   Dominik Helbing
%   adapted by: Mauro Leidi
%   MattechLab 2024
%
% Parameters:
%   argFile (Char): The path to the file.
%   autoFlag (Logical): Flag; Does allow user modification if false.
%    Simplifies use if true.
%
% Returns:
%   varargout{1}: bmMriAcquisitionParam object containing the extracted
%    meta data.
%   varargout{2}: Double containing the extracted reconstruction FoV.
    argFile = obj.argFile;
    autoFlag = obj.autoFlag;
    % Siemens-specific data extraction logic
    myTwix = mapVBVD_JH_for_monalisa(argFile);
    if iscell(myTwix)
        myTwix = myTwix{end};
    end
    
    %% header
    N      = getattr(myTwix.image, 'NCol', -1);
    nShot  = getattr(myTwix.image, 'NSeg', -1);
    nLine  = getattr(myTwix.image, 'NLin', -1);
    nEcho  = getattr(myTwix.image, 'NEco', -1);

    FoV = [-1,-1,-1];
    if isfield(myTwix.hdr, 'Meas')
        if isfield(myTwix.hdr.Meas, 'ReadFoV')
            FoV = myTwix.hdr.Meas.ReadFoV*2;
        end
        if isfield(myTwix.hdr.Meas, 'FOV')
            FoV = myTwix.hdr.Meas.FOV*2;
        end
    elseif isfield(myTwix.hdr, 'Protocol')
        if isfield(myTwix.hdr.Protocol, 'ReadFoV')
            FoV    = myTwix.hdr.Protocol.ReadFoV*2;
        end
        if isfield(myTwix.hdr.Protocol, 'PeFOV')
            FoV   = myTwix.hdr.Protocol.PeFOV*2;
        end
        if isfield(myTwix.hdr.Protocol, 'PhaseFoV')
            FoV   = myTwix.hdr.Protocol.PhaseFoV*2;
        end
    elseif isfield(myTwix.hdr, 'Config')
        if isfield(myTwix.hdr.Config, 'ReadFoV')
            FoV      = myTwix.hdr.Config.ReadFoV*2;
        end
        if isfield(myTwix.hdr.Config, 'PhaseFoV')
            FoV     = myTwix.hdr.Config.PhaseFoV*2;
        end
        if isfield(myTwix.hdr.Config, 'PeFOV')
            FoV        = myTwix.hdr.Config.PeFOV*2;
        end
        if isfield(myTwix.hdr.Config, 'RoFOV')
            FoV        = myTwix.hdr.Config.RoFOV*2;
        end
    elseif isfield(myTwix.hdr, 'Dicom')
        if isfield(myTwix.hdr.Dicom, 'dPhaseFOV')
            FoV     = myTwix.hdr.Dicom.dPhaseFOV*2;
        end
        if isfield(myTwix.hdr.Dicom, 'dReadoutFOV')
            FoV   = myTwix.hdr.Dicom.dReadoutFOV*2;
        end
    end

    % unsorted() returns the unsorted data as an array [N, nCh, nLine]
    y_raw = myTwix.image.unsorted();
    
    if nEcho == 1
        % Change structure to [nCh, N, nLine] and seperate nLine into nSeg and
        % nShot
        y_raw   = permute(y_raw, [2, 1, 3]);
        % Get nCh
        y_raw_size = size(y_raw); 
        y_raw_size = y_raw_size(:)'; 
        nCh        = y_raw_size(1, 1); 
        y_raw   = reshape(y_raw, [nCh, N, nSeg, nShot]);
    else
        error('bmTwix_data : nEcho > 1, case not implemented, yet ');
    end
    
   
    % Reduce the array to a 3D array, only containing the values for the first
    % segment 
    mySI = squeeze(y_raw(:, :, 1, :));
    
    % Calculate the inverse discret Fourier transform
    mySI = bmIDF(mySI, 1, [], 2);
    
    % Calculate the RMS along the first dimension (Coils) 
    % -> magnitude spectrum of the signal
    mySI = squeeze(  sqrt(sum(abs(mySI).^2, 1))  );
    
    % Normalize the magnitude
    mySI = mySI - min(mySI(:)); 
    mySI = mySI/max(mySI(:)); 
    
    % Create 2D array of size N x nShot with each column being [1; 2; ...; N]
    mySize_1 = size(mySI, 1);
    mySize_2 = size(mySI, 2);
    x_SI = 1:mySize_1;
    x_SI = repmat(x_SI(:), [1, mySize_2]);
    
    % Calculate the weighted arithmetic mean and the weighted mean (COM)
    s_mean = mean(x_SI.*mySI, 1);
    s_center_mass = sum(x_SI.*mySI, 1)./sum(mySI, 1);
    
    % Estimate shotOff (how many shots to be dropped)
    % Define the size of the sliding window
    window_size = 5; %magic number
    
    % Compute the running standard deviation
    running_std = movstd(s_mean, window_size, 'Endpoints', 'discard');
    
    % Define a threshold for the std to consider steady state
    threshold = prctile(running_std, 15);  % 10th percentile of std
    %% Extract acquisition parameters
    % Node for trajectory
    myMriAcquisition_node = bmMriAcquisitionParam([]); 
    myMriAcquisition_node.N = N;
    myMriAcquisition_node.nLine = nLine;
    myMriAcquisition_node.nShot = nShot;
    myMriAcquisition_node.nSeg = nSeg;
    myMriAcquisition_node.nCh = nCh;
    myMriAcquisition_node.nEcho = nEcho;
    myMriAcquisition_node.FoV = FoV;

    % Find the shot where the standard deviation falls below the threshold
    myMriAcquisition_node.nShot_off = find(running_std < threshold, 1);
    
    %% Set flags in myMriAcquisition_node (Maybe other way to handle them?)
    myMriAcquisition_node.selfNav_flag = true;
    myMriAcquisition_node.roosk_flag = false;

    
    reconFoV = FoV;

    if ~autoFlag || isequal(reconFoV, [-1, -1, -1])
    [myMriAcquisition_node, reconFoV] = checkMetadataInteractive(mySI, s_mean, ...
        s_center_mass, myMriAcquisition_node, reconFoV);
    end
    
    % Return values if required
    if nargout > 0
        varargout{1} = myMriAcquisition_node;
    end
    
    if nargout > 1
        varargout{2} = reconFoV;
    end

end

