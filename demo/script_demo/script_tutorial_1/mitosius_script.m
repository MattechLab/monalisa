%% Mitosius Data Preparation Script
% This script prepares data for reconstruction by:
% 1. Loading the raw brain scan data, coil sensitivity maps, and binning masks.
% 2. Computing trajectories, volume elements, and normalizing the data.
% 3. Allowing the user to select a binning strategy (AllLines or Sequential).

% Define paths for data and results
thisScript = mfilename('fullpath');
assert(~isempty(thisScript), 'mitosius_script:Run this file from disk (not as pasted code).');
[baseDir, ~, ~] = fileparts(thisScript);
monalisaRoot = fileparts(fileparts(fileparts(baseDir)));

addpath(genpath(fullfile(monalisaRoot, 'src')));  % include bmLocateTutorialDataDir

dataDir = bmLocateTutorialDataDir(monalisaRoot, 'data_8_tutorial_1');   % Data folder
resultsDir = fullfile(dataDir, 'results');  % Results folder
srcDir = fullfile(baseDir,'..','..','..','src');

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
% ROI: interactive (roipoly) for manual runs, deterministic auto for batch/pre-push.
roiMode = lower(strtrim(getenv('MONALISA_MITOSIUS_ROI_MODE')));
useInteractiveRoi = strcmpi(roiMode, 'interactive');
roiThreshFrac = str2double(getenv('MONALISA_MITOSIUS_ROI_THRESH_FRAC'));
if isempty(roiThreshFrac) || ~isfinite(roiThreshFrac) || roiThreshFrac <= 0
    roiThreshFrac = 0.25;
end
roiCenterFrac = str2double(getenv('MONALISA_MITOSIUS_ROI_CENTER_FRAC'));
if isempty(roiCenterFrac) || ~isfinite(roiCenterFrac) || roiCenterFrac <= 0
    roiCenterFrac = 0.30;
end
if isempty(roiMode)
    useInteractiveRoi = usejava('desktop');
end

temp_im_mag = abs(temp_im);
if useInteractiveRoi
    temp_roi = roipoly;
    roi_mode = 'interactive';
    roi_selection_source = 'user_popup';
    roi_thresh_frac = NaN;
    roi_center_frac = NaN;
else
    mx = max(temp_im_mag(:));
    if mx <= 0
        temp_roi = true(size(temp_im_mag));
    else
        thresh = roiThreshFrac * mx;
        temp_roi = temp_im_mag >= thresh;

        % Avoid empty or tiny ROI: fallback to central box.
        if nnz(temp_roi) < max(1, round(numel(temp_roi) * 0.01))
            [nr, nc] = size(temp_im_mag);
            halfSize = max(1, round(min(nr, nc) * roiCenterFrac / 2));
            cr = round(nr / 2);  cc = round(nc / 2);
            r1 = max(1, cr - halfSize + 1);  r2 = min(nr, cr + halfSize);
            c1 = max(1, cc - halfSize + 1);  c2 = min(nc, cc + halfSize);
            temp_roi = false(size(temp_im_mag));
            temp_roi(r1:r2, c1:c2) = true;
        end
    end
    roi_mode = 'auto_threshold';
    roi_selection_source = 'env_or_non_interactive_default';
    roi_thresh_frac = roiThreshFrac;
    roi_center_frac = roiCenterFrac;
end

normalize_val = mean(temp_im_mag(temp_roi(:)));
if ~isfinite(normalize_val) || normalize_val == 0
    normalize_val = 1;
end
y_tot = y_tot / normalize_val;  % Normalize the raw data

%% Step 4: Select binning strategy (GUI) or from MONALISA_MITOSIUS_BINNING / non-interactive default
envBin = lower(strtrim(getenv('MONALISA_MITOSIUS_BINNING')));
if ~isempty(envBin)
    switch envBin
        case 'alllines'
            choice = 'AllLines';
        case 'sequential'
            choice = 'Sequential';
        otherwise
            error('mitosius_script:InvalidEnv', ...
                'MONALISA_MITOSIUS_BINNING must be allLines or sequential, got "%s".', getenv('MONALISA_MITOSIUS_BINNING'));
    end
elseif usejava('desktop')
    choice = questdlg('Select a binning strategy:', ...
        'Binning Selection', ...
        'AllLines', 'Sequential', 'Cancel', 'AllLines');
else
    choice = 'AllLines';
end

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
binning_selection_source = 'default_non_interactive';
if ~isempty(envBin)
    binning_selection_source = 'env';
elseif usejava('desktop')
    binning_selection_source = 'user_popup';
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

% Export parity snapshot for mitosius-prepared data
try
    dataStruct = struct( ...
        'y_tot', y_tot, ...
        't_tot', t_tot, ...
        've_tot', ve_tot, ...
        'y', y, ...
        't', t, ...
        've', ve, ...
        'C', C, ...
        'N_u', N_u ...
    );
    meta = struct();
    meta.description = 'Mitosius data preparation outputs (y, t, ve, C, N_u).';
    meta.save_folder = saveFolder;
    meta.inputs = struct( ...
        'brain_scan_file', brainScanFile, ...
        'coil_sensitivity_file', coilSensitivityPath, ...
        'all_lines_binning_file', allLinesBinningspath, ...
        'sequential_binning_file', seqBinningspath, ...
        'traj_type', p.traj_type, ...
        'FoV', FoV, ...
        'matrix_size', matrix_size, ...
        'N_u', N_u, ...
        'autoFlag', autoFlag ...
    );
    meta.normalization = struct( ...
        'method', 'mean(abs(x_tot(roi)))', ...
        'normalize_val', normalize_val ...
    );
    meta.binning_choice = struct( ...
        'selected', choice, ...
        'selection_source', binning_selection_source ...
    );
    % ROI metadata used for deterministic normalization (used by parity export).
    meta.roi_mode = roi_mode;
    meta.roi_selection_source = roi_selection_source;
    meta.roi_env_mode = getenv('MONALISA_MITOSIUS_ROI_MODE');
    meta.roi_env_thresh_frac = getenv('MONALISA_MITOSIUS_ROI_THRESH_FRAC');
    meta.roi_env_center_frac = getenv('MONALISA_MITOSIUS_ROI_CENTER_FRAC');
    meta.roi_thresh_frac = roi_thresh_frac;
    meta.roi_center_frac = roi_center_frac;
    [roiRows, roiCols] = find(temp_roi);
    if ~isempty(roiRows)
        meta.roi_bbox = [min(roiRows), min(roiCols), max(roiRows), max(roiCols)];
    else
        meta.roi_bbox = [NaN, NaN, NaN, NaN];
    end
    save_parity_snapshot(monalisaRoot, 'mitosius', 1, 'prepared_data', dataStruct, meta);
catch ME
    warning('mitosius_script:parityExportFailed', ...
        'Failed to save parity snapshot for mitosius: %s', ME.message);
end