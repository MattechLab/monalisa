function coordinates = selectROI(dataRMS, dataMIP, N_u, varargin)
% coordinates = selectROI(dataRMS, dataMIP, N_u, boxPos)
% 
% This function allows to manually set the bounding box around the region
% of interest (ROI) for every dimension of the image in dataRMS and
% dataMIP. For both data a figure is created (6 images in total). The
% bounding boxes update automatically to always use the same coordinates in
% all images. The code is interrupted until the selection is confirmed or
% the window is closed.
%
% Authors:
%   Dominik Helbing
%   MattechLab 2024
%
% Parameters:
%   dataRMS (array): Data for RMS image. Has to be data of a 3D image.
%   dataMIP (array): Data for MIP image. Has to be data of a 3D image.
%   N_u (list): Contains the size of the data in every dimension.
%   varargin{1}: Array that contains the guessed position of the bounding
%    box. Has to have the structure [xMin, xWidth; yMin, yWidth; zMin,
%    zWidth]. Default value is [2, 2, min(N_u)-2, min(N_u)-2]
%
% Returns:
%   coordinates (array): The updated coordinates of the bounding box
%    including the same ROI for dataRMS and dataMIP. Has the structure
%    [xMin, xMax; yMin, yMax; zMin, zMax]

    %% Initialize arguments
    % Extract optional arguments
    boxPos = bmVarargin(varargin);

    % Ensure correct size
    N_u = N_u(:)';
    dataRMS = bmBlockReshape(dataRMS, N_u);
    dataMIP = bmBlockReshape(dataMIP, N_u);

    % Set default value if position is not given
    if isempty(boxPos)
        boxPos = [2, 2, min(N_u)-2, min(N_u)-2];
    end
    
    % Sum over every dimension and normalize
    zRMS = sum(dataRMS, 3);
    zRMS = (zRMS - min(zRMS, [], "all")) / ...
           (max(zRMS, [], "all") - min(zRMS, [], "all"));
    
    yRMS = permute(dataRMS, [3, 1, 2]);
    yRMS = sum(yRMS, 3);
    yRMS = (yRMS - min(yRMS, [], "all")) / ...
           (max(yRMS, [], "all") - min(yRMS, [], "all"));
    
    xRMS = permute(dataRMS, [2, 3, 1]);
    xRMS = sum(xRMS, 3);
    xRMS = (xRMS - min(xRMS, [], "all")) / ...
           (max(xRMS, [], "all") - min(xRMS, [], "all"));
    
    % Repeat for MIP
    zMIP = sum(dataMIP, 3);
    zMIP = (zMIP - min(zMIP, [], "all")) / ...
           (max(zMIP, [], "all") - min(zMIP, [], "all"));
    
    yMIP = permute(dataMIP, [3, 1, 2]);
    yMIP = sum(yMIP, 3);
    yMIP = (yMIP - min(yMIP, [], "all")) / ...
           (max(yMIP, [], "all") - min(yMIP, [], "all"));
    
    xMIP = permute(dataMIP, [2, 3, 1]);
    xMIP = sum(xMIP, 3);
    xMIP = (xMIP - min(xMIP, [], "all")) / ...
           (max(xMIP, [], "all") - min(xMIP, [], "all"));
    
    
    %% Prepare figure
    % Create 2 figures, 3 plot wide
    figMIP = figure('Name', 'MIP', 'Position', [100, 100, 1000, 400]);
    figRMS = figure('Name', 'RMS', 'Position', [100, 150, 1000, 400]);
    
    % Set image as grayscale
    colormap(figMIP, "gray");
    colormap(figRMS, "gray");
    
    % Have a tile layout of 1 row and 3 columns, a bit smaller and higher 
    % to make space for the confirm button
    tRMS = tiledlayout(figRMS, 1, 3);
    tMIP = tiledlayout(figMIP, 1, 3);
    set(tRMS, 'Position', [0.1, 0.15, 0.8, 0.8]);
    set(tMIP, 'Position', [0.1, 0.15, 0.8, 0.8]);
    
    % Put overall title for both figures
    title(tRMS, "RMS Values Summed Along Each Axis");
    title(tMIP, "MIP Values Summed Along Each Axis");
    
    % Add a confirmation button
    bRMS = uicontrol(figRMS ,'Style', 'pushbutton', ...
        'String', 'Confirm Selection', ...
        'Units', 'normalized', 'Position', [0.4 0.04 0.2 0.06], ...
        'Callback', @(src, event) confirmSelection(figRMS, tRMS, tMIP));
    
    bMIP = uicontrol(figMIP ,'Style', 'pushbutton', ...
        'String', 'Confirm Selection', ...
        'Units', 'normalized', 'Position', [0.4 0.04 0.2 0.06], ...
        'Callback', @(src, event) confirmSelection(figRMS, tRMS, tMIP));
    
    cbxR = uicontrol(figRMS, 'Style', 'checkbox', ...
        'String', ' Update on move', ...
        'Units', 'normalized', 'Position', [0.04 0.04 0.2 0.06]);
    
    cbxM = uicontrol(figMIP, 'Style', 'checkbox', ...
        'String', ' Update on move', ...
        'Units', 'normalized', 'Position', [0.04 0.04 0.2 0.06]);
    
    
    %% Plot data
    % Plot YZ view for RMS
    axRMSx = nexttile(tRMS);
    imagesc(xRMS);
    axis image;
    xlabel('Z');
    ylabel('Y');
    title('Along X');
    
    % Create movable rectangle on image
    nPos = [boxPos(3,1), boxPos(2,1), boxPos(3,2), boxPos(2,2)];
    xRectR = images.roi.Rectangle(axRMSx,'Position', nPos);
    
    % Plot YZ view for MIP
    axMIPx = nexttile(tMIP);
    imagesc(xMIP);
    axis image;
    xlabel('Z');
    ylabel('Y');
    title('Along X');

    % Create movable rectangle on image
    xRectM = images.roi.Rectangle(axMIPx,'Position', nPos);
    
    % Plot XZ view for RMS
    axRMSy = nexttile(tRMS);
    imagesc(yRMS);
    axis image;
    xlabel('X')
    ylabel('Z')
    title('Along Y');

    % Create movable rectangle on image
    nPos = [boxPos(1,1), boxPos(3,1), boxPos(1,2), boxPos(3,2)];
    yRectR = images.roi.Rectangle(axRMSy,'Position', nPos);
    
    % Plot XZ view for MIP
    axMIPy = nexttile(tMIP);
    imagesc(yMIP);
    axis image;
    xlabel('X')
    ylabel('Z')
    title('Along Y');

    % Create movable rectangle on image
    yRectM = images.roi.Rectangle(axMIPy,'Position', nPos);
    
    % Plot XY view for RMS
    axRMSz = nexttile(tRMS);
    imagesc(zRMS);
    axis image;
    xlabel('Y');
    ylabel('X');
    title('Along Z');

    % Create movable rectangle on image
    nPos = [boxPos(2,1), boxPos(1,1), boxPos(2,2), boxPos(1,2)];
    zRectR = images.roi.Rectangle(axRMSz,'Position', nPos);
    
    % Plot XY view for MIP
    axMIPz = nexttile(tMIP);
    imagesc(zMIP);
    axis image;
    xlabel('Y');
    ylabel('X');
    title('Along Z');

    % Create movable rectangle on image
    zRectM = images.roi.Rectangle(axMIPz,'Position', nPos);
    

    %% Add listeners to rectangles 
    % Listeners update boxes after changing them in the image and letting
    % go
    el1 = addlistener(xRectR, "ROIMoved", @(src, evnt)updateBorder(src, ...
        xRectR, yRectR, zRectR, xRectM, yRectM, zRectM));
    el2 = addlistener(yRectR, "ROIMoved", @(src, evnt)updateBorder(src, ...
        xRectR, yRectR, zRectR, xRectM, yRectM, zRectM));
    el3 = addlistener(zRectR, "ROIMoved", @(src, evnt)updateBorder(src, ...
        xRectR, yRectR, zRectR, xRectM, yRectM, zRectM));
    el4 = addlistener(xRectM, "ROIMoved", @(src, evnt)updateBorder(src, ...
        xRectR, yRectR, zRectR, xRectM, yRectM, zRectM));
    el5 = addlistener(yRectM, "ROIMoved", @(src, evnt)updateBorder(src, ...
        xRectR, yRectR, zRectR, xRectM, yRectM, zRectM));
    el6 = addlistener(zRectR, "ROIMoved", @(src, evnt)updateBorder(src, ...
        xRectR, yRectM, zRectR, xRectM, yRectM, zRectM));
    
    % Combine listeners into array for easier access
    listeners = [el1, el2, el3, el4, el5, el6];
    
    % Callback function for checkboxes to change the listeners between
    % updating the boxes on dragging or after changing
    cbxR.Callback = @(src,evnt)updateListeners(src, cbxR, cbxM, listeners);
    cbxM.Callback = @(src,evnt)updateListeners(src, cbxR, cbxM, listeners);
    
    % Turn position into coordinates
    coordinates = [boxPos(1,1), boxPos(1,1) + boxPos(1,2);
                   boxPos(2,1), boxPos(2,1) + boxPos(2,2);
                   boxPos(3,1), boxPos(3,1) + boxPos(3,2)];

    % Interupt code execution until Confirm is pressed or the RMS figure
    % closed
    uiwait(figRMS);

    % Update with new values if figures were not closed
    if ishandle(figRMS) && ishandle(figMIP)
        coordinates = borderExtraction(xRectR, yRectR, zRectR, xRectM, ...
            yRectM, zRectM);

    else
        disp("Use confirm to use the new values. " + ...
             "Don't close the figures!");
    end

    % End function
    return


    %% Nested functions
    function coordinates = borderExtraction(xRectR, yRectR, zRectR, ...
            xRectM, yRectM, zRectM)
        % This function extracts the border values, makes the rectangles 
        % non interactive and returns the border values as a [3,2] array
    
        % Extract borders
        yMin = xRectR.Vertices(1,2);
        yMax = xRectR.Vertices(3,2);
        zMin = xRectR.Vertices(1,1);
        zMax = xRectR.Vertices(3,1);
        xMin = yRectR.Vertices(1,1);
        xMax = yRectR.Vertices(3,1);
        
        
        % Scale from [0.5, 48.5] to [1, 48] and round
        xMin = round(1 + ((xMin - 0.5) / 48) * 47);
        xMax = round(1 + ((xMax - 0.5) / 48) * 47);
        yMin = round(1 + ((yMin - 0.5) / 48) * 47);
        yMax = round(1 + ((yMax - 0.5) / 48) * 47);
        zMin = round(1 + ((zMin - 0.5) / 48) * 47);
        zMax = round(1 + ((zMax - 0.5) / 48) * 47);
    
        % Make squares non interactive
        xRectR.InteractionsAllowed = 'none';
        yRectR.InteractionsAllowed = 'none';
        zRectR.InteractionsAllowed = 'none';
        xRectM.InteractionsAllowed = 'none';
        yRectM.InteractionsAllowed = 'none';
        zRectM.InteractionsAllowed = 'none';
    
        coordinates = [xMin, xMax; yMin, yMax; zMin, zMax];
    end


    function confirmSelection(fig, t1, t2)
        % This function resumes the code execution
        if ishandle(fig)
            % Show in title that the code execution continues
            title(t1, 'Confirmed');
            title(t2, 'Confirmed');
            
            % Resume execution
            uiresume(fig);
        end
    end


    function updateBorder(src, xRectR, yRectR, zRectR, xRectM, yRectM, ...
            zRectM)
        % This function updates all squares if one is modified
    
        % Ensure the source of the event is actually a rectangle
        if ~isa(src,'images.roi.Rectangle')
            return
        end
        
        % Read positions all squares (xRectR = xRectM sizewise)
        posX = xRectR.Position;
        posY = yRectR.Position;
        posZ = zRectR.Position;
        
        % Read position of updated square
        pos = src.Position;
    
        switch src
            case {xRectR, xRectM}
                % Update position lists with the new values
                posX = pos;
                posY = [posY(1), pos(1), posY(3), pos(3)];
                posZ = [pos(2), posZ(2), pos(4), posZ(4)];
    
            case {yRectR, yRectM}
                % Update position lists with the new values
                posX = [pos(2), posX(2), pos(4), posX(4)];
                posY = pos;
                posZ = [posZ(1), pos(1), posZ(3), pos(3)];
    
            case {zRectR, zRectM}
                % Update position lists with the new values
                posX = [posX(1), pos(1), posX(3), pos(3)];
                posY = [pos(2), posY(2), pos(4), posY(4)];
                posZ = pos;
    
            otherwise
        end
    
        % Override positions of all squares (M and R have the same
        % squares)
        xRectR.Position = posX;
        yRectR.Position = posY;
        zRectR.Position = posZ;
    
        xRectM.Position = posX;
        yRectM.Position = posY;
        zRectM.Position = posZ;
    
    end


    function updateListeners(src, cbxR, cbxM, listeners)
        % This function changes the listener event between MovingROI and
        % ROIMoved depending on the checkbox

        % Change checkbox value of the one in the figure not clicked on
        if strcmp(src.Parent.Name, 'RMS')
            cbxM.Value = src.Value;

        elseif strcmp(src.Parent.Name, 'MIP')
            cbxR.Value = src.Value;

        else
            return
        end
        
        % Choose event depending on the checkbox value
        if src.Value == 1
            eventName = 'MovingROI';
        else
            eventName = 'ROIMoved';
        end
        
        % Update all listeners to listen to the new event
        for i=1:size(listeners(:), 1)
            listeners(i).EventName = eventName;
        end
    end


end

