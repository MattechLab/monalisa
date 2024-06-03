% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function bmFieldPlot3_noImage(arg_x, arg_y, arg_z, arg_vx, arg_vy, arg_vz, argSize, autoScaleFlag, myNorm_max)

% argin initial -----------------------------------------------------------


argSize = argSize(:)';
argSize = argSize(1, 1:3);

nArrow  = 200;

arg_x   = reshape(arg_x, argSize);
arg_y   = reshape(arg_y, argSize);
arg_z   = reshape(arg_z, argSize);
arg_vx  = reshape(arg_vx, argSize);
arg_vy  = reshape(arg_vy, argSize);
arg_vz  = reshape(arg_vz, argSize);















myPerm = [1, 2, 3];
transpose_flag = false;

x = [];
y = [];
z = [];
vx = [];
vy = [];
vz = [];


psi = 0;
theta = 0;
phi = 0;

mySize = argSize;
numOfImages = mySize(1, 3);
curImNum = 1;

% END_argin initial -------------------------------------------------------



% graphic initial ---------------------------------------------------------

controlFlag     = 0;
shiftFlag       = 0;
escFlag         = 0;

reverse_flag = false;
mirror_flag  = false;

reverse_string = 'off';
transpose_string = 'off';
mirror_string = 'off';

x_label = 'X';
y_label = 'Y';
z_label = 'Z';

myFigure = figure(  'Name', 'bmFieldPlot3', ...
    'WindowScrollWheelFcn', @myWindowScrollWheelFcn,...
    'keyreleasefcn', @myKeyReleaseFcn,...
    'keypressfcn', @myKeyPressFcn,...
    'WindowButtonDownFcn', @myClickCallback);

update_field; 
refresh;

% END_graphic initial -----------------------------------------------------

    function myWindowScrollWheelFcn(src,evnt) % nested function
        
        if evnt.VerticalScrollCount > 0
            curImNum = curImNum - evnt.VerticalScrollAmount;
            if curImNum < 1
                curImNum = numOfImages;
            end
        elseif evnt.VerticalScrollCount < 0
            curImNum = curImNum + evnt.VerticalScrollAmount;
            if curImNum > numOfImages
                curImNum = 1;
            end
        end
        
        refresh;
        
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


    function myKeyPressFcn(src,command) % nested function
        switch lower(command.Key)
            case 'downarrow'
                curImNum = curImNum - 1;
                
                if curImNum < 1
                    curImNum = numOfImages;
                end
                refresh;
                
            case 'uparrow'
                
                curImNum = curImNum + 1;
                
                if curImNum > numOfImages
                    curImNum = 1;
                end
                refresh;
                
            case 'control'     % Ctrl key is pressed
                controlFlag=1;
                
            case 'shift'       % Shift key is pressed
                shiftFlag=1;
                
            case 'escape'      % Escape key is pressed
                escFlag=1;
            case 'a'
                if controlFlag && shiftFlag
                    autoScaleFlag = not(autoScaleFlag);
                    refresh;
                    shiftFlag = 0;
                    controlFlag = 0;
                end
            case 'd'
                if controlFlag % Ctrl + D  go to images number X
                    myNumber = bmGetNat;
                    myNumber = min(myNumber, numOfImages);
                    if myNumber > 0
                        curImNum = myNumber;
                    end
                    controlFlag = 0;
                    refresh;
                end
            case 'n'
                if controlFlag && shiftFlag
                    
                    myNorm_max = bmGetNum;
                    update_field;
                    refresh;
                    controlFlag = 0;
                    shiftFlag = 0;
                end
            case 'm'
                if controlFlag && shiftFlag
                    
                    mirror_flag = not(mirror_flag);
                    if mirror_flag
                        mirror_string = 'on';
                    else
                        mirror_string = 'off';
                    end
                    
                    refresh;
                    controlFlag = 0;
                    shiftFlag = 0;
                end
            case 'r'
                if controlFlag && shiftFlag
                    
                    reverse_flag = not(reverse_flag);
                    if reverse_flag
                        reverse_string = 'on';
                    else
                        reverse_string = 'off';
                    end
                    
                    refresh;
                    controlFlag = 0;
                    shiftFlag = 0;
                end
            case 't'
                if controlFlag && shiftFlag
                    
                    transpose_flag = not(transpose_flag);
                    
                    update_field;
                    refresh;
                    controlFlag = 0;
                    shiftFlag = 0;
                end
            case 'x'
                if controlFlag && shiftFlag
                    
                    myPerm = [2, 3, 1];
                    
                    update_field;
                    refresh;
                    controlFlag = 0;
                    shiftFlag = 0;
                end
            case 'y'
                if controlFlag && shiftFlag
                    
                    myPerm = [3, 1, 2];
                    
                    update_field;
                    refresh;
                    controlFlag = 0;
                    shiftFlag = 0;
                end
            case 'z'
                if controlFlag && shiftFlag
                    
                    myPerm = [1, 2, 3];
                    
                    update_field;
                    refresh;
                    controlFlag = 0;
                    shiftFlag = 0;
                end
        end % End Switch command.key
    end


    function myClickCallback(src, evnt)
        
        myCoordinates = get(gca,'CurrentPoint');
        myCoordinates = ceil(myCoordinates(1,1:2)-[0.5 0.5]);
        myX = myCoordinates(2);
        myY = myCoordinates(1);
        
        switch get(gcf,'selectiontype')
            case 'normal'%left mouse button click
                1+1;
            case 'alt'%right mouse button click
                1+1;
        end
    end


    function reset_field()
        x = arg_x;
        y = arg_y;
        z = arg_z;
        
        vx = arg_vx;
        vy = arg_vy;
        vz = arg_vz;
        mySize = argSize;
        
        x_label = 'X';
        y_label = 'Y';
        z_label = 'Z';
        
        
        
        
        transpose_string = 'off';
    end

    function rotate_field()
