% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function varargout = bmImage2(argImagesTable, varargin)



% argin initial -----------------------------------------------------------
[argParam, uiwait_flag] = bmVarargin(varargin);
if isempty(argParam)
    myParam = bmImageViewerParam(2, argImagesTable);
else
    myParam = bmImageViewerParam(argParam);
end

if isa(argImagesTable, 'logical')
    argImagesTable = single(argImagesTable);
end


myImagesTable       = argImagesTable;
point_list          = myParam.point_list; 
imSize              = myParam.imSize; 


controlFlag         = false;
shiftFlag           = false;
escFlag             = false;

% END_argin initial -------------------------------------------------------



% graphic initial ---------------------------------------------------------
myFigure = figure(  'Name', 'bmImage2', ...
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
        1+1;
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
                1+1;
                
            case 'uparrow'
                1+1;
                
            case 'rightarrow'
                
                if (controlFlag)
                    myParam.psi = myParam.psi + pi/128;
                    myParam.rotation = bmRotation2(myParam.psi); 
                else
                    myParam.psi = myParam.psi + pi/16;
                    myParam.rotation = bmRotation2(myParam.psi); 
                end
                update_image;
                refresh_image;
                
            case 'leftarrow'
                
                if (controlFlag)
                    myParam.psi = myParam.psi - pi/128;
                    myParam.rotation = bmRotation2(myParam.psi); 
                else
                    myParam.psi = myParam.psi - pi/16;
                    myParam.rotation = bmRotation2(myParam.psi); 
                end
                
                update_image;
                refresh_image;
                
            case 'control'     % Ctrl key is pressed
                controlFlag     = 1;
            case 'shift'       % Shift key is pressed
                shiftFlag       = 1;
            case 'escape'      % Escape key is pressed
                escFlag         = 1;
                
                
                
                
                
                
                
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
                
                
                
                
                
                
                
                
            case 'a'
                if controlFlag && shiftFlag
                    myAngles            = bmCol(bmGetNum)';
                    myParam.psi         = myAngles(1, 1);
                    myParam.rotation    = bmRotation2(myParam.psi); 
                    update_image;
                    refresh_image;
                    controlFlag = 0;
                    shiftFlag = 0;
                end
        end % End Switch command.key
    end

    function myKeyReleaseFcn(src,command) % nested function
        % Switch through the type of key that has been pressed and chose
        % the action to perform
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
        
        myPoint = myPoint(:);
        
        myX = myPoint(1, 1);
        myY = myPoint(2, 1);
        
        if myParam.transpose_flag
            temp     = myX;
            myX      = myY;
            myY      = temp;
        end
        
        myPoint     = [myX, myY]';
        
        myShift     = imSize(:)./2 + 1;
        myPoint     = myShift + (   myParam.rotation*(myPoint - myShift)  );
    end

    function myPoint = soft_coord(myPoint)
        
        myPoint     = myPoint(:);
        
        myShift     = myParam.imSize(:)./2 + 1;
        myPoint     = myShift + (   myParam.rotation\(myPoint - myShift)  );
        
        myX = myPoint(1, 1);
        myY = myPoint(2, 1);
        
        if myParam.transpose_flag
            temp  = myX;
            myX   = myY;
            myY   = temp;
        end
        
        myPoint = [myX, myY]';
        
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
        
        p = [myX, myY]';
        
    end


    function show_imVal_in_title(soft_point)
        
        soft_point = get_soft_point_from_click;
        
        title( ['(',    num2str(soft_point(1, 1)), ';', ...
            num2str(soft_point(2, 1)), ';', ...
            num2str(  myImagesTable(  soft_point(1, 1), soft_point(2, 1)  )), ...
            ')']);
    end


    function set_point
        soft_point          = get_soft_point_from_click;
        hard_point          = hard_coord(soft_point);
        myParam.point_list  = cat(2, myParam.point_list, hard_point);
        point_list          = [point_list, soft_point];
        refresh_image;
    end

    function delete_point
        if ~isempty(myParam.point_list) && ~isempty(point_list)
            myParam.point_list(:, end)  = [];
            point_list(:, end)          = [];
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
        transpose_image;
    end

    function reset_image()
        myImagesTable   = argImagesTable;
        point_list      = myParam.point_list; 
        imSize          = myParam.imSize;        
    end


    function rotate_image()
        
        if (myParam.psi == 0)
            return;
        end
        
        myShift = imSize(:)/2+1;
        R = myParam.rotation;
        
        [temp_X, temp_Y] = ndgrid(  1:imSize(1, 1), ... 
                                    1:imSize(1, 2)  );
        
        temp_X = temp_X - myShift(1, 1);
        temp_Y = temp_Y - myShift(2, 1);
        new_grid = R*cat(1, temp_X(:)', temp_Y(:)');
        new_X = new_grid(1, :);
        new_Y = new_grid(2, :);
        
        myImagesTable = interpn(temp_X, temp_Y, myImagesTable, new_X, new_Y);
        myImagesTable = reshape(myImagesTable, imSize);
        myImagesTable(isnan(myImagesTable)) = 0;
        
        % update_point_list
        if ~isempty(point_list)
            point_list = point_list - repmat(  myShift, [1, size(point_list, 2 )]  );
            point_list = R\point_list; 
            point_list = point_list + repmat(  myShift, [1, size(point_list, 2 )]  );
        end
        
        
    end



    function transpose_image()
        if myParam.transpose_flag
            imSize = [  imSize(1, 2), ...
                imSize(1, 1)];
            myImagesTable = permute(myImagesTable, [2, 1]);
            
            if ~isempty(point_list)
                temp_point_list  = point_list(1, :);
                point_list(1, :) = point_list(2, :);
                point_list(2, :) = temp_point_list;
            end
            
        end
    end



    function refresh_image()

        % display image ---------------------------------------------------
        figure(myFigure);
        imagesc(    myImagesTable, ...
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
        
        x_label = 'X'; 
        y_label = 'Y'; 
        
        if myParam.transpose_flag
            transpose_string = 'on';
            temp = x_label; 
            x_label = y_label; 
            y_label = temp; 
        else
            transpose_string = 'off';
        end
        
        axis image
        myTitle = [ 'reverse :',    reverse_string, '   ', ...
                    'mirror :',     mirror_string,'   ', ...
                    'transpose :',  transpose_string];
        title(myTitle);
        xlabel(y_label);
        ylabel(x_label);
        % END_displax image -----------------------------------------------
        
        
    
        % plot point_list -------------------------------------------------
        if ~isempty(point_list)
            hold on
            p = point_list; 
            plot(p(2, :), p(1, :), 'r.') 
            hold off
        end
        if ~isempty(myParam.point_A)
            hold on
            p = soft_coord(myParam.point_A);
            plot(p(2, :), p(1, :), 'g.')
            hold off
        end
        if ~isempty(myParam.point_B)
            hold on
            p = soft_coord(myParam.point_B);
            plot(p(2, :), p(1, :), 'g.')
            hold off
        end
        if ~isempty(myParam.point_C)
            hold on
            p = soft_coord(myParam.point_C);
            plot(p(2, :), p(1, :), 'g.')
            hold off
        end
        % END_plot point_list --------------------------------------------- 
        
    end

end

