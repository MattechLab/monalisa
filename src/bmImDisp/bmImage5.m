% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% I thank
%
% Simone Coppo,
%
% one of the inventor of free-running MRI, 
% for his help in implementing 5D image viewers. 


function varargout = bmImage5(argImagesTable, varargin)



% initial -----------------------------------------------------------------
[argParam, uiwait_flag] = bmVarargin(varargin);
if isempty(argParam)
    myParam = bmImageViewerParam(5, argImagesTable);
else
    myParam = bmImageViewerParam(argParam);
end

if isa(argImagesTable, 'logical')
    argImagesTable = single(argImagesTable);
end

% The four following variables are the dynamic variales that are updated at
% each change of view_angle
myImagesTable       = argImagesTable;
point_list          = myParam.point_list; 
imSize              = myParam.imSize; 
axis_3              = myParam.rotation(:, 3); 

controlFlag         = false;
shiftFlag           = false;
escFlag             = false;
% END_initial -------------------------------------------------------------




% graphic initial ---------------------------------------------------------
myFigure = figure(  'Name', 'bmImage5', ...
                    'WindowScrollWheelFcn', @myWindowScrollWheelFcn,...
                    'keyreleasefcn', @myKeyReleaseFcn,...
                    'keypressfcn', @myKeyPressFcn,...
                    'WindowButtonDownFcn', @myClickCallback);

colormap gray

update_image;
refresh_image;

if uiwait_flag
    uiwait;
end
if nargout > 0
    varargout{1} = myParam;
