function varargout = dhIsmrmrdReadMetaData(obj)
% varargout = dhIsmrmrdReadMetaData(obj)
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
%   obj (mleIsmrmrdReader) the reader object to handle ismrmrd files.
%
% Returns:
%   varargout{1}: bmMriAcquisitionParam object containing the extracted
%    meta data.
%   varargout{2}: Double containing the extracted reconstruction FoV.
argFile = obj.argFile;
autoFlag = obj.autoFlag;
%% Extract data and xml
% Read struct containing the data
myData = h5read(argFile, '/dataset/data');
raw_data = myData.data;
h = myData.head;

% Read string containting the xml (for FOV)
myXML = h5read(argFile, '/dataset/xml');

% Parse the XML string using parseString
import matlab.io.xml.dom.*
xmlDoc = parseString(Parser,myXML);


%% Extract acquisition parameters
% Node for trajectory
myMriAcquisition_node = bmMriAcquisitionParam([]); 

% parse timestamp
myMriAcquisition_node.timestamp = h.acquisition_time_stamp;

% Number of samples per channel and acquisition
N = double(unique(h.number_of_samples));
myMriAcquisition_node.N = N;

% Number of acquisitions
nLine = size(raw_data(:), 1);
myMriAcquisition_node.nLine = nLine;

% Number of shots
nShot = size(unique(h.idx.segment(:)), 1);
myMriAcquisition_node.nShot = nShot;

% Number of segments per shot
nSeg = nLine / nShot;
myMriAcquisition_node.nSeg = nSeg;

% Number of channels
nCh = double(unique(h.active_channels));
myMriAcquisition_node.nCh = nCh;

% Number of echos (DON'T KNOW IF THIS WORKS AS I DON'T HAVE ANY DATA
% CONTAINING MORE THAN ONE ECHO)
myMriAcquisition_node.nEcho = size(unique(h.idx.contrast(:)), 1);

% Throw error if acquisition parameters change during acquisition
if size(myMriAcquisition_node.N(:), 1) > 1
    error('Different acquisitions have a different number of samples');
end

if size(myMriAcquisition_node.nCh(:), 1) > 1
    error('Different acquisitions have different active channels');
end


%% Extract FOV assuming possible changes in the XML format
encodedSpace = xmlDoc.getElementsByTagName('encodedSpace').item(0);
fovEncoded = encodedSpace.getElementsByTagName('fieldOfView_mm').item(0);
reconSpace = xmlDoc.getElementsByTagName('reconSpace').item(0);
fovRecon = reconSpace.getElementsByTagName('fieldOfView_mm').item(0);

% Get FoV from encoded space
xFoV = str2double(fovEncoded.getElementsByTagName('x').item(0).getTextContent());
yFoV = str2double(fovEncoded.getElementsByTagName('y').item(0).getTextContent());
zFoV = str2double(fovEncoded.getElementsByTagName('z').item(0).getTextContent());

% Multiply by two as a convention
myMriAcquisition_node.FoV = [xFoV, yFoV, zFoV] .* 2;

% Get FoV from reconstruction space
xFoV_recon = str2double(fovRecon.getElementsByTagName('x').item(0).getTextContent());
yFoV_recon = str2double(fovRecon.getElementsByTagName('y').item(0).getTextContent());
zFoV_recon = str2double(fovRecon.getElementsByTagName('z').item(0).getTextContent());

reconFoV = [xFoV_recon, yFoV_recon, zFoV_recon] .* 2;


%% Calculate shot drop off
% Initialize y
y_raw = complex(zeros([N, nCh, nLine]));

% Transform it into array
for i = 1:nLine
    acq = raw_data{i};
    acq = reshape(acq, [2, N, nCh]); % [complex, N, nCh]
    y_raw(:,:,i) = squeeze(acq(1,:,:) + 1i * acq(2,:,:));
end

% Change structure to [nCh, N, nLine]
y_raw = permute(y_raw, [2, 1, 3]);

% Seperate nLine into nSeg and nShot (nSeg = nLine / nShot)
y_raw      = reshape(y_raw, [nCh, N, nSeg, nShot]); 

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

% Find the shot where the standard deviation falls below the threshold
myMriAcquisition_node.nShot_off = find(running_std < threshold, 1);

%% Set flags in myMriAcquisition_node (Maybe other way to handle them?)
myMriAcquisition_node.selfNav_flag = true;
myMriAcquisition_node.roosk_flag = false;


%% Allow manual changes before returning
% Plot figures and ask for confirmation of the values if should work
% manualy
if ~autoFlag
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



