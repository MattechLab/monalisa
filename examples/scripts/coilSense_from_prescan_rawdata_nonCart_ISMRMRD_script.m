% This script creates a coil sensitivity map for non cartesian data.

%% Setup paths and flags
% Flag; decide on values automatically if true, require user input if false
autoFlag = true;

% Flag; saves the coil sensitivity map if true
doSave = false;

% Path to prescan files
bodyCoilFile = [];
arrayCoilFile = [];

% reconDir = '../../..';
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
myMriAcquisition_node = ISMRMRD_readParam(bodyCoilFile, autoFlag);
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

% Matrix size of the cartesian grid in the k-space
N_u          = [48, 48, 48]; 


%% Read data and calculate trajectory and volume elements
% We can read the trajectory from the ismrmrd file if existing or give an
% option for different trajectories. This could also be done for the volume
% elemnt calculation.

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

% compute the gridding matrices (Gn = approximation of inverse, Gu =
% Forward, Gut = transpose of Gu) Gn and Gut are both backward
[Gn, Gu, Gut] = bmTraj2SparseMat(t, ve, N_u, dK_u); 


%% Create mask
m = bmCoilSense_nonCart_mask_automatic(y_body, Gn, autoFlag);


%% Estimate coil sensitivity
% Select one body coil as reference coil and compute its sensitivity
[y_ref, C_ref] = bmCoilSense_nonCart_ref(y_body, Gn, m, []); 



% Estimate the coil sensitivity of each surface coil using one body coil
% image as reference image C_c = (X_c./x_ref)
C_array_prime = bmCoilSense_nonCart_primary(y_array, y_ref, C_ref, Gn, ve, m);


% Do a recon, predending the selected body coil is one channel among the
% others, and optimize the coil sensitivity estimate by alternating steps
% of gradient descent (X,C)
nIter = 5; 
[C, x] = bmCoilSense_nonCart_secondary(y_array, C_array_prime, y_ref, ...
                                       C_ref, Gn, Gu, Gut, ve, nIter, ...
                                       ~autoFlag); 

% Show the result
bmImage(C);


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
    saveName = ['coil_sensitivity_map_',formattedString,'.mat'];
    savePath = fullfile(saveFolder, saveName);
    
    % Save matrix
    save(savePath, 'C');
end
