function [thRMS, thMIP] = thresholdRMS_MIP(colorMax, dataRMS, dataMIP, N_u, autoFlag)
% [thRMS, thMIP] = thresholdRMS_MIP(colorMax, dataRMS, dataMIP, ...
%                                  N_u, automaticFlag)
%
% This function sets a threshold for the values of the RMS and MIP value
% calculated along the channels for 3D data. The threshold are
% automatically estimated by assuming the data to have a multimodal
% distribuition made out of two normal distributions. One for the noise and
% one for the actual data. A Gaussian mixture model (GMM) is fitted to the 
% data and the point where the possibility of the pixel intensity belonging
% to the data is higher than the possibility of the intensity to be noise
% is taken as the treshold value. It is assumed that the mean of the noise
% distribution is lower (darker pixels).
%
% Authors:
%   Dominik Helbing
%   MattechLab 2024
%
% Parameters:
%   colorMax (list): The value used to scale the RMS and MIP values. This
%   gives the possible maximum of the threshold (colorMax-1).
%   dataRMS (array): The RMS values of the data over its channels. This is 
%   a 3D image.
%   dataMIP (array): The MIP values of the data over its channels. This is 
%   a 3D image.
%   N_u (list): Size of the data in block format.
%   autoFlag (logical): flag; Automatically decide on thresholds if true.
%   Show figure and interrupt code to manually set if false.
%   
% Returns:
%   thRMS (int): The threshold value above which the RMS values are kept.
%   thMIP (int): The threshold value above which the MIP values are kept.

    %% Inizialize arguments
    % Ensure block format and single precision
    dataRMS = single(bmBlockReshape(dataRMS, N_u));
    dataMIP = single(bmBlockReshape(dataMIP, N_u));

    % Initialize variables spaning multiple nested functions for view
    permutation = [1,2,3];
    curImNum = 24;
    useContrast = false;
    activeSize = size(dataRMS,3);

    % And to track dragging state and the dragged line
    isDragging = false;
    activeLine = [];

    %% Guess threshold
    % Get initial values for MIP and RMS thresholds
    [thRMS, pdf1R, pdf2R] = detectThreshold_GMM2(dataRMS);
    [thMIP, pdf1M, pdf2M] = detectThreshold_GMM2(dataMIP);
    
    % Return out of function if threshold is only detected automatically
    if autoFlag
        return
    end

    %% Optionally show histogram (can only be set true here)
    showHistogram = false;
    if showHistogram
        figure;
        tiledlayout('vertical');
        nexttile;
        hold on
        histogram(dataRMS, 'Normalization', 'pdf');
        xVal = linspace(min(dataRMS(:)), max(dataRMS(:)), 1000);
        plot(xVal, pdf1R(xVal), '--', 'LineWidth', 2);
        plot(xVal, pdf2R(xVal), '--', 'LineWidth', 2);
        hold off
        nexttile;
        hold on
        histogram(dataMIP, 'Normalization', 'pdf');
        xVal = linspace(min(dataMIP(:)), max(dataMIP(:)), 1000);
        plot(xVal, pdf1M(xVal), '--', 'LineWidth', 2);
        plot(xVal, pdf2M(xVal), '--', 'LineWidth', 2);
        hold off
    end


    %% Prepare figure for threshold selection
    % Get number of points of x
    nPix = size(dataRMS(:), 1); 

    n_RMS = zeros(1, colorMax);
    n_MIP = zeros(1, colorMax);

    % Calculate the fraction of points having a value bigger than every 
    % integer from 0 to colorMax-1
    for i = 0:colorMax-1
        n_RMS(1, i+1) = sum(dataRMS(:) > i)/nPix;
        n_MIP(1, i+1) = sum(dataMIP(:) > i)/nPix;
    end

    % Create figure with tile layout (top is selection and bottom is view)
    fig = figure('WindowScrollWheelFcn', @myWindowScrollWheelFcn);
    t = tiledlayout(fig,2,2);
    set(t, 'Position', [0.1, 0.15, 0.8, 0.8]);

    % Create axes
    axSel = nexttile([1,2]);
    ax1 = nexttile;
    ax2 = nexttile;

    % Set up mouse click and motion callbacks for dragging the lines
    set(fig, 'WindowButtonDownFcn', @(src, event) startDragFcn(fig));
    set(fig, 'WindowButtonUpFcn', @(src, event) stopDragFcn(fig));


    %% Place interactive control elements
    % Add a confirmation button to finalize the selection
    uicontrol(fig, 'Style', 'pushbutton', 'String', 'Confirm Selection', ...
       'Units', 'normalized', 'Position', [0.4 0.04 0.2 0.06], ...
       'Callback', @(src,even)confirmSelection());

    % Add dropdown to change the viewed dimensions, default is along Z
    uicontrol(fig, 'Style', 'popupmenu', 'String', {'Along X', ...
        'Along Y', 'Along Z'}, 'Units', 'normalized', ...
        'Position', [0.44, 0.46, 0.12, 0.06], 'Value', 3, ... % For Along Z
        'Callback', @(src, event)changeView(src));

    % Add a checkbox to toggle between binary and percentile view
    uicontrol(fig, 'Style', 'checkbox', 'String', ' Contrast', ...
        'Units', 'normalized', 'Position', [0.04 0.04 0.2 0.06], ...
        'Callback', @(src,event)toggleContrast());

    
    %% Plot selection plot with vertical lines
    hold(axSel, "on");
    
    % Plot RMS and MIP fractions above integers from 0 to colorMax - 1
    x = (0:colorMax-1);
    plot(axSel, x, n_RMS, '.-');
    plot(axSel, x, n_MIP, '.-');
    xlabel(axSel, 'X');
    ylabel(axSel, 'Fraction above X');
    legend(axSel, 'RMS', 'MIP');
    title(axSel, 'Fraction of points having a value above X');
    

    % Initial positions of the vertical lines
    lineRMS = line(axSel, [thRMS thRMS], ylim, 'Color', 'b', ...
        'LineWidth', 2, 'DisplayName', 'RMS TH');
    lineMIP = line(axSel, [thMIP thMIP], ylim, 'Color', 'r', ...
        'LineWidth', 2, 'DisplayName', 'MIP TH');

    hold(axSel, "off");

    
    % Draw view images
    refreshImages();

    % Wait for figure to close or the confirm button to be pressed
    uiwait;

    if ishandle(fig)
        thRMS = lineRMS.XData(1);
        thMIP = lineMIP.XData(1);
        delete(fig);
    end

    return;



    %% Nested functions - Threshold selection
    function [threshold, pdf1, pdf2] = detectThreshold_GMM2(data)
        % This function fits two Gaussians to the data by fitting a
        % gaussian mixture model with two components. This is done with the
        % assumption that the data contains noise and actual data, both of
        % which can be described with a Gaussian.
        % The threshold is taken at the crossing point of the two
        % Gaussians. The noise is assumed to be the left Gaussian (smaller
        % intensity than the data)

        % Ensure data is a column vector
        data = data(:);
        
        % Fit Gaussian mixture model with two components to data
        gm = fitgmdist(data, 2);
        
        % Extract parameters of the two Gaussians
        mu1 = double(gm.mu(1));
        sigma1 = sqrt(gm.Sigma(1));
        mu2 = double(gm.mu(2));
        sigma2 = sqrt(gm.Sigma(2));
        
        % Define the PDFs of the two Gaussians as anonymous functions
        pdf1 = @(x) normpdf(x, mu1, sigma1) * gm.ComponentProportion(1);
        pdf2 = @(x) normpdf(x, mu2, sigma2) * gm.ComponentProportion(2);
        
        % Define the difference of the two PDFs (0 at crossing point)
        diff_pdf = @(x) pdf1(x) - pdf2(x);
        
        % Find the crossing point and return it as the threshold
        threshold = round(fzero(diff_pdf, (mu1 + mu2)/2));
    end


    function startDragFcn(fig)
        % This function checks if a line is clicked and starts the dragging
        % function if this is the case

        % Check if the click is close to either line
        cp = get(gca, 'CurrentPoint');
        x_click = cp(1,1);
        
        % Test if RMS line was clicked
        if abs(x_click - lineRMS.XData(1)) < 0.8  % Adjust as needed
            activeLine = lineRMS;
            isDragging = true;

        % Test if MIP line was clicked
        elseif abs(x_click - lineMIP.XData(1)) < 0.8
            activeLine = lineMIP;
            isDragging = true;
        end
        
        if isDragging
            % Activate dragging function if either line is clicked
            set(fig, 'WindowButtonMotionFcn', @(src, event) draggingFcn());
        end
    end


    function draggingFcn()
        % This function updates the line and the images when a line is
        % dragged

        % Test if dragginFcn is correctly called
        if isDragging && ~isempty(activeLine)
            % Get current point and extract x values for redrawing the 
            % active line
            cp = get(gca, 'CurrentPoint');

            % clip data and round to integer
            new_x = max(min(round(cp(1,1)), colorMax-1), 0); 
            
            % Redraw line
            set(activeLine, 'XData', [new_x new_x]);
            drawnow;

            % Redraw MIP or RMS image
            refreshImages();
        end
    end


    function stopDragFcn(fig)
        % This function resets the active line and motion function when
        % the mouse button is let go

        isDragging = false;
        activeLine = [];  
        set(fig, 'WindowButtonMotionFcn', '');
    end


    function confirmSelection()
        % Resume execution
        uiresume;
    end

    %% Nested functions - RMS/MIP image view
    function changeView(src)
        % This function permutes the data to show different views when
        % another view is selected from the dropdown menu.

        % Make sure the function is called from the correct source
        if ~isa(src, 'matlab.ui.control.UIControl')
            return
        end
        if ~strcmp(src.Style, 'popupmenu')
            return
        end
        
        % Get value as a string
        newSelection = src.String{src.Value};
        
        % Change size and permutation depending on selection
        switch newSelection
            case 'Along X'
                permutation = [2,3,1];
                activeSize = size(dataRMS, 1);

            case 'Along Y'
                permutation = [3,1,2];
                activeSize = size(dataRMS, 2);

            case 'Along Z'
                permutation = [1,2,3];
                activeSize = size(dataRMS, 3);

            otherwise
        end

        % Refresh images
        refreshImages();
    end


    function myWindowScrollWheelFcn(src, evnt)
        % Mousewheel callback function to give interactions to bmImage3
        if evnt.VerticalScrollCount > 0    
            % Scrolling towards body -> reducing slice by one
            curImNum = curImNum - 1;

            % Wrap around
            if curImNum < 1
                curImNum = activeSize;
            end
            
        elseif evnt.VerticalScrollCount < 0
            % Scrolling away from body -> increasing slice by one
            curImNum = curImNum + 1;

            % Wrap around
            if curImNum > activeSize
                curImNum = 1;
            end
        end
        
        % Refresh images
        refreshImages();
    end


    function refreshImages()
        % This function refreshes both images (RMS and MIP)

        % Refresh RMS image
        refreshImage(dataRMS, ax1, lineRMS, 'RMS');

        % Refresh MIP image
        refreshImage(dataMIP, ax2, lineMIP, 'MIP');

        function refreshImage(data, ax, line, name)
            % This helper function refreshes a given image

            % Permute data to show correct slice
            data = permute(data, permutation);
            data = data(:, :, curImNum);

            % Get threshold and apply to data to visualize its effect
            th = line.XData(1);
            if useContrast
                data = data > th;
            else
                data(data <= th) = 0;
            end

            % Update image and title
            imagesc(ax, data);
            title(ax, [name, ' [', num2str(curImNum), '/', ...
                num2str(activeSize), ']']);
            axis(ax, 'image');
            colormap(ax, 'gray');
        end

    end


    function toggleContrast()
        % This function is called by the checkbox to update contrast use
        useContrast = ~useContrast;
        refreshImages;
    end

end
