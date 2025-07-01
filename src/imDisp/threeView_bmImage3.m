function varargout = threeView_bmImage3(argImagesTable, varargin)
% Trying to construct a 3 view visualizer.
% This function is an attempt to enhance the bmImage3 visualization for 3D
% data. It is the beginning, then it should be integrated in bmImage4,5
% This 3D visualizer is slightly challenging and therefore we highlight
% here the differences betwen bmImage3, as well as the assumptinos made
% We should never edit the data when displaying it, to avoid conflicts with
% the permute functions. This prevents the key combinations shift + axis to
% break.
% The idea is to display the 3 differen views and to allow the user to move
% a point by dragging it and update the plots, similarly to what is done in
% popular software like spm, ... . To achieve this additional fields are 
% used in the bmImageViewerParam object. Specifically we added:
%% obj.bluePoint 
% which is a 3D point that has the display coordinate of the
% 3 displayed slices [curImNumX, curImNumY, curImNumZ]; % 3 views 
%% bluePointHandles = gobjects(3, 1); % preallocate handles (1 per view)
%% obj.blueLineHandles = gobjects(3, 2);  % 3 views, 2 lines per view
% We should not compute much when dragging the blue point, to prevent
% freezing in the UI. Therefore refresh_image is not called in the dragging
% callback, instead, we only update the bluepoint coordinates. A second
% callback is responsible for refreshing the image at the end of the
% dragging of the blue point.
%
% For some reason the coordinate system of the array is different from the 
% one of the bluepoint. This is why we need to transpose the slices before 
% displaying them.

%% Initialize arguments
% Extract optional arguments
[argParam, uiwait_flag] = bmVarargin(varargin); 

% Use default values for image viewer parameters if empty
% Create bmImageViewerParam object
if isempty(argParam) 
    myParam = bmImageViewerParam(3, argImagesTable); 
else
    myParam = bmImageViewerParam(argParam);
end

% Turn logical into single for compatibility
if isa(argImagesTable, 'logical') 
    argImagesTable = single(argImagesTable);
end

% The four following variables are the dynamic variales that are updated at
% each change of view_angle
myImagesTable       = argImagesTable;
point_list          = myParam.point_list; 
imSize              = myParam.imSize; 
axis_3              = myParam.rotation(:, 3); % Normal axis (perpenticular to image)

controlFlag         = false;
shiftFlag           = false;
escFlag             = false;

%% Create figure and display image
% Create figure and set callback functions to define interactions
myFigure = figure(  'Name', 'bmImage3', ...
                    'keyreleasefcn', @myKeyReleaseFcn,...
                    'keypressfcn', @myKeyPressFcn,...
                    'WindowButtonDownFcn', @myClickCallback); 

colormap gray

% Display image
update_image;
refresh_image;

% Code execution waits for resume if flag is true
if uiwait_flag
    uiwait;
end

% Return bmImageViewerParam object used in this figure if required
if nargout > 0 
    varargout{1} = myParam;
end
return;

