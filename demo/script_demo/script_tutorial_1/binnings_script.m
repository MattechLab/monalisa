%% Binning Generation Script
% This script demonstrates how to generate binning masks, a crucial step in
% determining how many images will be generated during reconstruction.
% We will cover three binning strategies in this tutorial,
% starting from a simple case and gradually increasing the complexity.
% The binning computation is made of two main parts:
% 1. A filtering of data that cannot be used for reconstruction. E.g.:
%    a. non steady state lines
%    b. repeated measures of the same points 
%    (in this trajectory we repeat SI projection 1 line every nSeg = 22)
% 2. A regrouping to get the desired images

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
%% Step 1: Read the Raw Data
% Here, we load the data file for the brain scan, used for binning. 
% As for coil sensitivity estimation, we use the "RawDataReader" class. 

% Load the raw data for the brain scan
brainScanFile = fullfile(dataDir, 'brainScan.dat');  % Brain scan data file

% Create a reader object for the brain scan
brainCoilReader = createRawDataReader(brainScanFile, false);
% Extract acquisition parameters from the raw data
acquisitionParams = brainCoilReader.acquisitionParams;

nSeg = acquisitionParams.nSeg;  % Number of segments
nShotOff = acquisitionParams.nShot_off;  % Number of off shots (non-steady state)
nMeasuresPerShot = acquisitionParams.nSeg;  % Measurements per shot
nExcludeMeasures = nShotOff * nMeasuresPerShot;  % Total number of measurements to exclude
nLines = acquisitionParams.nLine;  % Total number of radial lines
% Define cost time (this is typically a fixed value depending on the scanner type)
costTime = 2.5;  % Siemens-specific, don't change unless known

% Extract timestamp in milliseconds (time of each acquisition)
timeStamp = double(acquisitionParams.timestamp);
timeStamp = timeStamp - min(timeStamp);  % Normalize timestamps to start from 0
timestampMs = timeStamp * costTime;  % Convert to milliseconds

%% Step 2: Simple Binning - Include All Steady-State Lines
% In this example, we will group all steady-state lines into one bin.
% This is the simplest binning strategy, where we exclude any non-steady-state lines.

% Create a mask with all lines that are in steady state
% (excluding the first few lines which may be non-steady-state)
nbins = 1;
mask = true(nbins, nLines);  % Include all lines 

mask(nbins,1:nExcludeMeasures) = false; % Exclude non steady state

% Exclude the non-steady-state lines (e.g., SI projection or other artifacts)
for K = 0:floor(nLines / nMeasuresPerShot)
    idx = 1 + K * nMeasuresPerShot;
    if idx <= nLines
        mask(idx) = false;  % Set non-steady-state lines to false
    end
end

% Nicely display the binning mask
figure;
hold on;

% Define the color for orange as an RGB triplet
orangeColor = [1, 0.647, 0];

% Preallocate the x and y data for each category
redX = []; redY = [];
orangeX = []; orangeY = [];
greenX = []; greenY = [];

timeInSeconds = timestampMs/1000;
% Categorize the points into red, orange, and green
for i = 1:length(timeInSeconds)
    if i <= nExcludeMeasures
        redX = [redX, timeInSeconds(i)];
        redY = [redY, mask(i)];
    elseif mod(i, 22) == 1
        orangeX = [orangeX, timeInSeconds(i)];
        orangeY = [orangeY, mask(i)];
    else
        greenX = [greenX, timeInSeconds(i)];
        greenY = [greenY, mask(i)];
    end
end

% Plot all points at once for each category
scatter(orangeX, orangeY, 40, orangeColor, 'filled');
scatter(redX, redY, 40, 'r', 'filled');
scatter(greenX, greenY, 40, 'g', 'filled');

hold off;

