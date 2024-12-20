%% Mitosius Data Preparation Script
% This script prepares data for reconstruction by:
% 1. Loading the raw brain scan data, coil sensitivity maps, and binning masks.
% 2. Computing trajectories, volume elements, and normalizing the data.
% 3. Allowing the user to select a binning strategy (AllLines or Sequential).

% Define paths for data and results
[baseDir, ~, ~] = fileparts(  matlab.desktop.editor.getActiveFilename  );
dataDir = fullfile(baseDir, '..','..', 'data_demo','data_8_tutorial_1');   % Data folder
resultsDir = fullfile(dataDir, 'results');  % Results folderv

%% Step 0: If you haven't done it already add src to your MATLAB PATH
addpath(genpath(srcDir))

% File paths
brainScanFile = fullfile(dataDir, 'brainScan.dat'); 
coilSensitivityPath = fullfile(resultsDir, 'coil_sensitivity_map.mat');  
allLinesBinningspath = fullfile(resultsDir, 'allLinesBinning.mat');  
seqBinningspath = fullfile(resultsDir, 'sequentialBinning.mat');  

%% Step 1: Load the Raw Data
autoFlag = false;  % Disable validation UI
reader = createRawDataReader(brainScanFile, autoFlag);
p = reader.acquisitionParams;
p.traj_type = 'full_radial3_phylotaxis';  % Trajectory type

% Load the raw data and compute trajectory and volume elements
y_tot = reader.readRawData(true, true);  % Filter nshotoff and SI
t_tot = bmTraj(p);                       % Compute trajectory
ve_tot = bmVolumeElement(t_tot, 'voronoi_full_radial3');  % Volume elements

%% Step 2: Load Coil Sensitivity Maps
load(coilSensitivityPath, 'C');  % Load sensitivity maps

% Adjust grid size for coil sensitivity maps
FoV = p.FoV;  % Field of View
matrix_size = FoV / 3;  % Max nominal spatial resolution
N_u = [matrix_size, matrix_size, matrix_size];
C = bmImResize(C, [48, 48, 48], N_u);

%% Step 3: Normalize the Raw Data
x_tot = bmMathilda(y_tot, t_tot, ve_tot, C, N_u, N_u, [1, 1, 1] / 384);
bmImage(x_tot);  % Display the reconstructed image
temp_im = getimage(gca); 
bmImage(temp_im);  % Display the ROI selection
temp_roi = roipoly; 
normalize_val = mean(temp_im(temp_roi(:))); 
y_tot = y_tot / normalize_val;  % Normalize the raw data

%% Step 4: Select Binning Strategy via User Interaction
choice = questdlg('Select a binning strategy:', ...
                  'Binning Selection', ...
                  'AllLines', 'Sequential', 'Cancel', 'AllLines');

switch choice
    case 'AllLines'
        load(allLinesBinningspath, 'mask');  % Load allLines binning mask
        saveFolderSuffix = 'mitosius_allLines';  % Folder suffix for AllLines
        disp('AllLines binning selected.');
    case 'Sequential'
        load(seqBinningspath, 'mask');  % Load sequential binning mask
        saveFolderSuffix = 'mitosius_sequential';  % Folder suffix for Sequential
        disp('Sequential binning selected.');
    otherwise
        error('Binning selection canceled by user.');
end


% Create the save folder with the selected suffix
saveFolder = fullfile(resultsDir, saveFolderSuffix);  
if ~exist(saveFolder, 'dir')
    mkdir(saveFolder);
end

% Reshape and clean the binning mask
mask = reshape(mask, [size(mask, 1), p.nSeg, size(mask, 2) / p.nSeg]);  % Adjust dimensions
mask(:, 1, :) = [];                 % Remove SI projection (even if they were set to false)
mask(:, :, 1:p.nShot_off) = [];     % Remove non-steady-state (even if they were set to false)
mask = bmPointReshape(mask);        % Reshape for reconstruction

% It's important to remove datapoints before computing the final volume
% elements, otherwise some points not used in the recon, will influence the
% final recon, since they change the ve computation.

%% Step 5: Apply Mitosis Function
[y, t] = bmMitosis(y_tot, t_tot, mask);  % Apply mitosis
y = bmPermuteToCol(y);                   % Prepare data in column format
ve = bmVolumeElement(t, 'voronoi_full_radial3');  % Compute volume elements

% Save the results
bmMitosius_create(saveFolder, y, t, ve);
disp(['Mitosius preparation complete. Data saved to: ', saveFolder]);