%% Nested functions

    function myClickCallback(~, ~)
        switch get(gcf,'selectiontype')
            case 'normal'
                % Left mouse button click
                % Display value of pixel clicked on in the title
                show_imVal_in_title;
                % refresh_image;
            case 'alt'
                % Right mouse button click or Ctrl + LMB click
                if controlFlag
                    % Set one of three control points
                    set_control_point;
                    controlFlag = 0;
                else
                    set_point;
                    controlFlag = 0;
                end
            case 'extend'
                % Shift + LMB/RMB click or middle mouse button click
                % Delete the latest point placed
                delete_point;         
        end
    end

    
    function myKeyPressFcn(~,command)
        % Keypress callback function to give interactions to bmImage3
        % Switch through the type of key that has been pressed and chose
        % the action to perform
        switch lower(command.Key)
            case 'downarrow'
                % Show next lower slice of the third dimension
                myParam.curImNum = myParam.curImNum - 1;
                if myParam.curImNum < 1
                    myParam.curImNum = myParam.numOfImages;
                end
                refresh_image;
                
            case 'uparrow'
                % Show next higher slice of the third dimension
                myParam.curImNum = myParam.curImNum + 1;
                if myParam.curImNum > myParam.numOfImages
                    myParam.curImNum = 1;
                end
                refresh_image;
                
            case 'control'     % Ctrl key is pressed
                controlFlag = 1;
            case 'shift'       % Shift key is pressed
                shiftFlag   = 1;
            case 'escape'      % Escape key is pressed
                escFlag     = 1;
            case 'n'
                if controlFlag 
                    % Ctrl + n  go to images number X
                    maxNumber = num2str(myParam.numOfImages);
                    prompt = ['Enter slice number [1, ', maxNumber, '] :'];
                    myParam.curImNum = private_ind_box(bmGetNat(prompt), ...
                                                    myParam.numOfImages);
                    controlFlag = 0;
                    refresh_image;
                end
                
            case 'e'
                % Change color limits / contrast of image
                if (controlFlag && shiftFlag)
                    % Change color limits through user input
                    prompt = 'Enter color limits as [low, high]:';
                    myParam.colorLimits = bmCol(bmGetNum(prompt))';
                    refresh_image;
                    controlFlag = 0;
                    shiftFlag = 0;  

                elseif controlFlag
                    % Create an Adjust Contrast Tool
                    imcontrast(myFigure);    % DO NOT REFRESH image after this command
                    controlFlag = 0;

                elseif shiftFlag  
                    % Apply image colorlimit to bmImageViewerParam object
                    % Useful for when the color limits where changed with
                    % the Adjust Contrast Tool
                    myParam.colorLimits=get(gca,'CLim'); 
                    refresh_image;
                    shiftFlag = 0;

                elseif escFlag   
                    % Reset color limits
                    myParam.colorLimits = myParam.colorLimits_0;
                    refresh_image;
                    escFlag = 0;
                end
                
            case 'm'
                if controlFlag && shiftFlag
                    % Mirror image horizontally
                    myParam.mirror_flag = not(myParam.mirror_flag);
                    refresh_image;
                    controlFlag = 0;
                    shiftFlag = 0;
                end

            case 'r'
                if controlFlag && shiftFlag
                    % Mirror image vertically
                    myParam.reverse_flag = not(myParam.reverse_flag);
                    refresh_image;
                    controlFlag = 0;
                    shiftFlag = 0;
                end

            case 't'
                if controlFlag && shiftFlag
                    % Transpose image (swap first two dimensions)
                    myParam.transpose_flag = not(myParam.transpose_flag);
                    update_image;
                    refresh_image;
                    controlFlag = 0;
                    shiftFlag = 0;
                end
                
            case '3'
                if (controlFlag && shiftFlag)
                    % Change view to show slice depening on the control
                    % points (A, B, C)
                    set_viewPlane;
                    controlFlag     = 0;
                    shiftFlag       = 0;
                end
                
            case 'a'
                % Rotate image
                if controlFlag && shiftFlag
                    % Rotate by Euler angles given as input
                    set_psi_theta_phi;
                elseif controlFlag
                    % Visually rotate plane with arrow keys
                    set_inPlane_angle; 
                end
                controlFlag = 0; 
                shiftFlag   = 0;
                
            case 'x'
                if controlFlag && shiftFlag
                    % Permute data to have x as third dimension
                    myParam.permutation = [2, 3, 1];
                    update_image;
                    refresh_image;             
                end
                controlFlag = 0;
                shiftFlag   = 0;
                
            case 'y'
                if controlFlag && shiftFlag
                    % Permute data to have y as third dimension
                    myParam.permutation = [3, 1, 2];
                    update_image;
                    refresh_image;
                end
                controlFlag = 0;
                shiftFlag = 0;

            case 'z'
                if controlFlag && shiftFlag
                    % Permute data to have z as third dimension
                    myParam.permutation = [1, 2, 3];
                    update_image;
                    refresh_image;
                end
                controlFlag = 0;
                shiftFlag = 0;

            case 'h'
                % Print explanation for all interactions
                print_help;
            
        end % End Switch command.key
    end

    function myKeyReleaseFcn(~,command)
        % Reset flags if keys are released
        switch lower(command.Key)
            case 'control'     % Ctrl key is released
                controlFlag = 0;
            case 'shift'       % Shift key is released
                shiftFlag   = 0;
            case 'escape'      % Escape key is released
                escFlag     = 0;
        end
    end

    function myPoint = hard_coord(myPoint)
        % Get coordinates of original grid (position in the image not in
        % the grid displayed now -> taking into consideration rotation and
        % permutations)

        % Column vector
        myPoint = myPoint(:); 
        
        % Split coordinates
        myX = myPoint(1, 1); 
        myY = myPoint(2, 1); 
        myZ = myPoint(3, 1); 
        
        % Swap first two coordinates if the image is transposed
        if myParam.transpose_flag 
            temp     = myX;
            myX      = myY;
            myY      = temp;
        end
        
        % Adapt coordinates to match permutation
        if isequal(myParam.permutation, [1, 2, 3]) 
            perm_x = myX;
            perm_y = myY;
            perm_z = myZ;
        elseif isequal(myParam.permutation, [3, 1, 2])
            perm_x = myY;
            perm_y = myZ;
            perm_z = myX;
        elseif isequal(myParam.permutation, [2, 3, 1])
            perm_x = myZ;
            perm_y = myX;
            perm_z = myY;
        end
        
        % Return to column vector format
        myPoint     = [perm_x, perm_y, perm_z]'; 
        
        % Rotate point to match rotated grid
        myShift     = imSize(:)./2 + 1;
        myPoint     = myShift + (   myParam.rotation*(myPoint - myShift)  ); 
    end


    function myPoint = soft_coord(myPoint)
        % Returns coordinates after rotation and transposition of a point 
        % given its coordinates in the original data structure (without 
        % rotation and transposition). This is used for control points as
        % their coordinates are not changed in update_image() (unlike the
        % point_list)

        % Column vector
        myPoint     = myPoint(:); 

        % Inverse rotation to get correct coordinates in rotated grid
        myShift     = myParam.imSize(:)./2 + 1;       
        myPoint     = myShift + (   myParam.rotation\(myPoint - myShift)  );
        
        myX = myPoint(1, 1); 
        myY = myPoint(2, 1); 
        myZ = myPoint(3, 1); 

        % Swap around coordinates depending on permutation
        if isequal(myParam.permutation, [1, 2, 3])
            perm_x = myX;
            perm_y = myY;
            perm_z = myZ;
        elseif isequal(myParam.permutation, [3, 1, 2])
            perm_x = myZ;
            perm_y = myX;
            perm_z = myY;
        elseif isequal(myParam.permutation, [2, 3, 1])
            perm_x = myY;
            perm_y = myZ;
            perm_z = myX;
        end

        % Swap coordinates of first and second dimension if transposed
        if myParam.transpose_flag
            temp     = perm_x;
            perm_x   = perm_y;
            perm_y   = temp;
        end

        % Returned updated coordinates as column vector
        myPoint = [perm_x, perm_y, perm_z]'; 
        
    end


    function p = get_soft_point_from_click()
        % Read out coordinates of mouse location. Either the exact
        % coordinates for points or the indices of the pixel in the data

        % Get coordinates of the mouse location
        myCoordinates = get(gca,'CurrentPoint');

        % normal = left, alt = Ctrl + left or right
        if strcmp(  get(gcf,'selectiontype'), 'normal'  )
            % Extract first two coordinates and round to the next integer
            % This gives the indices for the data array
            myCoordinates = ceil(myCoordinates(1,1:2)-[0.5 0.5]); 

        elseif strcmp(  get(gcf,'selectiontype'), 'alt'  )
            % Extract first two coordinates
            myCoordinates = myCoordinates(1,1:2);
        end

        % Clip coordinates to valid values
        myX = max(1, myCoordinates(2) );
        myX = min(  imSize(1, 1), myX);
        myY = max(1, myCoordinates(1) );
        myY = min(  imSize(1 ,2),  myY);
        myZ = myParam.curImNum;

        % Return coordinates as column vector
        p = [myX, myY, myZ]';
        
    end

    function show_imVal_in_title(~)
        % Show the 3d Coordinate of the clicked point on any of the 2D 
        % subplots. This is not easy, since you need to take into account:
        % Which of the 2D subplots was clicked? The axis are different
        % What is the current permutation? The axis are different
        % Extract the 3rd coordinate that is not described by the click (using the blue point)
        % One exception is that if the blue point wasn't created yet, that
        % needs carefull consideration. Probably the best would be to
        % initialize the blue point when the figure is generated at the
        % center.

        % Determine which subplot was clicked
        axes1 = ancestor(myParam.bluePointHandles(1), 'axes');
        axes2 = ancestor(myParam.bluePointHandles(2), 'axes');
        axes3 = ancestor(myParam.bluePointHandles(3), 'axes');
        clickedAxes = ancestor(gco, 'axes');
    
        % Get the clicked point in axes coordinates
        cp = get(clickedAxes, 'CurrentPoint');
        disp('Here')
        disp(cp)
        clickX = cp(1,1);
        clickY = cp(1,2);
    
        % Determine which view was clicked (1, 2 or 3)
        if isequal(clickedAxes, axes1)
            viewIdx = 1;
        elseif isequal(clickedAxes, axes2)
            viewIdx = 2;
        elseif isequal(clickedAxes, axes3)
            viewIdx = 3;
        else
            disp('Clicked outside known subplots');
            return;
        end
    
        % Build the soft_point (continuous 3D coordinate)
        % using your corrected mapping:
        % - view 1 shows (X,Z), fixes Y from bluePoint(2)
        % - view 2 shows (Z,Y), fixes X from bluePoint(1)
        % - view 3 shows (X,Y), fixes Z from bluePoint(3)
        soft_point = zeros(3,1);
        switch viewIdx
            case 1
                soft_point(1) = clickX;               % X from X on image
                soft_point(2) = myParam.bluePoint(2); % Y fixed
                soft_point(3) = clickY;               % Z from Y on image
            case 2
                soft_point(1) = myParam.bluePoint(1); % X fixed
                soft_point(2) = clickX;               % Y from Y on image
                soft_point(3) = clickY;               % Z from X on image
            case 3
                soft_point(1) = clickX;               % X from X on image
                soft_point(2) = clickY;               % Y from Y on image
                soft_point(3) = myParam.bluePoint(3); % Z fixed
        end
    
        % Now handle permutation
        switch num2str(myParam.permutation)
            case num2str([1, 2, 3])
                final_coord = soft_point;
            case num2str([3, 1, 2])
                final_coord = soft_point([3,1,2]);
            case num2str([2, 3, 1])
                final_coord = soft_point([2,3,1]);
            otherwise
                error('Unknown permutation');
        end
    
        % Clamp to data size
        idx = max(1, min(imSize, round(final_coord)));
    
        % Update the title of the clicked subplot
        title(clickedAxes, ...
            ['(' num2str(idx(1)) ';' num2str(idx(2)) ';' num2str(idx(3)) ') : ' ...
             num2str(myImagesTable(idx(1), idx(2), idx(3))) ]);
    end

    
    %% Dragging event code for updating 3 views viewer
    
    function update_dragged_point(src, evt, viewIndex)
        %% Callback when moving => update the position of the blue point
        % Nb do not add slow stuff in this callback otherwise function
        % becomes lagging
        % Same assuption as the display:
        % (verticalDisplay2D, horizontalDisplay2D)
        % Slice i=1: (Y,Z) => Blue point slice (blupoint(1),:,:)
        % Slice i=2: (Y,X) => Blue point slice (:,blupoint(2),:) 
        % Slice i=3: (X,Z) => Blue point slice (:,:,blupoint(3)) 
        % There seems to be a missmatch here!!!

        % pos2d coordinates are: horizontal, vertical
        pos2D = src.Position;
        %disp(num2str(pos2D(1)))
        %disp(num2str(pos2D(2)))
        % Update only 2 axes based on view
        switch viewIndex
            case 1
                myParam.bluePoint([1,3]) = pos2D;
            case 2
                myParam.bluePoint([2,3]) = pos2D;
            case 3
                myParam.bluePoint([1,2]) = pos2D;
        end
    
    end

    function finalize_drag(viewIndex)
        %% Callback when finished dragging => update images
        drawnow;  % allow UI to settle before redrawing
        refresh_image;
    end

    %% End dragging event code
    
    function set_point
        % Place points. They are stored in the bmImageViewerParam object
        % with coordinates for the original grid (hard coordinates) and in
        % the function variable point_point list with coordinates for the
        % modified grid (soft coordinates)

        % Get soft coordinates
        soft_point          = get_soft_point_from_click;

        % Transform the soft coordinates into hard coordinates
        hard_point          = hard_coord(soft_point);

        % Store the coordinates for the original grid in the 
        % bmImageViewerParam object
        myParam.point_list  = cat(2, myParam.point_list, hard_point);

        % Store the coordinates for the modified grid in the point_list
        point_list          = [point_list, soft_point];

        % Display changes
        refresh_image;
    end

    function delete_point
        % Delets the last placed point (not control point)

        % Remove last entry in point_list (and param) if it exists
        if ~isempty(myParam.point_list) && ~isempty(point_list) 
            myParam.point_list(:, end)  = [];
            point_list(:, end)          = [];
        end

        % Display changes
        refresh_image;
    end

    function set_control_point
        % Place control points. They are always given in coordinates in the 
        % original grid.

        % Get coordinates in image (hard coordinates). This is done by
        % getting the coordinates in the shown grid and applying rotation
        % and permutations to have the coordinates of the place in the
        % original grid.
        soft_point    = get_soft_point_from_click;
        hard_point    = hard_coord(soft_point);
        
        % Ask user which control point should be placed
        myAnswer = questdlg('Choose point : ', ...
                            'Choose point : ', 'A', 'B', 'C', 'A');
        
        % No answer when pop up is closed
        if strcmp(myAnswer, 'NO') || isempty(myAnswer)
            return;
        end
        
        % Asign the coordinates to the chosen point
        if myAnswer == 'A'
            myParam.point_A = hard_point;
        elseif myAnswer == 'B'
            myParam.point_B = hard_point;
        elseif myAnswer == 'C'
            myParam.point_C = hard_point;
        end

        % Display the changes
        refresh_image;
        
    end


    function update_image()
        % Apply rotations, permutations and transposing from starting point
        % These changes modify how the data is stored (myImagesTable)
        reset_image;
        rotate_image;
        permute_image;
        transpose_image;        
    end


    function reset_image()
        % Reset 'global' image variables to match bmImageViewerParam and 
        % input data. Variables given for [1, 2, 3] permutation
        myImagesTable   = argImagesTable; % Data
        point_list      = myParam.point_list; % Points
        imSize          = myParam.imSize;     % Size
        axis_3          = myParam.rotation(:, 3); % Normal axis
    end

    function rotate_image()
        % Rotate image data (myImagesTable) to match applied rotation.

        % The Euler-angles must first be defined in order to apply this
        % function. The image and the points are rotated according to the
        % pre-defined Euler-angles. The rotation myParam.rotation must also
        % be correctly prepared according to the Euler-angles. 

        % Skip if no rotation
        if (myParam.psi == 0)&&(myParam.theta == 0)&&(myParam.phi == 0)
            return;
        end

        % Read rotation matrix 
        myShift = imSize(:)/2+1; 
        R = myParam.rotation; 

        % Create grid for all coordinates
        [temp_X, temp_Y, temp_Z] = ndgrid(  1:imSize(1, 1), ...
                                            1:imSize(1, 2), ...
                                            1:imSize(1, 3));

        % Shift grid so 0 is in the center
        temp_X      = temp_X - myShift(1, 1);
        temp_Y      = temp_Y - myShift(2, 1);
        temp_Z      = temp_Z - myShift(3, 1);

        % Multiply coordinates with rotation matrix for new coordinates
        new_grid    = R*cat(1, temp_X(:)', temp_Y(:)', temp_Z(:)'); 

        % Seperate coordinates into X, Y and Z row vectors
        new_X       = new_grid(1, :); 
        new_Y       = new_grid(2, :);
        new_Z       = new_grid(3, :);
        
        % Update image data with rotation applied 
        % Interpolate from sample grid to new grid
        myImagesTable = interpn(temp_X, temp_Y, temp_Z, myImagesTable, new_X, new_Y, new_Z); 

        % Reshape to orignal grid size [x,y,z]
        myImagesTable = reshape(myImagesTable, imSize); 

        % Replace NaNs with 0
        myImagesTable(isnan(myImagesTable)) = 0;
        
        % Change coordinates of point list to match applied rotation
        if ~isempty(point_list)
            % Shift points such that the origin (0,0,0) is in the center
            point_list = point_list - repmat(  myShift, [1, size(point_list, 2 )]  ); 

            % Reverse rotation (needed for the points to be at the correct place)
            point_list = R\point_list; 

            % Shift the points back
            point_list = point_list + repmat(  myShift, [1, size(point_list, 2 )]  ); 
        end
        
        % Update normal axis
        axis_3 = myParam.rotation(:, 3); 
        
        % imSize is not updated. It is a choice to do so. 
        
    end

    function permute_image()
        % Permute data to have correct third dimension. Is called after
        % reseting data, size, points and normal axis that of permutation 
        % [1, 2, 3].

        % Z as third dimension
        if isequal(myParam.permutation, [1, 2, 3]) 
            % No permutation needed. Called after reseting data to this 
            % permutation anyways
            myParam.numOfImages = imSize(1, 3);

            % Clip slice to valid number
            myParam.curImNum = max([myParam.curImNum, 1]);
            myParam.curImNum = min([myParam.curImNum, myParam.numOfImages]);
           
        % Y as third dimension
        elseif isequal(myParam.permutation, [3, 1, 2]) 
            % Update size to match permutation
            imSize = [  imSize(1, 3), ...
                        imSize(1, 1), ...
                        imSize(1, 2)];
                            
            myParam.numOfImages = imSize(1, 3);

            % Permute data
            myImagesTable = permute(myImagesTable, myParam.permutation);

            % Clip slice to valid number
            myParam.curImNum = max([myParam.curImNum, 1]);
            myParam.curImNum = min([myParam.curImNum, myParam.numOfImages]);

            % Permute coordinates of points
            if ~isempty(myParam.point_list)
                temp_point_list = point_list(3, :);
                point_list(3, :) = point_list(2, :);
                point_list(2, :) = point_list(1, :);
                point_list(1, :) = temp_point_list;
            end

            % Update normal axis
            axis_3 = myParam.rotation(:, 2); 
        
        % X as third dimension
        elseif isequal(myParam.permutation, [2, 3, 1]) 
            % Update size to match permutation
            imSize = [  imSize(1, 2), ...
                        imSize(1, 3), ...
                        imSize(1, 1)];
            
            myParam.numOfImages = imSize(1, 3);

            % Permute data
            myImagesTable = permute(myImagesTable, myParam.permutation);

            % Clip slice to valid number
            myParam.curImNum = max([myParam.curImNum, 1]);
            myParam.curImNum = min([myParam.curImNum, myParam.numOfImages]);

            % Permute coordinates of points
            if ~isempty(myParam.point_list)
                temp_point_list  = point_list(1, :);
                point_list(1, :) = point_list(2, :);
                point_list(2, :) = point_list(3, :);
                point_list(3, :) = temp_point_list;
            end

            % Update normal axis
            axis_3 = myParam.rotation(:, 1); 
            
        end
    end

    function transpose_image()
        % Transpose image by swapping (permutate) the first two dimensions.

        if myParam.transpose_flag
            % Swap first to dimensions (transpose shown dimensions)
            imSize = [  imSize(1, 2), ...
                        imSize(1, 1), ...
                        imSize(1, 3)];
            
            myImagesTable = permute(myImagesTable, [2, 1, 3]);

            % Change first two coordinates of points to match transposing
            if ~isempty(point_list)
                temp_point_list  = point_list(1, :);
                point_list(1, :) = point_list(2, :);
                point_list(2, :) = temp_point_list;
            end

            % Invert normal axis
            axis_3 = -axis_3; 
            
        end
    end

    function refresh_image()
        % Show the same image slice in 3 subplots with correct axis labels
        % based on permutation and transpose
    
        % Define subplot layout positions (SPM-style)
        subplot_positions = [1, 2, 3];  % top-left, top-right, bottom-left
       
        % Determine axis labels based on permutation
        switch num2str(myParam.permutation)
            case num2str([1, 2, 3])
                axesLabels = {'X', 'Y', 'Z'};
            case num2str([3, 1, 2])
                axesLabels = {'Z', 'X', 'Y'};
            case num2str([2, 3, 1])
                axesLabels = {'Y', 'Z', 'X'};
            otherwise
                error('Unknown permutation');
        end

        % Only set position the first time
        if ~isappdata(myFigure, 'initialized')
            % Display figure and clear it
            figure(myFigure);
            screenSize = get(0, 'ScreenSize');
            figWidth  = round(screenSize(3) * 0.8);
            figHeight = round(screenSize(4) * 0.8);
            left   = round((screenSize(3) - figHeight) / 2);
            bottom = round((screenSize(4) - figHeight) / 2);
            set(myFigure, 'Position', [left, bottom, figHeight, figHeight]);
            setappdata(myFigure, 'initialized', true);
        end
    
        clf;


        % Loop over the three subplots for each subplot we are 
        % Updating the figure based on the current values of blue point.
        % We need clear statements of which axes are present in each slice
        % The image is stored in an array named here myImagesTable where my
        % assumtion is that the coordinates are in order  X, Y, Z
        % (verticalDisplay2D, horizontalDisplay2D)
        % Slice i=1: (Y,Z) => Blue point slice (blupoint(1),:,:)
        % Slice i=2: (Y,X) => Blue point slice (:,blupoint(2),:) 
        % Slice i=3: (X,Z) => Blue point slice (:,:,blupoint(3)) 
        % Unless we assume an orientation of the body in the array we
        % cannot assume any is Axial, Coronal and Sagittal
        disp(axesLabels)
        for i = 1:3
            subplot(2, 2, subplot_positions(i));

            % Determine the projected 2D point of 3D bluePoint
            % This should be the same as on top?

            switch i
                case 1  % 
                    pt2d = myParam.bluePoint([1, 3]);  % (X,Z)

                case 2  % 
                    pt2d = myParam.bluePoint([2, 3]);  % (Y,Z)

                case 3  % 
                    pt2d = myParam.bluePoint([1, 2]);  % (X,Y)
            end
            
            % Extract the appropriate slice and labels for each view
            % If the mouse click a new point on the image then we need to
            % update the bluepoint coordinates
            
            switch i
                case 1  
                    slice = squeeze(myImagesTable(:, round(myParam.bluePoint(2)), :)).';
                    % Follow computer science conventions, origin is on top
                    x_label = axesLabels{1};
                    y_label = axesLabels{3};
                case 2   
                    slice = squeeze(myImagesTable(round(myParam.bluePoint(1)), :, :)).';
                    x_label = axesLabels{2};
                    y_label = axesLabels{3};
                case 3  
                    slice = squeeze(myImagesTable(:, :, round(myParam.bluePoint(3)))).';
                    x_label = axesLabels{1};
                    y_label = axesLabels{2};
            end

            % Display the slice
            imagesc(slice, myParam.colorLimits);
            
            % Axis direction handling
            if myParam.mirror_flag 
                set(gca, 'XDir', 'reverse');
                mirror_string = 'on'; 
            else
                set(gca, 'XDir', 'normal');
                mirror_string = 'off';
            end
    
            if myParam.reverse_flag 
                set(gca, 'YDir', 'normal');
                reverse_string = 'on'; 
            else
                set(gca, 'YDir', 'reverse');
                reverse_string = 'off';
            end
    
            % Swap if transposed
            if myParam.transpose_flag
                transpose_string = 'on';
                temp = x_label;
                x_label = y_label;
                y_label = temp;
            else
                transpose_string = 'off';
            end
    
            % Set aspect ratio and labels
            axis image;
            xlabel(x_label);
            ylabel(y_label);
    
            % Title with slice and flags
            myTitle = [ 'curImNum : ', num2str(myParam.curImNum), '/', ...
                        num2str(myParam.numOfImages), '   ', ...
                        'reverse :', reverse_string, '   ', ...
                        'mirror :', mirror_string, '   ', ...
                        'transpose :', transpose_string];
            title(myTitle);
    
            % -------------------- Plot Points ---------------------
            hold on;
            if ~isempty(point_list)
                p = point_list;
                for j = 1:size(p, 2)
                    p_3_int = max(1, fix(p(3, j)));
                    p_3_int = min(imSize(1, 3), p_3_int);
                    if p_3_int == myParam.curImNum
                        plot(p(2, j), p(1, j), 'r.');
                    end
                end
            end
    
            % Plot control points A, B, C
            for point = {'point_A', 'point_B', 'point_C'}
                pt = myParam.(point{1});
                if ~isempty(pt)
                    p = soft_coord(pt);
                    p_3_int = max(1, fix(p(3, 1)));
                    p_3_int = min(imSize(1, 3), p_3_int);
                    if p_3_int == myParam.curImNum
                        plot(p(2, 1), p(1, 1), 'g.');
                    end
                end
            end

            xlim manual; ylim manual;  % Freeze axes so lines stay in place
            xLimits = xlim();
            yLimits = ylim();

             % Only create drawpoints if they don't already exist
             % This is initialization at the first run of refresh_image()
            if isempty(myParam.bluePointHandles(i)) || ...
                ~isgraphics(myParam.bluePointHandles(i), 'images.roi.Point')

                %% Initialize blue point
                dp = drawpoint(gca, 'Position', pt2d, 'Color', 'b');
                addlistener(dp, 'MovingROI', @(src, evt) update_dragged_point(src, evt, i));
                
                myParam.bluePointHandles(i) = dp;

                %% Initialize blue lines
                % On drop — refresh all views
                addlistener(dp, 'ROIMoved', @(src, evt) finalize_drag(i));
                % Vertical line
                myParam.blueLineHandles(i,1) = line([pt2d(1), pt2d(1)], yLimits, ...
                    'Color', 'b', 'LineStyle', '--', ...
                'HitTest', 'off', 'PickableParts', 'none');
                % Horizontal line
                myParam.blueLineHandles(i,2) = line(xLimits, [pt2d(2), pt2d(2)], ...
                    'Color', 'b', 'LineStyle', '--', ...
                'HitTest', 'off', 'PickableParts', 'none');
                
            else
                % Update position instead of recreating
                myParam.bluePointHandles(i).Position = pt2d;
                % Update vertical line X only
                myParam.blueLineHandles(i,1).XData = [pt2d(1), pt2d(1)];
                myParam.blueLineHandles(i,1).YData = yLimits;
            
                % Update horizontal line Y only
                myParam.blueLineHandles(i,2).XData = xLimits;
                myParam.blueLineHandles(i,2).YData = [pt2d(2), pt2d(2)];
                uistack(myParam.bluePointHandles(i), 'top');
            end

            hold off;
            % ------------------------------------------------------
        end
    end


    function set_psi_theta_phi()
        % Rotate image with user given Euler angles

        % Get new angles
        myAngles = bmGetNum('Enter [psi, theta, phi] in radians:');

        % Check for valid answer
        if isempty(myAngles) 
            return;
        end
        
        myAngles = myAngles(:)';

        % Apply rotation with new angles if three angles were given
        if length(myAngles) == 3 
            myParam.psi         = myAngles(1, 1);
            myParam.theta       = myAngles(1, 2);
            myParam.phi         = myAngles(1, 3);
            myParam.rotation    = bmRotation3(myParam.psi, myParam.theta, myParam.phi);
        end

        % Refresh image
        update_image; 
        refresh_image;
        
    end


    function set_inPlane_angle()
        % Get slice currently shown and create new 2D bmImageViewerParam object copying the flags
        temp_image                  = myImagesTable(:, : , myParam.curImNum);
        temp_param                  = bmImageViewerParam(2, temp_image);
        temp_param.mirror_flag      = myParam.mirror_flag;
        temp_param.reverse_flag     = myParam.reverse_flag;
        temp_param.colorLimits      = myParam.colorLimits;

        % Create 2D interactive figure using the currently shown slice, 
        % interrupting further excecution of the code (true) until figure 
        % is closed 
        temp_param  = bmImage2( temp_image, ...
                                temp_param, ...
                                true);

        % Get angle of the 2D slice in radians
        alpha = temp_param.psi;

        % Consider transposed image
        if myParam.transpose_flag 
            alpha = -alpha;
        end

        % The rotation is done around an axis (X, Y or Z). Use the correct
        % elementary rotation matrix (depends on permutation)
        if isequal(myParam.permutation, [1, 2, 3])
            % Rotation matrix around 3rd axis (z - yaw)
            temp_R = [  cos(alpha), -sin(alpha),    0;
                        sin(alpha),  cos(alpha),    0;
                        0,           0,             1];
            
        elseif isequal(myParam.permutation, [3, 1, 2])
            % Rotation matrix around 2nd axis (y - pitch)
            temp_R = [  cos(alpha),     0,      sin(alpha);
                        0,              1,      0;
                        -sin(alpha),    0,      cos(alpha)];
            
        elseif isequal(myParam.permutation, [2, 3, 1])
            % Rotation matrix around 1st axis (x - roll)
            temp_R = [  1,      0,           0;
                        0,      cos(alpha), -sin(alpha);
                        0,      sin(alpha),  cos(alpha)];
            
        end
        
        % Calculate rotation matrix by applying new to existing rotation
        myParam.rotation = myParam.rotation*temp_R;

        % Calculate Euler angles for ZYZ rotation matrix
        [temp_psi, temp_theta, temp_phi] = bmPsi_theta_phi(myParam.rotation);
        myParam.psi         = temp_psi;
        myParam.theta       = temp_theta;
        myParam.phi         = temp_phi;

        % Caluclate rotation matrix from Euler angles
        myParam.rotation    = bmRotation3(myParam.psi, myParam.theta, myParam.phi);
        
        % Update image
        update_image;
        refresh_image;
        
    end

    function set_viewPlane()
        % Change rotation to show a slice (view plane) depending on the
        % placement of the control points A, B and C

        % Ask user to choose an option
        myAnswer = questdlg('Choose an option : ', 'Choose an option : ', ...
                            'Othog. to AB', ...
                            'Parallel to AB', ...
                            'Parallel to ABC', ...
                            'Othog. to AB');
        
        % No answer = closing the pop up
        if isempty(myAnswer)
            return;
        end
        
        % Get slice showing the plane orthogonal to the line connecting A
        % and B and lying in the middle between the two points
        if isequal(myAnswer, 'Othog. to AB')
            % Enusre A and B were placed
            if isempty(myParam.point_A)|| isempty(myParam.point_B)
                return;
            end

            % Line AB is the normal of the viewplane, calculate mid point
            myNormal    = myParam.point_A(:) - myParam.point_B(:); 
            mid_point   = (  myParam.point_A(:) + myParam.point_B(:)  )/2;

        % Get slice showing the plane defined by the line connecting A and 
        % B and the normal axis, lying in the middle between the two points
        elseif isequal(myAnswer, 'Parallel to AB')
            % Enusre A and B were placed
            if isempty(myParam.point_A)|| isempty(myParam.point_B)
                return;
            end

            % Create normal by taking the cross product of the line and the
            % current normal axis, calculate the mid point 
            myNormal    = cross(myParam.point_A(:) - myParam.point_B(:), axis_3(:));
            mid_point   = (  myParam.point_A(:) + myParam.point_B(:)  )/2;


        % Get slice showing the plane defined by the line connecting A and 
        % B and the line AC, lying in the middle between the three points
        elseif isequal(myAnswer, 'Parallel to ABC')
            % Enusre A, B and C were placed
            if isempty(myParam.point_A) || isempty(myParam.point_B) || isempty(myParam.point_C)
                return;
            end

            % Create normal by taking the cross product of the two lines
            % and calculate the mid point
            myNormal    = cross(myParam.point_B(:) - myParam.point_A(:), myParam.point_C(:) - myParam.point_A(:) );
            mid_point   = (  myParam.point_A(:) + myParam.point_B(:) + myParam.point_C(:) )/3;
        end
        
        % Make the normal a unit vector and calculate the Euler angles for 
        % rotation
        myNormal = myNormal(:)/norm(myNormal(:)); 
        [temp_theta, temp_phi]  = bmTheta_phi( myNormal );
        myParam.theta           = temp_theta;
        myParam.phi             = temp_phi;
        myParam.psi             = pi;

        % Calculate rotation matrix to achieve required orientation
        myParam.rotation        = bmRotation3(myParam.psi, myParam.theta, myParam.phi); 
        
        % Get coordinates after rotation and take the third coordinate for
        % the slice to show. Clipp to ensure valid value
        mid_point               = soft_coord(  mid_point(:)  ); 
        myParam.curImNum        = private_ind_box(  fix(  mid_point(3, 1)  ), myParam.numOfImages);
        
        % Reset data structure changes (except rotation)
        myParam.permutation     = [1, 2, 3]; 
        myParam.transpose_flag  = false;
        myParam.mirror_flag     = false;
        myParam.reverse_flag    = false;
        
        % Redraw image
        update_image; 
        refresh_image;
        
    end


    function print_help()
        % Print help information in console
        helpString = '\n\n'+...
        '----------------------------------------------------------------------------------------------\n'+...
        '----------------------------------------------------------------------------------------------\n'+...
        '<strong>Help for the interactive 3D image from bmImage3.m</strong>\n'+...
        '\n'+...
        'The image shows two dimensions as a slice of the third dimension.\n'+...
        '\n'+...
        'Changing the slice shown can be done using:\n'+...
	    '   Arrow key Up: Increase value\n'+...
	    '   Arrow key Down: Decrease value\n'+...
	    '   Mouse Wheel: Scroll in both directions\n'+...
	    '                Rolling away from body increases the value.\n'+...
	    '                Rolling towards the body decreases the value.\n'+...
        '\n\n'+...
        '----------------------------------------------------------------------------------------------\n'+...
        '<strong>Functional keys are</strong>: a, e, h, m, n, r, t, x, y, z, 3, Ctrl, Shift and Esc\n'+...
        'The Ctrl, Shift and Esc keys have to be repressed after each action.\n'+...
        'Careful! The flags of Ctrl, Shift and Esc are only updated if the \n'+...
        'figure is the active window.\n'+...
        '\n'+...
	    '   <strong>a)</strong> Allows to rotate the image.\n'+...
	    '   Ctrl + a: Manually rotate the visible plane (around the normal axis).\n'+...
		'             This is done on the 2D image by using the left and right arrow keys.\n'+...
	    '   Ctrl + Shift + a: Input a list [psi, theta, phi] by which the whole image is rotated.\n'+...
        '\n'+...
	    '   <strong>e)</strong> Allows to change the color limit (contrast) of the image.\n'+...
	    '   Ctrl + e: Open an Adjust Contrast Tool to change the color limits of the 2D image.\n'+...
	    '   Shift + e: Applies the color limits of the currently shown plane to the whole image data.\n'+...
		'              This is used to apply the changed color limits through the Contrast Tool \n'+...
	   	'              to the whole 3D image.\n'+...
	    '   Esc + e: Reset the color limits (Reset changes done after creation).\n'+...
	    '   Ctrl + Shift + e: Input the color limits as a list [low, high].\n'+...
        '\n'+...
	    '   <strong>h)</strong> Print this help information.\n'+...
        '\n'+...
    	'   <strong>m)</strong> Allows to mirror the image.\n'+...
	    '   Ctrl + Shift + m: Mirror the image horizontally (Change direction of the horizontal axis).\n'+...
        '\n'+...
	    '   <strong>n)</strong> Allows to change slice shown to certain number.\n'+...
	    '   Ctrl + n: Input the desired slice as a natural number.\n'+...
        '\n'+...
	    '   <strong>r)</strong> Allows to mirror the image.\n'+...
	    '   Ctrl + Shift + r: Mirror the image vertically (Change direction of the vertical axis).\n'+...
        '\n'+...
	    '   <strong>t)</strong> Allows to transpose the image.\n'+...
	    '   Ctrl + Shift + t: Transpose the first and second dimension (swap shown axes).\n'+...
        '\n'+...
	    '   <strong>x)</strong> Allows to change the visible axes to Y and Z.\n'+...
	    '   Ctrl + Shift + x: Permute the data such that X is the third dimension.\n'+...
        '\n'+...
	    '   <strong>y)</strong> Allows to change the visible axes to X and Z.\n'+...
	    '   Ctrl + Shift + x: Permute the data such that Y is the third dimension.\n'+...
        '\n'+...
	    '   <strong>z)</strong> Allows to change the visible axes to X and Y.\n'+...
	    '   Ctrl + Shift + x: Permute the data such that Z is the third dimension.\n'+...
        '\n'+...
	    '   <strong>3)</strong> Allows to change the view to show a slice depending on the control points A, B and C.\n'+...
	    '   Ctrl + Shift + 3: Choose one of three options:\n'+...
		'       Orthog. to AB: Slice orthogonal to the line AB and in the middle between A and B.\n'+...
		'       Parallel to AB: Slice defined by the line AB and the normal of the current view \n'+...
		'		                plane and in the middle between A and B.\n'+...
		'       Parallel to ABC: Slice defined by the lines AB and AC and in the middle between \n'+...
		'		                 A, B and C.\n'+...
        '\n\n'+...
        '----------------------------------------------------------------------------------------------\n'+...
        '<strong>The mouse buttons</strong> have the following functions when pressed:\n'+...
        '\n'+...
	    '   LMB: Displaying the value of the image pixel clicked on.\n'+...
        '\n'+...
	    '   Ctrl + LMB: Placing a control point at the mouse location.\n'+...
	    '   Ctrl + RMB: Placing a control point at the mouse location.\n'+...
        '\n'+...
	    '   RMB: Placing a point at the mouse location.\n'+...
        '\n'+...
	    '   Shift + LMB: Deleting the latest point placed. Can be repeated as long as there are points.\n'+...
	    '   Shift + RMB: Deleting the latest point placed. Can be repeated as long as there are points.\n'+...
	    '   MMB (Wheel): Deleting the latest point placed. Can be repeated as long as there are points.\n'+...
        '\n'+...
        '----------------------------------------------------------------------------------------------\n'+...
        '----------------------------------------------------------------------------------------------\n';
        fprintf(helpString);
    end


end

function out_ind = private_ind_box(arg_ind, arg_max)
    % Clip arg_ind between 1 and arg_max
    out_ind = arg_ind; 
    out_ind = min(out_ind, arg_max); 
    out_ind = max(out_ind, 1); 

end