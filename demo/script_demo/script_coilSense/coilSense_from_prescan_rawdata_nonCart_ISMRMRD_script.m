% This script creates a coil sensitivity map for non cartesian data.
%% SET YOUR PARAMETERS FOR THE COIL SENSITIVITY ESTIMATION

% K-space resolution for the reconstruction (has to be the same as the
% final reconstruction)
reconFoV = 384;

dK_u         = [1, 1, 1]./reconFoV;

% Matrix size of the cartesian grid in the k-space
N_u          = [48, 48, 48]; 
%% END: SET YOUR PARAMETERS

%% Setup paths and flags
% Flag; decide on values automatically if true, require user input if false
autoFlag = false;

% Flag; saves the coil sensitivity map if true
doSave = true;

% Path to prescan files
bodyCoilFile = [];
arrayCoilFile = [];

% Path to folder where the coil sensitivity map is saved
saveFolder = [];


% If paths are not set in this script, create explorer window
pathOutside = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));

if isempty(bodyCoilFile)
    [fileName, fileDir] = uigetfile({'*.mrd;*.dat;*.h5', 'Supported Files (*.mrd, *.dat, *.h5)'}, ...
    'Pick the body coil prescan', 'MultiSelect', 'off', pathOutside);
    bodyCoilFile = fullfile(fileDir, fileName);
end


if isempty(arrayCoilFile)
    [fileName, fileDir] = uigetfile({'*.mrd;*.dat;*.h5', 'Supported Files (*.mrd, *.dat, *.h5)'}, ...
    'Pick the surface coil prescan', 'MultiSelect', 'off', fileDir);
    arrayCoilFile = fullfile(fileDir, fileName);
end

if isempty(saveFolder) & doSave
    saveFolder = uigetdir(pathOutside, ['Select folder to save the ' ...
        'coil sensitivity map']);
end

%% Read parameters
bodyreader = createRawDataReader(bodyCoilFile, autoFlag);
bodyreader.acquisitionParams.traj_type = 'full_radial3_phylotaxis';
bodyreader.acquisitionParams.selfNav_flag = true;
arrayreader = createRawDataReader(arrayCoilFile, autoFlag);
arrayreader.acquisitionParams.traj_type = 'full_radial3_phylotaxis';
arrayreader.acquisitionParams.selfNav_flag = true;

% MAKE SURE THE Number of shot off is consistent between the two acquisitions.
nShotOff = max(bodyreader.acquisitionParams.nShot_off,arrayreader.acquisitionParams.nShot_off);
bodyreader.acquisitionParams.nShot_off = nShotOff;
arrayreader.acquisitionParams.nShot_off = nShotOff;
%% Read data and calculate trajectory and volume elements
% We can read the trajectory from the ismrmrd file if existing or give an
% option for different trajectories. This could also be done for the volume
% elemnt calculation.

% Prepare myMriAcquisition_node.nCh for body
[y_body, t, ve] = bmCoilSense_nonCart_data( bodyreader, ...
                                                    N_u);

% Same for array coils 
y_array         = bmCoilSense_nonCart_data( arrayreader, ...
                                                    N_u);
disp(size(t))
disp(size(y_body))
disp(size(y_array))
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