end
return;
% END_graphic initial -----------------------------------------------------

    function myWindowScrollWheelFcn(src,evnt) % nested function
        if evnt.VerticalScrollCount > 0            
            myScrol = max(1, fix(  abs(evnt.VerticalScrollAmount)/  1  ));
            myParam.curImNum = myParam.curImNum - myScrol;
            if myParam.curImNum < 1
                myParam.curImNum = myParam.numOfImages;
            end
        elseif evnt.VerticalScrollCount < 0
            myScrol = max(1, fix(  abs(evnt.VerticalScrollAmount)/  1  ));
            myParam.curImNum = myParam.curImNum + myScrol;
            if myParam.curImNum > myParam.numOfImages
                myParam.curImNum = 1;
            end
        end
        refresh_image;
    end

    function myClickCallback(src, evnt)
        switch get(gcf,'selectiontype')
            case 'normal'% left mouse button click
                show_imVal_in_title;
            case 'alt'% right mouse button click
                if controlFlag
                    set_control_point;
                    controlFlag = 0;
                else
                    set_point;
                    controlFlag = 0;
                end
            case 'extend'% right mouse button click
                delete_point;         
        end
    end


    function myKeyPressFcn(src,command) % nested function
        switch lower(command.Key)
            case 'downarrow'
                myParam.curImNum = myParam.curImNum - 1;
                if myParam.curImNum < 1
                    myParam.curImNum = myParam.numOfImages;
                end
                refresh_image;
                
            case 'uparrow'
                myParam.curImNum = myParam.curImNum + 1;
                if myParam.curImNum > myParam.numOfImages
                    myParam.curImNum = 1;
                end
                refresh_image;
                
            case 'leftarrow'
                if controlFlag
                    myParam.curImNum_5 = myParam.curImNum_5 - 1;
                    if myParam.curImNum_5 < 1
                        myParam.curImNum_5 = myParam.numOfImages_5;
                    end
                    refresh_image;
                else
                    myParam.curImNum_4 = myParam.curImNum_4 - 1;
                    if myParam.curImNum_4 < 1
                        myParam.curImNum_4 = myParam.numOfImages_4;
                    end
                    refresh_image;
                end
                
            case 'rightarrow'
                if controlFlag
                    myParam.curImNum_5 = myParam.curImNum_5 + 1;
                    if myParam.curImNum_5 > myParam.numOfImages_5
                        myParam.curImNum_5 = 1;
                    end
                    refresh_image;
                else
                    myParam.curImNum_4 = myParam.curImNum_4 + 1;
                    if myParam.curImNum_4 > myParam.numOfImages_4
                        myParam.curImNum_4 = 1;
                    end
                    refresh_image;
                end
                
            case 'control'     % Ctrl key is pressed
                controlFlag = 1;
            case 'shift'       % Shift key is pressed
                shiftFlag   = 1;
            case 'escape'      % Escape key is pressed
                escFlag     = 1;
            case 'n'
                if controlFlag % Ctrl + n  go to images number X
                    myParam.curImNum = private_ind_box(bmGetNat);
                    controlFlag = 0;
                    refresh_image;
                end
                
            case 'e'
                if (controlFlag && shiftFlag)
                    myParam.colorLimits = bmCol(bmGetNum)';
                    refresh_image;
                    controlFlag = 0;
                    shiftFlag = 0;    
                elseif controlFlag           
                    imcontrast(myFigure);    % DO NOT REFRESH image after this command
                    controlFlag = 0;
                elseif shiftFlag         
                    myParam.colorLimits=get(gca,'CLim');
                    refresh_image;
                    shiftFlag = 0;
                elseif escFlag           
                    myParam.colorLimits = myParam.colorLimits_0;
                    refresh_image;
                    escFlag = 0;
                end
                
            case 'm'
                if controlFlag && shiftFlag
                    myParam.mirror_flag = not(myParam.mirror_flag);
                    refresh_image;
                    controlFlag = 0;
                    shiftFlag = 0;
                end
            case 'r'
                if controlFlag && shiftFlag
                    myParam.reverse_flag = not(myParam.reverse_flag);
                    refresh_image;
                    controlFlag = 0;
                    shiftFlag = 0;
                end
            case 't'
                if controlFlag && shiftFlag
                    myParam.transpose_flag = not(myParam.transpose_flag);
                    update_image;
                    refresh_image;
                    controlFlag = 0;
                    shiftFlag = 0;
                end
                
            case '3'
                if (controlFlag && shiftFlag)
                    set_viewPlane;
                    controlFlag     = 0;
                    shiftFlag       = 0;
                end
                
            case 'a'
                if controlFlag && shiftFlag
                    set_psi_theta_phi;
                elseif controlFlag
                    set_inPlane_angle; 
                end
                controlFlag = 0; 
                shiftFlag   = 0;
                
            case 'x'
                if controlFlag && shiftFlag
                    myParam.permutation = [2, 3, 1];
                    update_image;
                    refresh_image;             
                end
                controlFlag = 0;
                shiftFlag   = 0;
                
            case 'y'
                if controlFlag && shiftFlag
                    myParam.permutation = [3, 1, 2];
                    update_image;
                    refresh_image;
                end
                controlFlag = 0;
                shiftFlag = 0;
            case 'z'
                if controlFlag && shiftFlag
                    myParam.permutation = [1, 2, 3];
                    update_image;
                    refresh_image;
                end
                controlFlag = 0;
                shiftFlag = 0;
        end % End Switch command.key
    end

    function myKeyReleaseFcn(src,command) % nested function
        % Switch through the type of key that has been pressed and chose
        % the action to perform
        switch lower(command.Key)
            case 'control'     % Ctrl key is released
                controlFlag = 0;
            case 'shift'       % Shift key is released
                shiftFlag = 0;
            case 'escape'      % Escape key is released
                escFlag = 0;
        end
    end

