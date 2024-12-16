function cMask = mleGenerateTaskBasedBinningMasks(trialDurationSec, temporalResolutionSec, reader, debug)
    % PARAMS:
    % trialDurationSec: Duration of each trial in seconds (e.g., 40 seconds).
    % temporalResolutionSec: Temporal resolution for binning in seconds.
    % reader: the RawDataReader object.
    % debug: (Optional) boolean flag for enabling debug mode, default is false.
    % Author: Mauro Leidi.
    
    acquisitionParams = reader.acquisitionParams;
    if nargin < 4  % Check if the debug flag was provided
        debug = false;  % Set default value to false if not provided
    end
    
    % Extract nMeasures: Total number of measures.
    nMeasures   = acquisitionParams.nLine;
    nseg        = acquisitionParams.nSeg;
    nShotOff    = acquisitionParams.nShot_off;
    
    % Extract timestampMs: Vector of timestamps in milliseconds, similar to Sequential Binning
    costTime = 2.5;  % Siemens-specific constant
    timeStamp = double(acquisitionParams.timestamp);
    timeStamp = timeStamp - min(timeStamp);
    timestampMs = timeStamp * costTime;
    
    % Convert trial duration to milliseconds
    trialDurationMs = trialDurationSec * 1000;

    % Convert temporal resolution to milliseconds
    temporalResolutionMs = temporalResolutionSec * 1000;

    % Calculate the total number of measurements to exclude
    nExcludeMeasures = nShotOff * nseg;

    % Adjust start time to exclude non-steady-state shots
    startTime = timestampMs(1);
    endTime = timestampMs(end);

    % Calculate total duration for valid data
    totalDuration = endTime - startTime;

    % Calculate the number of bins based on the temporal resolution
    nBins = floor(trialDurationSec / temporalResolutionSec);

    % Initialize the mask matrix for the number of bins
    cMask = false(nBins, nMeasures);

    % Iterate over each bin and create masks based on the trial duration
    for i = 1:nBins
        % Define the start and end of the current bin window
        binStart = startTime + (i - 1) * temporalResolutionMs;
        binEnd = binStart + temporalResolutionMs;

        % Create mask for the current bin based on timestamps
        mask = (timestampMs >= binStart) & (timestampMs < binEnd) & (timestampMs > timestampMs(nExcludeMeasures));

        % Exclude SI projection for each segment, as in Sequential Binning
        for K = 0:floor(nMeasures / nseg)
            idx = 1 + K * nseg;
            if idx <= nMeasures
                mask(idx) = false;
            end
        end

        % Assign the mask to the cMask matrix
        cMask(i, :) = mask;
    end
    
    % Ensure non-steady-state measurements are excluded properly
    if any(cMask(:, 1:nExcludeMeasures), 'all')
        error('The first %d measurements (nseg * nShotOff) are not all false.', nExcludeMeasures);
    end
    
    % Debug plotting, show only the first 5 bins
    if debug
        figure;
        hold on;
        colors = lines(min(5, nBins));  % Generate colors for up to 5 bins
        timeInSeconds = timestampMs / 1000;  % Convert timestamps to seconds

        % Plot only the first 5 bins
        for i = 1:min(5, nBins)
            plot(timeInSeconds, cMask(i, :) + i, 'Color', colors(i, :));
        end

        xlabel('Time (seconds)');
        ylabel('Bin Index');
        title('Task-Based Binning Masks (First 5 Bins)');
        hold off;
    end
end