%        myRotation = bmRotation(psi, theta, phi);
%        myRotation_inv = bmRotation(-phi, -theta, -psi);
        
        
    end

    function permute_field()
        if isequal(myPerm, [1, 2, 3])
            
            numOfImages = mySize(1, 3); 
            curImNum = max([curImNum, 1]); 
            curImNum = min([curImNum, numOfImages]); 

        elseif isequal(myPerm, [3, 1, 2])
            
            temp = z;
            z = y;
            y = x;
            x = temp;
            
            temp = vz;
            vz = vy;
            vy = vx;
            vx = temp;
            
            z = permute(z, myPerm);
            y = permute(y, myPerm);
            x = permute(x, myPerm);
            vz = permute(vz, myPerm);
            vy = permute(vy, myPerm);
            vx = permute(vx, myPerm);
            
            mySize = [mySize(1, 3), mySize(1, 1), mySize(1, 2)];
            numOfImages = mySize(1, 3);
            
            temp = z_label;
            z_label = y_label;
            y_label = x_label;
            x_label = temp;
             
            
            
            curImNum = max([curImNum, 1]); 
            curImNum = min([curImNum, numOfImages]); 
  
        
        elseif isequal(myPerm, [2, 3, 1])
            
            temp = x;
            x = y;
            y = z;
            z = temp;
            
            temp = vx;
            vx = vy;
            vy = vz;
            vz = temp;
            
            z = permute(z, myPerm);
            y = permute(y, myPerm);
            x = permute(x, myPerm);
            vz = permute(vz, myPerm);
            vy = permute(vy, myPerm);
            vx = permute(vx, myPerm);
            
            mySize = [mySize(1, 2), mySize(1, 3), mySize(1, 1)];
            numOfImages = mySize(1, 3);
            
            temp = x_label;
            x_label = y_label;
            y_label = z_label;
            z_label = temp;
            
            
            
            curImNum = max([curImNum, 1]); 
            curImNum = min([curImNum, numOfImages]); 

            
        end
    end

    function reduce_field()
        
        myNorm = sqrt(vx(:).^2 + vy(:).^2 + vz(:).^2);
        myNorm(isinf(myNorm)) = 0;
        myNorm(isnan(myNorm)) = 0;
        
        vx(myNorm > myNorm_max) = 0;
        vy(myNorm > myNorm_max) = 0;
        vz(myNorm > myNorm_max) = 0;
        
        nPart_1 = fix(mySize(1, 1)/(nArrow+1)) + 1;
        nPart_2 = fix(mySize(1, 2)/(nArrow+1)) + 1;
        
        x = x(1:nPart_1:end, 1:nPart_2:end, :);
        y = y(1:nPart_1:end, 1:nPart_2:end, :);
        z = z(1:nPart_1:end, 1:nPart_2:end, :);
        
        vx = vx(1:nPart_1:end, 1:nPart_2:end, :);
        vy = vy(1:nPart_1:end, 1:nPart_2:end, :);
        vz = vz(1:nPart_1:end, 1:nPart_2:end, :);
    end

    function transpose_field()
        if transpose_flag
            
            temp = x;
            x = y;
            y = temp;
            
            temp = vx;
            vx = vy;
            vy = temp;
            
            x = permute(x, [2, 1, 3]);
            y = permute(y, [2, 1, 3]);
            vx = permute(vx, [2, 1, 3]);
            vy = permute(vy, [2, 1, 3]);
            
            mySize = [mySize(1, 2), mySize(1, 1), mySize(1, 3)];
            
            temp = x_label;
            x_label = y_label;
            y_label = temp;
            
        
            
            transpose_string = 'on';
        end
    end



    function update_field()
        
        reset_field;
        rotate_field;
        permute_field;
        reduce_field;
        transpose_field;
        
    end





    function refresh()
        
        figure(myFigure);
        
        
        
        
        if autoScaleFlag
            quiver3(y(:, :, curImNum), x(:, :, curImNum), zeros(size(x, 1), size(x, 2)), vy(:, :, curImNum), vx(:, :, curImNum), vz(:, :, curImNum), 'Linewidth', 2, 'Autoscale', 'on');
        else
            quiver3(y(:, :, curImNum), x(:, :, curImNum), zeros(size(x, 1), size(x, 2)), vy(:, :, curImNum), vx(:, :, curImNum), vz(:, :, curImNum), 'Linewidth', 2, 'Autoscale', 'off');
        end                
        hold off
        
        view([0 90]);
        
        if mirror_flag
            set(gca, 'XDir', 'reverse');
        else
            set(gca, 'XDir', 'normal');
        end
        
        if reverse_flag
            set(gca, 'YDir', 'normal');
        else
            set(gca, 'YDir', 'reverse');
        end
        
        axis image
        colormap gray
        myTitle = [ 'Autoscale : ',num2str(autoScaleFlag), ...
            '  normMax : ', num2str(myNorm_max), ...
            '  ', z_label, ' : ', num2str(z(1, 1, curImNum)), ...
            '\newline', ...
            '  reverse  :', reverse_string, ...
            '  mirror : ', mirror_string, ...
            '  transpose  :', transpose_string];
        
        
        title(myTitle);
        
        caxis([-1, 0]);
        xlabel(y_label);
        ylabel(x_label);
        
    end
end