function myPoint = hard_coord(myPoint)
        
        myPoint = myPoint(:); 
        
        myX = myPoint(1, 1); 
        myY = myPoint(2, 1); 
        myZ = myPoint(3, 1); 
        
        if myParam.transpose_flag
            temp     = myX;
            myX      = myY;
            myY      = temp;
        end
        
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
        
        myPoint     = [perm_x, perm_y, perm_z]';
        
        myShift     = imSize(:)./2 + 1;
        myPoint     = myShift + (   myParam.rotation*(myPoint - myShift)  );
    end


    function myPoint = soft_coord(myPoint)
        
        myPoint     = myPoint(:);
        
        myShift     = myParam.imSize(:)./2 + 1;       
        myPoint     = myShift + (   myParam.rotation\(myPoint - myShift)  );
        
        myX = myPoint(1, 1); 
        myY = myPoint(2, 1); 
        myZ = myPoint(3, 1); 
        
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
        
        if myParam.transpose_flag
            temp     = perm_x;
            perm_x   = perm_y;
            perm_y   = temp;
        end
        
        myPoint = [perm_x, perm_y, perm_z]'; 
        
    end


    function p = get_soft_point_from_click()
        
        myCoordinates = get(gca,'CurrentPoint');
        
        if strcmp(  get(gcf,'selectiontype'), 'normal'  )
            myCoordinates = ceil(myCoordinates(1,1:2)-[0.5 0.5]);
        elseif strcmp(  get(gcf,'selectiontype'), 'alt'  )
            myCoordinates = myCoordinates(1,1:2);
        end
        
        myX = max(0, myCoordinates(2) );
        myX = min(  imSize(1, 1), myX);
        myY = max(0, myCoordinates(1) );
        myY = min(  imSize(1 ,2),  myY);
        myZ = myParam.curImNum;
        
        p = [myX, myY, myZ]';
        
    end

    function show_imVal_in_title(soft_point)
        
        soft_point = get_soft_point_from_click;
        
        title( ['(',    num2str(soft_point(1, 1)), ';', ...
                        num2str(soft_point(2, 1)), ';', ...
                        num2str(soft_point(3, 1)), ';', ...
                        num2str(myParam.curImNum_4), ')', ' : ', ...
                        num2str(  myImagesTable(soft_point(1, 1), ...
                                                soft_point(2, 1), ...
                                                soft_point(3, 1), ...
                                                myParam.curImNum_4, ...
                                                myParam.curImNum_5))] );
    end

    
    function set_point
        soft_point          = get_soft_point_from_click;
        hard_point          = hard_coord(soft_point);
        
        temp_ind_4 = myParam.curImNum_4;
        temp_ind_5 = myParam.curImNum_5;
        myParam.point_list{temp_ind_4, temp_ind_5}  = cat(2, myParam.point_list{temp_ind_4, temp_ind_5}, hard_point);
        point_list{temp_ind_4, temp_ind_5}          = [point_list{temp_ind_4, temp_ind_5}, soft_point];
        
        refresh_image;
    end

    function delete_point
        if ~isempty(myParam.point_list) && ~isempty(point_list)
            temp_ind_4 = myParam.curImNum_4;
            temp_ind_5 = myParam.curImNum_5;
            if ~isempty(myParam.point_list{temp_ind_4, temp_ind_5}) && ~isempty(point_list{temp_ind_4, temp_ind_5})
                
                myParam.point_list{temp_ind_4, temp_ind_5}(:, end)  = [];
                point_list{temp_ind_4, temp_ind_5}(:, end)          = [];
            end
        end
        refresh_image;
    end

    function set_control_point
        
        soft_point    = get_soft_point_from_click;
        hard_point    = hard_coord(soft_point);
        
        myAnswer = questdlg('Choose point : ', ...
                            'Choose point : ', 'A', 'B', 'C', 'A');
        
        if strcmp(myAnswer, 'NO') || isempty(myAnswer)
            return;
        end
        
        if myAnswer == 'A'
            myParam.point_A = hard_point;
        elseif myAnswer == 'B'
            myParam.point_B = hard_point;
        elseif myAnswer == 'C'
            myParam.point_C = hard_point;
        end
        refresh_image;
        
    end


    function update_image()
        reset_image;
        rotate_image;
        permute_image;
        transpose_image;        
    end


    function reset_image()
        myImagesTable   = argImagesTable;
        point_list      = myParam.point_list; 
        imSize          = myParam.imSize;        
        axis_3          = myParam.rotation(:, 3); 
    end

    function rotate_image()
        
        % the Euler-angles must first be defined in order to apply this
        % function. The image and the points are rotated according to the
        % pre-defined Euler-angles. The rotation myParam.rotation must also
        % be correctly prepared according to the Euler-angles. 
        
        if (myParam.psi == 0)&&(myParam.theta == 0)&&(myParam.phi == 0)
            return;
        end
        
        myShift = imSize(:)/2+1; 
        R = myParam.rotation; 
        
        [temp_X, temp_Y, temp_Z] = ndgrid(  1:imSize(1, 1), ...
                                            1:imSize(1, 2), ...
                                            1:imSize(1, 3));
        
        temp_X      = temp_X - myShift(1, 1);
        temp_Y      = temp_Y - myShift(2, 1);
        temp_Z      = temp_Z - myShift(3, 1);
        new_grid    = R*cat(1, temp_X(:)', temp_Y(:)', temp_Z(:)');
        new_X       = new_grid(1, :);
        new_Y       = new_grid(2, :);
        new_Z       = new_grid(3, :);
        
        % update_image
        for i = 1:myParam.numOfImages_4
            for j = 1:myParam.numOfImages_5
                temp_imagesTable = interpn( temp_X, temp_Y, temp_Z, ...
                    myImagesTable(:, :, :, i, j), ...
                    new_X, new_Y, new_Z);
                myImagesTable(:, :, :, i, j) = reshape(temp_imagesTable, myParam.imSize(1, 1:3));
            end
        end
        myImagesTable(isnan(myImagesTable)) = 0;
        
        % update_point_list
        if ~isempty(point_list)
            if ~isempty(point_list{myParam.curImNum_4, myParam.curImNum_5})
                
                
                temp_point = point_list{myParam.curImNum_4, myParam.curImNum_5}; 
                
                temp_point = temp_point - repmat(  myShift, [1, size(temp_point, 2 )]  );
                temp_point = R\temp_point;
                temp_point = temp_point + repmat(  myShift, [1, size(temp_point, 2 )]  );
                
                point_list{myParam.curImNum_4, myParam.curImNum_5} = temp_point; 
                
            end
        end
        
        % update axis_3
        axis_3 = myParam.rotation(:, 3); 
        
        % imSize is not updated. It is a choice to do so. 
        
    end

    function permute_image()
        if isequal(myParam.permutation, [1, 2, 3])
            
            myParam.numOfImages = imSize(1, 3);
            
            myParam.curImNum = max([myParam.curImNum, 1]);
            myParam.curImNum = min([myParam.curImNum, myParam.numOfImages]);
            
        elseif isequal(myParam.permutation, [3, 1, 2])
            
            imSize = [  imSize(1, 3), ...
                        imSize(1, 1), ...
                        imSize(1, 2)];
                            
            myParam.numOfImages = imSize(1, 3);
            
            myImagesTable = permute(myImagesTable, [myParam.permutation, 4, 5]);
            
            myParam.curImNum = max([myParam.curImNum, 1]);
            myParam.curImNum = min([myParam.curImNum, myParam.numOfImages]);
            
            if ~isempty(myParam.point_list)
                temp_point_list = point_list(3, :);
                point_list(3, :) = point_list(2, :);
                point_list(2, :) = point_list(1, :);
                point_list(1, :) = temp_point_list;
            end
            
            axis_3 = myParam.rotation(:, 2); 
            
        elseif isequal(myParam.permutation, [2, 3, 1])
            
            imSize = [  imSize(1, 2), ...
                        imSize(1, 3), ...
                        imSize(1, 1)];
            
            myParam.numOfImages = imSize(1, 3);
            
            myImagesTable = permute(myImagesTable, [myParam.permutation, 4, 5]);
            
            myParam.curImNum = max([myParam.curImNum, 1]);
            myParam.curImNum = min([myParam.curImNum, myParam.numOfImages]);
            
            if ~isempty(myParam.point_list)
                temp_point_list  = point_list(1, :);
                point_list(1, :) = point_list(2, :);
                point_list(2, :) = point_list(3, :);
                point_list(3, :) = temp_point_list;
            end
            
            axis_3 = myParam.rotation(:, 1); 
            
        end
    end

    function transpose_image()
        if myParam.transpose_flag
            
            imSize = [  imSize(1, 2), ...
                        imSize(1, 1), ...
                        imSize(1, 3)];
            
            myImagesTable = permute(myImagesTable, [2, 1, 3, 4, 5]);
            
            if ~isempty(point_list)
                temp_point_list  = point_list(1, :);
                point_list(1, :) = point_list(2, :);
                point_list(2, :) = temp_point_list;
            end
            
            axis_3 = -axis_3; 
            
        end
    end

    function refresh_image()
        
        % display image ---------------------------------------------------
        figure(myFigure);
        imagesc(    myImagesTable(:, : , myParam.curImNum, myParam.curImNum_4, myParam.curImNum_5), ...
                    myParam.colorLimits);
        
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
        
        if myParam.transpose_flag
            transpose_string = 'on';
            temp = x_label; 
            x_label = y_label; 
            y_label = temp; 
        else
            transpose_string = 'off';
        end
        
        axis image
        myTitle = [ 'curImNum : ',  num2str(myParam.curImNum), '/', ...
            num2str(myParam.numOfImages), '   ', ...
                    'curImNum_4 : ',  num2str(myParam.curImNum_4), '/', ...
                    num2str(myParam.numOfImages_4), '   ', ...
                    'curImNum_5 : ',  num2str(myParam.curImNum_5), '/', ...
                    num2str(myParam.numOfImages_5), '   ', ...
                    '\newline', ...
                    'reverse :',    reverse_string, '   ', ...
                    'mirror :',     mirror_string,'   ', ...
                    'transpose :',  transpose_string];
        title(myTitle);
        xlabel(y_label);
        ylabel(x_label);
        % END_displax image -----------------------------------------------
        
        
    
        % plot point_list -------------------------------------------------
        if ~isempty(point_list)
            hold on
            
            
            if ~isempty(point_list{myParam.curImNum_4, myParam.curImNum_5})
                p = point_list{myParam.curImNum_4, myParam.curImNum_5};
                for i = 1:size(p, 2)
                    p_3_int = max(1, fix(p(3, i)));
                    p_3_int = min(imSize(1, 3), p_3_int);
                    if p_3_int == myParam.curImNum
                        plot(p(2, i), p(1, i), 'r.')
                    end
                end
            end
            
            hold off
        end
        if ~isempty(myParam.point_A)
            hold on
            p = soft_coord(myParam.point_A);
            p_3_int = max(1, fix(p(3, 1)));
            p_3_int = min(imSize(1, 3), p_3_int);
            if p_3_int == myParam.curImNum
                plot(p(2, 1), p(1, 1), 'g.')
            end
            hold off
        end
        if ~isempty(myParam.point_B)
            hold on
            p = soft_coord(myParam.point_B);
            p_3_int = max(1, fix(p(3, 1)));
            p_3_int = min(imSize(1, 3), p_3_int);
            if p_3_int == myParam.curImNum
                plot(p(2, 1), p(1, 1), 'g.')
            end
            hold off
        end
        if ~isempty(myParam.point_C)
            hold on
            p = soft_coord(myParam.point_C);
            p_3_int = max(1, fix(p(3, 1)));
            p_3_int = min(imSize(1, 3), p_3_int);
            if p_3_int == myParam.curImNum
                plot(p(2, 1), p(1, 1), 'g.')
            end
            hold off
        end
        % END_plot point_list --------------------------------------------- 
        
    end


    function set_psi_theta_phi()
        
        myAngles = bmGetNum;
        if isempty(myAngles)
            return;
        end
        
        myAngles = myAngles(:)';
        if length(myAngles) == 3
            myParam.psi         = myAngles(1, 1);
            myParam.theta       = myAngles(1, 2);
            myParam.phi         = myAngles(1, 3);
            myParam.rotation    = bmRotation3(myParam.psi, myParam.theta, myParam.phi);
        end
        update_image;
        refresh_image;
        
    end


    function set_inPlane_angle()
        
        temp_image                  = myImagesTable(:, : , myParam.curImNum, myParam.curImNum_4, myParam.curImNum_5);
        temp_param                  = bmImageViewerParam(2, temp_image);
        temp_param.mirror_flag      = myParam.mirror_flag;
        temp_param.reverse_flag     = myParam.reverse_flag;
        temp_param.colorLimits      = myParam.colorLimits;
        
        temp_param  = bmImage2( temp_image, ...
                                temp_param, ...
                                true);
        
        alpha = temp_param.psi;
        if myParam.transpose_flag
            alpha = -alpha;
        end
        
        if isequal(myParam.permutation, [1, 2, 3])
            
            temp_R = [  cos(alpha), -sin(alpha),    0;
                        sin(alpha),  cos(alpha),    0;
                        0,           0,             1];
            
        elseif isequal(myParam.permutation, [3, 1, 2])
            
            temp_R = [  cos(alpha),     0,      sin(alpha);
                        0,              1,      0;
                        -sin(alpha),    0,      cos(alpha)];
            
        elseif isequal(myParam.permutation, [2, 3, 1])
            
            temp_R = [  1,      0,           0;
                        0,      cos(alpha), -sin(alpha);
                        0,      sin(alpha),  cos(alpha)];
            
        end
        
        
        myParam.rotation = myParam.rotation*temp_R;
        [temp_psi, temp_theta, temp_phi] = bmPsi_theta_phi(myParam.rotation);
        myParam.psi         = temp_psi;
        myParam.theta       = temp_theta;
        myParam.phi         = temp_phi;
        myParam.rotation    = bmRotation3(myParam.psi, myParam.theta, myParam.phi);
        
        update_image;
        refresh_image;
        
    end

    function set_viewPlane()
        
        myAnswer = questdlg('Choose an option : ', 'Choose an option : ', ...
                            'Othog. to AB', ...
                            'Paralel to AB', ...
                            'Paralel to ABC', ...
                            'Othog. to AB');
        
        if isempty(myAnswer)
            return;
        end
        
        if isequal(myAnswer, 'Othog. to AB')
            if isempty(myParam.point_A)|| isempty(myParam.point_B)
                return;
            end
            myNormal    = myParam.point_A(:) - myParam.point_B(:);
            mid_point   = (  myParam.point_A(:) + myParam.point_B(:)  )/2;
        elseif isequal(myAnswer, 'Paralel to AB')
            if isempty(myParam.point_A)|| isempty(myParam.point_B)
                return;
            end
            myNormal    = cross(myParam.point_A(:) - myParam.point_B(:), axis_3(:));
            mid_point   = (  myParam.point_A(:) + myParam.point_B(:)  )/2;
        elseif isequal(myAnswer, 'Paralel to ABC')
            if isempty(myParam.point_A) || isempty(myParam.point_B) || isempty(myParam.point_C)
                return;
            end
            myNormal    = cross(myParam.point_B(:) - myParam.point_A(:), myParam.point_C(:) - myParam.point_A(:) );
            mid_point   = (  myParam.point_A(:) + myParam.point_B(:) + myParam.point_C(:) )/3;
        end
        
        myNormal = myNormal(:)/norm(myNormal(:));
        [temp_theta, temp_phi]  = bmTheta_phi( myNormal );
        myParam.theta           = temp_theta;
        myParam.phi             = temp_phi;
        myParam.psi             = pi;
        myParam.rotation        = bmRotation3(myParam.psi, myParam.theta, myParam.phi);
        
        mid_point               = soft_coord(  mid_point(:)  );
        myParam.curImNum        = private_ind_box(  fix(  mid_point(3, 1)  ), myParam.numOfImages);
        
        myParam.permutation     = [1, 2, 3];
        myParam.transpose_flag  = false;
        myParam.mirror_flag     = false;
        myParam.reverse_flag    = false;
        
        update_image;
        refresh_image;
        
    end


end

function out_ind = private_ind_box(arg_ind, arg_max)

    out_ind = arg_ind; 
    out_ind = min(out_ind, arg_ind); 
    out_ind = max(out_ind, 1); 

end