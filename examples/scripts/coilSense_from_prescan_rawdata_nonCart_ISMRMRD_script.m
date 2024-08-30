% This script creates a coil sensitivity map for non cartesian data.

%% Setup paths and flags
% Flag; decide on values automatically if true, require user input if false
autoFlag = true;

% Flag; saves the coil sensitivity map if true
doSave = true;

% Path to prescan files
bodyCoilFile = [];
arrayCoilFile = [];

% reconDir = 'C:\Users\helbi\Documents\MattechLab\recon_eva';
% 
% bodyCoilFile     = [reconDir, '/C/ismrmrd_testfile_body.mdr'];
% arrayCoilFile    = [reconDir, '/C/ismrmrd_testfile_array.mdr'];

% Path to folder where the coil sensitivity map is saved
saveFolder = [];


% If paths are not set in this script, create explorer window
pathOutside = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
if isempty(bodyCoilFile)
    [fileName, fileDir] = uigetfile(  {'*.mdr'; '*.h5'}, ...
    'Pick the body coil prescan', 'MultiSelect', 'off', pathOutside);
    bodyCoilFile = fullfile(fileDir, fileName);
end

if isempty(arrayCoilFile)
    [fileName, fileDir] = uigetfile(  {'*.mdr';'*.h5'}, ...
    'Pick the surface coil prescan', 'MultiSelect', 'off', fileDir);
    arrayCoilFile = fullfile(fileDir, fileName);
end

if isempty(saveFolder) & doSave
    saveFolder = uigetdir(pathOutside, ['Select folder to save the ' ...
        'coil sensitivity map']);
end


%% Read parameters
[myMriAcquisition_node, ~] = ISMRMRD_readParam(bodyCoilFile, autoFlag); % Maybe make true always (only change values for array?, but then steady state could be a problem)
nCh_body = myMriAcquisition_node.nCh;

% Assuming the acquisition parameters are the same, they are overriden
[myMriAcquisition_node, reconFoV] = ISMRMRD_readParam(arrayCoilFile, autoFlag);
nCh_array = myMriAcquisition_node.nCh;

% All trajectory information, to generate the trajectory. 
N = myMriAcquisition_node.N;
nSeg = myMriAcquisition_node.nSeg;
nShot = myMriAcquisition_node.nShot;

% This is the FoV set during the acquisition
FoV = myMriAcquisition_node.FoV;

% nShotOff depends on magnitude shown in figure "DataInfo Magnitude" if
% automatic_flag = 0;
nShotOff = myMriAcquisition_node.nShot_off;

% K-space resolution for the reconstruction (has to be the same as the
% final reconstruction)
dK_u         = [1, 1, 1]./reconFoV;


%% Grid (how to make this automatic? Maybe give options when automatic and allow choosing when manual)
% Matrix size of the cartesian grid in the k-space
N_u          = [48, 48, 48]; 


%% How to handle the trajectory?
% We will need to ask for a predefined format. Hence we need to read the 
% data outside and pass the y_body, t has to be computed by the user.  
% We use trajectory in using the physical dimensions without convention 
% [-0.5, 0.5]

% Prepare myMriAcquisition_node.nCh for body
myMriAcquisition_node.nCh = nCh_body;
[y_body, t, ve] = bmCoilSense_nonCart_dataFromISMRMRD( bodyCoilFile, ...
                                                    N_u, ...
                                                    myMriAcquisition_node);

% Same for array coils 
myMriAcquisition_node.nCh = nCh_array;
y_array         = bmCoilSense_nonCart_dataFromISMRMRD( arrayCoilFile, ...
                                                    N_u, ...
                                                    myMriAcquisition_node);

% compute the gridding matrices (Gn = approximation of inverse, Gu = Forward,
% Gut = transposed of Gu) Gn and Gut are both backward
[Gn, Gu, Gut] = bmTraj2SparseMat(t, ve, N_u, dK_u); 


%% Make some work to try to automate it. Define two scripts.
% (Automatic and Advanced)
close_size = []; 
open_size  = []; 
m = bmCoilSense_nonCart_mask_automatic( y_body, Gn, autoFlag, close_size, ...
                                        open_size, false);


% Select one body coil and compute its sensitivity
[y_ref, C_ref] = bmCoilSense_nonCart_ref(y_body, Gn, m, []); 



% Estimate the coil sensitivity of each surface coil using one body coil
% image as reference image C_c = (X_c./x_ref)
C_array_prime = bmCoilSense_nonCart_primary(y_array, y_ref, C_ref, Gn, ve, m);


% Do a recon, predending the selected body coil is one channel among the
% others, and optimize the coil sensitivity estimate by alternating steps
% Of gradient descent (X,C)
nIter = 5; 
[C, x] = bmCoilSense_nonCart_secondary(y_array, C_array_prime, y_ref, C_ref, Gn, Gu, Gut, ve, nIter, true); 

% Close all figures
all_fig = findall(0, 'type', 'figure');
close(all_fig)

%% Save data
if doSave
    % Get the current date and time
    currentDateTime = datetime('now', 'Format', 'yyyyMMdd_HHmm');
    
    % Create a formatted string with the desired format
    formattedString = sprintf('%04d-%02d-%02d_%02d-%02d', ...
        year(currentDateTime), month(currentDateTime), ...
        day(currentDateTime), hour(currentDateTime), ...
        minute(currentDateTime));

    % Set file name
    saveName = ['coil_sensitivity_',formattedString,'.mat'];
    savePath = fullfile(saveFolder, saveName);

    save(savePath, 'C');
end
