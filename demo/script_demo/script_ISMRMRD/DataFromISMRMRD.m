%% Read ISMRMRD file
% Path to the ISMRMRD file
filePath = 'ismrmrd_testfile_body.mdr';

% Read struct containing the data
myData = h5read(filePath, '/dataset/data');
raw_data = myData.data;

% Read string containting the xml (for FOV)
myXML = h5read(filePath, '/dataset/xml');


%% Turn XML string into xmlDoc, Option 1 (temp file)
% % Define the temporary file name
% tempFileName = 'tempXML.xml';
% 
% % Open the file for writing
% fileID = fopen(tempFileName, 'w');
% 
% % Write the XML string to the file
% fprintf(fileID, '%s', myXML);
% 
% % Close the file
% fclose(fileID);
% 
% % Parse the XML file using xmlread
% xmlDoc = xmlread(tempFileName);
% delete(tempFileName);


%% Option 2 (matlab.io.xml.dom.Parser Class)
import matlab.io.xml.dom.*

% Parse the XML string using parseString
xmlDoc = parseString(Parser,myXML);


%% Option 3 (Java)
% % Convert the MATLAB string to a Java string
% javaXmlString = java.lang.String(myXML);
% 
% % Create a StringReader for the XML content
% strReader = java.io.StringReader(javaXmlString);
% 
% % Use a DocumentBuilderFactory to parse the XML
% factory = javax.xml.parsers.DocumentBuilderFactory.newInstance();
% builder = factory.newDocumentBuilder();
% xmlDoc = builder.parse(org.xml.sax.InputSource(strReader));


%% Extract values for phyllotaxis spiral
% Number of samples per channel and acquisition
N = double(unique(myData.head.number_of_samples));

% Number of acquisitions
nLine = size(myData.data(:), 1);

% Number of shots
nShot = size(unique(myData.head.idx.segment(:)), 1);

% Number of segments per shot
nSeg = nLine / nShot;

% Number of partitions (DON'T KNOW IF THIS WORKS AS I DON'T HAVE ANY DATA
% CONTAINING MORE THAN ONE PARTITION)
nPar = size(unique(myData.head.idx.kspace_encode_step_2(:)), 1);

% Number of channels
nCh = double(unique(myData.head.active_channels));

% Number of echos (DON'T KNOW IF THIS WORKS AS I DON'T HAVE ANY DATA
% CONTAINING MORE THAN ONE ECHO)
nEcho = size(unique(myData.head.idx.contrast(:)), 1);

% Throw error if acquisition parameters change during acquisition
if size(N(:), 1) > 1
    error('Different acquisitions have a different number of samples');
end

if size(nCh(:), 1) > 1
    error('Different acquisitions have different active channels');
end


%% Extract FOV assuming possible changes in the XML format
% encodedSpace = xmlDoc.getElementsByTagName('encodedSpace').item(0);
% fovEncoded = encodedSpace.getElementsByTagName('fieldOfView_mm').item(0);
% reconSpace = xmlDoc.getElementsByTagName('reconSpace').item(0);
% fovRecon = encodedSpace.getElementsByTagName('fieldOfView_mm').item(0);
% 
% xFoV = str2double(fovEncoded.getElementsByTagName('x').item(0).getTextContent());
% yFoV = str2double(fovEncoded.getElementsByTagName('y').item(0).getTextContent());
% zFoV = str2double(fovEncoded.getElementsByTagName('z').item(0).getTextContent());
% 
% FoV = [xFoV, yFoV, zFoV] .* 2;
% 
% xFoV_recon = str2double(fovRecon.getElementsByTagName('x').item(0).getTextContent());
% yFoV_recon = str2double(fovRecon.getElementsByTagName('y').item(0).getTextContent());
% zFoV_recon = str2double(fovRecon.getElementsByTagName('z').item(0).getTextContent());
% 
% FoV_recon = [xFoV_recon, yFoV_recon, zFoV_recon] .* 2;


%% Extract FOV assuming ISMRMRD standard XML file (know item number)
xFoV = str2double(xmlDoc.getElementsByTagName('x').item(1).getTextContent());
yFoV = str2double(xmlDoc.getElementsByTagName('y').item(1).getTextContent());
zFoV = str2double(xmlDoc.getElementsByTagName('z').item(1).getTextContent());

FoV = [xFoV, yFoV, zFoV] .* 2;

xFoV_recon = str2double(xmlDoc.getElementsByTagName('x').item(3).getTextContent());
yFoV_recon = str2double(xmlDoc.getElementsByTagName('y').item(3).getTextContent());
zFoV_recon = str2double(xmlDoc.getElementsByTagName('z').item(3).getTextContent());

FoV_recon = [xFoV_recon, yFoV_recon, zFoV_recon] .* 2;

clear xFoV yFoV zFoV xFoV_recon yFoV_recon zFoV_recon
%% Extract data
% Data is stored as follows:
%   Cell array of size nLine (Total number of acquisitions)
%   Each cell of size N*nCh*2 (real then imaginary part)
%       First 2*N elements are for channel 1
%       Element 2*N+1 is first element of channel 2
%       Odd elements are the real part, even elements are imaginary

% Initialize y
y_raw = complex(zeros([N, nCh, nLine]));

% Extract data
for i = 1:nLine
    acq = raw_data{i};
    acq = reshape(acq, [2, N, nCh]); % [complex, N, nCh]
    y_raw(:,:,i) = squeeze(acq(1,:,:) + 1i * acq(2,:,:));