% Add labels and title
xlabel('Time (s)');
ylabel('Logical Mask Values (0 = exclude)');
title('allLine Binning Mask (4.15s to 5s)');
grid on;
ylim([-0.1, 1.1]);  % Binary y-axis
xlim([4.15, 5]);    % Limit x-axis to the specified time range
set(gca, 'XTick', 4.15:0.05:5);  % Adjust tick density within the range
set(gcf, 'Color', 'w');  % Set white background for the figure

% Add a legend with the color descriptions
legend({'SI point (Orange)', 'Not steady-state points (Red)', 'Other points (Green)'}, 'Location', 'best');


%% Save Results
% Generate a timestamped filename for saving
saveName = fullfile(resultsDir, 'allLinesBinning.mat');

save(saveName, 'mask');
disp(['All lines inning bins saved to: ', saveName]);

%% Step 3: Medium Binning - Group Data into Bins of 5 Seconds
% In this case, we will group the data into bins of 5 seconds. This strategy
% creates several bins, each containing 5 seconds of data, and excludes non-steady-state lines.

% Define temporal window size in seconds (5 seconds in this case)
temporalWindowSec = 5;  

% Convert temporal window to milliseconds
temporalWindowMs = temporalWindowSec * 1000;

% Exclude non-steady-state measurements by considering the first few off shots

% Adjust the start time to account for non-steady-state shots
startTime = timestampMs(nExcludeMeasures + 1);
endTime = timestampMs(end);

% Calculate the total duration of valid data
totalDuration = endTime - startTime;

% Calculate the number of masks based on the temporal window size
% We take the floor to make only images with 5s of data
nMasks = floor(totalDuration / temporalWindowMs);

% Initialize the mask matrix with logical false
mask = false(nMasks, nLines);

% Fill the masks: Set to true for measurements that fall within the current temporal window
for i = 1:nMasks
    % Define the start and end of the current time window
    windowStart = startTime + (i - 1) * temporalWindowMs;
    windowEnd = windowStart + temporalWindowMs;
    
    % Create the mask for the current window (True for measurements within the window)
    singlemask = (timestampMs >= windowStart) & (timestampMs < windowEnd);
    
    % Exclude the non-steady-state lines (e.g., SI projection or other artifacts)
    for K = 0:floor(nLines / nMeasuresPerShot)
        idx = 1 + K * nSeg;
        if idx <= nLines
            singlemask(idx) = false;  % Set non-steady-state lines to false
        end
    end
    
    % Assign the mask to the binning matrix
    mask(i, :) = singlemask;
end

% Create a figure to display the temporal bins
% Initialize the figure
figureHandle = figure('Color', 'w'); % Single figure with a white background

% Create an initial plot with the first bin's data
plotHandle = plot(timestampMs / 1000, mask(1, :), 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Logical Mask Value (0 = excluded)');
title('Sequential Binning Mask: Bin 1');
grid on;
ylim([-0.1, 1.1]);  % Binary y-axiss
hold on;

% Create a UI control for bin selection
binSelector = uicontrol('Style', 'popupmenu', ...
    'String', num2cell(1:nMasks), ...  % Bin numbers as options
    'Position', [20 20 200 30], ...
    'Callback', @(src, event) updatePlot(plotHandle, src.Value, mask));

%% Save Results
% Generate a timestamped filename for saving
saveName = fullfile(resultsDir, 'sequentialBinning.mat');

save(saveName, 'mask');
disp(['Sequential bins saved to: ', saveName]);

%% Step 4: Hard Binning - Use Cardiac Physio for Binning (To be filled later)
% This step will use cardiac physiological data to group the data more accurately based on the cardiac cycle. We will skip the implementation details for now, but here is where you would use a more advanced binning strategy based on the physiological signals from the subject.

% Future Implementation Placeholder:
% hardBinningMask = ... (to be added later)

% Save the placeholder for now
% save(fullfile(resultsDir, 'hard_binning_mask_placeholder.mat'), 'hardBinningMask');

%% End of Binning Generation
% Now that we have created and saved our binning masks, we can proceed to the next steps in the reconstruction process. These masks will guide how the raw data is grouped for image reconstruction.
