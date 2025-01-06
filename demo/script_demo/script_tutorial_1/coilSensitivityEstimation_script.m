%% Coil Sensitivity Estimation Script
% This script demonstrates how to estimate coil sensitivity using the library.

% Define paths for data and results
[baseDir, ~, ~] = fileparts(  matlab.desktop.editor.getActiveFilename  );
dataDir = fullfile(baseDir, '..','..', 'data_demo','data_8_tutorial_1');   % Data folder
resultsDir = fullfile(dataDir, 'results');  % Results folder
srcDir = fullfile(baseDir,'..','..','..','src');

%% Step 0: If you haven't done it already add src to your MATLAB PATH
addpath(genpath(srcDir))

%Add helper functions to path
helpfDir = fullfile(baseDir, '..','..','function_demo','function_tutorial_1');
addpath(genpath(helpfDir))

bodyCoilFile = fullfile(dataDir, 'bodyCoil.dat');      % Body coil data
headCoilFile = fullfile(dataDir, 'surfaceCoil.dat');% Surface coil data

%% Load and Configure Data
% Read data using the library's `createRawDataReader` function
% This readers makes the usage of Siemens and ISMRMRD files equivalent for
% the libraray
bodyCoilreader = createRawDataReader(bodyCoilFile, false);
headCoilReader = createRawDataReader(headCoilFile, false);

% Ensure consistency in number o1f shot-off points
nShotOff = max(bodyCoilreader.acquisitionParams.nShot_off, ...
               headCoilReader.acquisitionParams.nShot_off);
bodyCoilreader.acquisitionParams.nShot_off = nShotOff;
headCoilReader.acquisitionParams.nShot_off = nShotOff;

%% Parameters
dK_u = [1, 1, 1] ./ headCoilReader.acquisitionParams.FoV;   % Cartesian grid spacing
N_u = [48, 48, 48];             % Adjust this value as needed

%% Compute Trajectory and Volume Elements
[y_body, t, ve] = bmCoilSense_nonCart_data(bodyCoilreader, N_u);
y_surface = bmCoilSense_nonCart_data(headCoilReader, N_u);

% Compute the gridding matrices (subscript is a reminder of the result)
% Gn is from uniform to Non-uniform
% Gu is from non-uniform to Uniform
% Gut is Gu transposed
[Gn, Gu, Gut] = bmTraj2SparseMat(t, ve, N_u, dK_u);

%% Create Mask
mask = bmCoilSense_nonCart_mask_automatic(y_body, Gn, false);

%% Estimate Coil Sensitivity
% Reference coil sensitivity using the body coils. This is used as 
% a reference to estiamte the sensitivity of each head coil
[y_ref, C_ref] = bmCoilSense_nonCart_ref(y_body, Gn, mask, []);

% Head coil sensitivity estimate using body coil reference
C_array_prime = bmCoilSense_nonCart_primary(y_surface, y_ref, C_ref, Gn, ve, mask);

% Refine the sensitivity estimate with optimization
nIter = 5;
[C, x] = bmCoilSense_nonCart_secondary(y_surface, C_array_prime, y_ref, ...
                                       C_ref, Gn, Gu, Gut, ve, nIter, false);

%% Display Results
bmImage(C);

%% Save Results
% Generate a timestamped filename for saving
saveName = fullfile(resultsDir, 'coil_sensitivity_map.mat');

save(saveName, 'C');
disp(['Coil sensitivity map saved to: ', saveName]);
