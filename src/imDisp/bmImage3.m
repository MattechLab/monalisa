function varargout = bmImage3(argImagesTable, varargin)
% varargout = bmImage3(argImagesTable, varargin)
%
% This function creates an interactive figure for 3D data. The figure
% visualizes the data by plotting a greyscale heatmap for two dimensions
% and allows to scroll through the third dimension. There are other options
% that allow to modify the view. These options are further explained in the
% console by pressing h (for help).
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Contributors:
%   Dominik Helbing (Documentation, Comments, Help and Bug fixing)
%   MattechLab 2024
%
% Parameters:
%   argImagesTable (3D array): The data to be visualized
%   varargin{1}: bmImageViewerParam object containing the parameters for
%   the image.
%   varargin{2}: Logical (flag) that interrupts the code execution until
%   the figure is closed if true.
%
% Returns:
%   varargout{1}: bmImageViewerParam object containing the parameter for
%   the image. Useful to get the coordinates of placed points.

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
                    'WindowScrollWheelFcn', @myWindowScrollWheelFcn,...
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

    function myWindowScrollWheelFcn(~,evnt)
        % Mousewheel callback function to give interactions to bmImage3
        if evnt.VerticalScrollCount > 0    
            % Scrolling towards body -> reducing slice value
            myScrol = max(1, fix(  abs(evnt.VerticalScrollAmount)/  1  ));
            myParam.curImNum = myParam.curImNum - myScrol;
            
            % Wrap around if end is reached
            if myParam.curImNum < 1
                myParam.curImNum = myParam.numOfImages;
            end
        elseif evnt.VerticalScrollCount < 0
            % Scrolling away from body -> increasing slice value
            myScrol = max(1, fix(  abs(evnt.VerticalScrollAmount)/  1  ));
            myParam.curImNum = myParam.curImNum + myScrol;
            
            % Wrap around if end is reached
            if myParam.curImNum > myParam.numOfImages
                myParam.curImNum = 1;
            end
        end
        refresh_image;
    end

    function myClickCallback(~, ~)
        switch get(gcf,'selectiontype')
            case 'normal'
                % Left mouse button click
                % Display value of pixel clicked on in the title
                show_imVal_in_title;
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
        % Display the value of the pixel clicked on, by changing the title

        % Get array indices closest to the mouse click
        soft_point = get_soft_point_from_click;

        % Change title to (x;y;z) : value in data(x,y,z)
        title( ['(',    num2str(soft_point(1, 1)), ';', ...
                        num2str(soft_point(2, 1)), ';', ...
                        num2str(soft_point(3, 1)), ')', ' : ', ...
                        num2str(  myImagesTable(soft_point(1, 1), soft_point(2, 1), soft_point(3, 1))  ) ] );
    end

    
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
        % Show data as image depending on the modification done without 
        % further modifying the data. Only modifications done are visual
        % changes like mirroring axes.

        % display image ---------------------------------------------------
        % Display figure on top
        figure(myFigure); 

        % Display data with colormap and color limits
        imagesc(    myImagesTable(:, : , myParam.curImNum), ...
                    myParam.colorLimits); 
        
        % Update X-axis direction depending on the flag and update string 
        % for title
        if myParam.mirror_flag 
            set(gca, 'XDir', 'reverse');
            mirror_string = 'on'; 
        else
            set(gca, 'XDir', 'normal');
            mirror_string = 'off';
        end
        
        % Update Y-axis direction depending on the flag and update string 
        % for title
        if myParam.reverse_flag 
            set(gca, 'YDir', 'normal');
            reverse_string = 'on';
        else
            set(gca, 'YDir', 'reverse');
            reverse_string = 'off';
        end
        
        % Change label of axes depending on permutation
        if isequal(myParam.permutation, [1, 2, 3]) 
            x_label = 'X'; 
            y_label = 'Y'; 
        elseif isequal(myParam.permutation, [3, 1, 2])
            x_label = 'Z'; 
            y_label = 'X'; 
        elseif isequal(myParam.permutation, [2, 3, 1])
            x_label = 'Y'; 
            y_label = 'Z'; 
        end
        
        % Update string for title and swap labels if transposed
        if myParam.transpose_flag 
            transpose_string = 'on';
            temp = x_label; 
            x_label = y_label; 
            y_label = temp; 
        else
            transpose_string = 'off';
        end

        % Use the same length for the data units along each axis and fit 
        % the axes box tightly around the data
        axis image

        % Construct title string
        myTitle = [ 'curImNum : ',  num2str(myParam.curImNum), '/', ... 
                                    num2str(myParam.numOfImages), '   ', ...
                    'reverse :',    reverse_string, '   ', ...
                    'mirror :',     mirror_string,'   ', ...
                    'transpose :',  transpose_string];

        % Update title and axis labels
        title(myTitle); 
        xlabel(y_label); 
        ylabel(x_label);

        % END_displax image -----------------------------------------------
        
        
    
        % plot point_list -------------------------------------------------
        % Plot all points on the active slice
        if ~isempty(point_list) 
            hold on
            p = point_list; 
            for i = 1:size(p, 2) 
                % Clip coordinate between [1, max]
                p_3_int = max(1, fix(p(3, i))); 
                p_3_int = min(imSize(1, 3), p_3_int); 

                % Plot point if it is on the active slice
                if p_3_int == myParam.curImNum 
                   plot(p(2, i), p(1, i), 'r.') 
                end
            end
            hold off
        end

        % Control point coordinates are not updated (unlike points) that is
        % why the soft coordinates are required

        % Plot control point A if it is on the active slice
        if ~isempty(myParam.point_A)
            hold on
            % Get coordinates in modified grid
            p = soft_coord(myParam.point_A);

            % Clip coordinate between [1, max]
            p_3_int = max(1, fix(p(3, 1))); 
            p_3_int = min(imSize(1, 3), p_3_int);

            % Plot point if it is on the active slice
            if p_3_int == myParam.curImNum 
                plot(p(2, 1), p(1, 1), 'g.')
            end
            hold off
        end

        % Plot control point B if it is on the active slice
        if ~isempty(myParam.point_B)
            hold on
            % Get coordinates in modified grid
            p = soft_coord(myParam.point_B);

            % Clip coordinate between [1, max]
            p_3_int = max(1, fix(p(3, 1)));
            p_3_int = min(imSize(1, 3), p_3_int);

            % Plot point if it is on the active slice
            if p_3_int == myParam.curImNum
                plot(p(2, 1), p(1, 1), 'g.')
            end
            hold off
        end

        % Plot control point C if it is on the active slice
        if ~isempty(myParam.point_C)
            hold on
            % Get coordinates in modified grid
            p = soft_coord(myParam.point_C);

            % Clip coordinate between [1, max]
            p_3_int = max(1, fix(p(3, 1)));
            p_3_int = min(imSize(1, 3), p_3_int);

            % Plot point if it is on the active slice
            if p_3_int == myParam.curImNum
                plot(p(2, 1), p(1, 1), 'g.')
            end
            hold off
        end
        % END_plot point_list --------------------------------------------- 
        
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