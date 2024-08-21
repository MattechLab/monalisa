function cMask = generateSequentialBinningMasks(temporalWindowSec, filepathRawdata, nShotOff, debug)
    % PARAMS:
    % temporalWindowSec: Temporal window size in seconds
    % filepathRawdata: the path to the Siemens rawdata file
    % nShotOff: number of non-steady-state lines
    % debug: (Optional) boolean flag for enabling debug mode, default is false

    if nargin < 4  % Check if the debug flag was provided
        debug = false;  % Set default value to false if not provided
    end

    % Read twix object
    mytwix = mapVBVD_JH_for_monalisa(filepathRawdata);
    if iscell(mytwix)
        myTwix = mytwix{end};
    end
   
    % Extract nMeasures: Total number of measures.
    nMeasures = myTwix.image.NLin;

    % Extract timestampMs: Vector of timestamps in milliseconds.

    % Start count only on valid shots
    costTime = 2.5;
    timeStamp = double(myTwix.image.timestamp);
    timeStamp = timeStamp - min(timeStamp);
    timestampMs = timeStamp * costTime;
    
    % Convert temporal window to milliseconds
    temporalWindowMs = temporalWindowSec * 1000;
    
    % Calculate the total number of measurements to be excluded
    nMeasuresPerShot = 22;
    nExcludeMeasures = nShotOff * nMeasuresPerShot;

    % Adjust start time to account for non-steady-state shots
    startTime = timestampMs(nExcludeMeasures + 1);
    endTime = timestampMs(end);
    
    % Calculate the total duration for valid data
    totalDuration = endTime - startTime;
    
    % Calculate the number of masks
    nMasks = floor(totalDuration / temporalWindowMs);
    
    % Initialize the mask matrix with logical false
    cMask = false(nMasks, nMeasures);

    % Fill the masks
    for i = 1:nMasks
        % Define the start and end of the current time window
        windowStart = startTime + (i-1) * temporalWindowMs;
        windowEnd = windowStart + temporalWindowMs;
        
        % Create the mask for the current window
        mask = (timestampMs >= windowStart) & (timestampMs < windowEnd);

        % Apply the condition to set the index 1 + K*22 to false:
        % This removes the SI projection from all reconstruction volumes
        for K = 0:floor(nMeasures/nMeasuresPerShot)
            idx = 1 + K*22;
            if idx <= nMeasures
                mask(idx) = false;
            end
        end

        % Assign the mask to the cMask matrix
        cMask(i, :) = mask;
    end
    
    % Check if the first 22*nShotOff measurements are all false
    if any(cMask(:, 1:nExcludeMeasures), 'all')
        error('The first %d measurements (22 * nShotOff) are not all false.', nExcludeMeasures);
    end

    % If debug mode is enabled, plot the binning
    if debug
        figure;
        hold on;
        colors = lines(nMasks);  % Generate a set of colors
        timeInSeconds = timestampMs / 1000;  % Convert timestamps to seconds

        for i = 1:nMasks
            % Plot each mask in a different color
            plot(timeInSeconds, cMask(i, :) + i, 'Color', colors(i, :));
        end

        xlabel('Time (seconds)');
        ylabel('Mask Index');
        title('Binning Masks');
        hold off;
    end
end