end


%% Part from bmTwix_info to display magnitude spectrum figure for drop off
% Change structure to [nCh, N, nLine]
y_raw = permute(y_raw, [2, 1, 3]);

% Seperate nLine into nSeg and nShot (nSeg = nLine / nShot)
y_raw      = reshape(y_raw, [nCh, N, nSeg, nShot]); 

% Reduce the array to a 3D array, only containing the values for the first segment
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
window_size = 10;  % Define the size of the sliding window
threshold = std(s_mean)*0.1; %0.01 % Define a threshold for the std to consider steady state

% Compute the running standard deviation
running_std = movstd(s_mean, window_size);

% Find the shot where the standard deviation falls below the threshold
shotOff = find(running_std < threshold, 1);


%% Plot figure (bmTwix_info)
% Plotting heatmap of magnitude for the first segment of each shot
figure('Name', 'TwixInfo Magnitude')
imagesc(mySI, [0, 3*mean(mySI(:))]); 
set(gca,'YDir','normal');
colorbar
colormap gray

% Plotting the mean and COM of each shot
hold on
plot(s_center_mass, 'g.-')
plot(s_mean, 'r.-')

% Plotting vertical line for shotOff
if ~isempty(shotOff)
    xline(shotOff, 'c--');  % Add vertical line at steady state index
    text(shotOff+5, floor(N*0.75), sprintf('shot = %i', ...
        shotOff), "HorizontalAlignment", "left", ...
        'Color', 'black', 'BackgroundColor', 'white', 'Margin', 0.5);
end

% Adding legend, title and labels
legend('Center of Mass', 'Mean', 'Steady State', 'Location', 'best')
xlabel('nShot')
ylabel('N','Rotation',0)
title(sprintf(['Magnitude spectrum for first segment of each shot\n(estimates ' ...
    'which shots should be excluded)']))
hold off


%% Ask for confirmation if shotOff is correct
nShotOff     = shotOff; 
selfNav_flag   = true;

% Create the question dialog with Yes and Other options
choice = questdlg(['The estimated value is ', num2str(nShotOff), '. Is this correct?'], ...
    'Confirm Value', ...
    'Yes', 'No', 'Yes');

% Handle response
switch choice
    case 'Yes'
        % The user accepted the estimated value
        disp(['Using estimated value: ', num2str(nShotOff)]);
        
    case 'No'
        % The user wants to input a different value
        newShotOff = inputdlg('Please enter the correct value:', 'Input New Value', [1 50], {num2str(nShotOff)});
        
        % Convert the input to a number and use it
        if ~isempty(newShotOff) % Check if the user didn't cancel
            nShotOff = floor(str2double(newShotOff{1}));
            disp(['Using new value: ', num2str(nShotOff)]);
        else
            disp('No value entered. Keeping the original value.');
        end
        
    otherwise
        % This handles the case where the dialog is closed
        disp('No selection made. Keeping the original value.');
end


%% Code part of coilSense_from_prescan_rawdata_nonCart_script
% Matrix size of the cartesian grid in the k-space
N_u          = [48, 48, 48]; 

% K-space resolution for the reconstruction (has to be the same as the
% final reconstruction)
reconFoV = 480; % magic number
dK_u         = [1, 1, 1]./reconFoV;


%% Code part of bmTwix_data, remove parts of data
% If a navigation was acquired it should be removed from the rawdata
% (remove first segment)
nS = nSeg;
nSh = nShot;
if selfNav_flag 
    y_raw(:, :, 1, :) = [];
    nS = nS - 1;
end

% Remove all shots that were not in steady state
if nShotOff > 0
    y_raw(:, :, :, 1:nShotOff) = [];
    nSh = nSh - nShotOff;
end

% Reshape back to [nCh, N, nLine] after removing some data
y = reshape(y_raw, [nCh, N, nS*nSh]);


%% Create Trajectory (code from bmCoilSense_nonCart_dataFromTwix)
% Node for trajectory
myMriAcquisition_node                = bmMriAcquisitionParam([]); 
myMriAcquisition_node.N              = N; 
myMriAcquisition_node.nSeg           = nSeg; 
myMriAcquisition_node.nShot          = nShot;
myMriAcquisition_node.FoV            = FoV; 
myMriAcquisition_node.nCh            = nCh; 
myMriAcquisition_node.nEcho          = 1; 

myMriAcquisition_node.selfNav_flag   = selfNav_flag; 
myMriAcquisition_node.nShot_off      = nShotOff; 
myMriAcquisition_node.selfNav_flag   = false; 
myMriAcquisition_node.nShot_off      = 0; 
myMriAcquisition_node.roosk_flag     = false; 

% Compute trajectory and express it as points in 3 dimensions [3, #points]
t = bmPointReshape(...
    bmTraj_fullRadial3_phyllotaxis_lineAssym2(myMriAcquisition_node));


%% Get trajectory from file, if given (How to handle selfNav and shotOff?)
% % Load file with trajectory
% filePath = 'ismrmrd_testfile_body_w_traj.mdr';
% 
% % Read struct containing the data
% myData = h5read(filePath, '/dataset/data');
% traj = myData.traj;
% 
% % Concatenate trajectory
% t2 = [];
% for i=1:nLine
%     t2 = cat(2,t2,reshape(traj{i}, [3, N]));
% end
% t2 = double(t2);

% % isequal(t2,t) = 0, isequal(single(t2),single(t)) = 1
% % In double it has some floating point errors



