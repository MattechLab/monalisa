% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function bmFieldPlot2_noImage(arg_x, arg_y, arg_vx, arg_vy, argSize, autoScaleFlag, myNorm_max)

% argin initial -----------------------------------------------------------


argSize = argSize(:)';
argSize = argSize(1, 1:2);

nArrow = 20;

arg_x = reshape(arg_x, argSize);
arg_y = reshape(arg_y, argSize);
arg_vx = reshape(arg_vx, argSize);
arg_vy = reshape(arg_vy, argSize);


















transpose_flag = false; 

x = []; 
y = []; 
vx = []; 
vy = []; 








mySize = argSize; 

update_field; 

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






myFigure = figure(  'Name', 'bmFieldPlot2', ...
    'WindowScrollWheelFcn', @myWindowScrollWheelFcn,...
    'keyreleasefcn', @myKeyReleaseFcn,...
    'keypressfcn', @myKeyPressFcn,...
    'WindowButtonDownFcn', @myClickCallback);












refresh;

% END_graphic initial -----------------------------------------------------

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
            case 'control'     % Ctrl key is pressed
                controlFlag = 1;
            case 'shift'       % Shift key is pressed
                shiftFlag = 1;
            case 'escape'      % Escape key is pressed
                escFlag = 1;
            case 'a'
                if controlFlag && shiftFlag
                    autoScaleFlag = not(autoScaleFlag);
                    refresh;
                    shiftFlag = 0; 
                    controlFlag = 0;
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
        
        
        vx = arg_vx;
        vy = arg_vy;
        
        mySize = argSize; 
        
        x_label = 'X'; 
        y_label = 'Y'; 
        
        
        
        
        transpose_string = 'off'; 
    end


    function reduce_field()
        
        myNorm = sqrt(vx(:).^2 + vy(:).^2);
        myNorm(isinf(myNorm)) = 0;
        myNorm(isnan(myNorm)) = 0;
        
        vx(myNorm > myNorm_max) = 0;
        vy(myNorm > myNorm_max) = 0;
        
        
        nPart_1 = fix(argSize(1, 1)/(nArrow+1)) + 1;
        nPart_2 = fix(argSize(1, 2)/(nArrow+1)) + 1;
        
        x =  x(1:nPart_1:end, 1:nPart_2:end);
        y =  y(1:nPart_1:end, 1:nPart_2:end);
        
        
        vx =  vx(1:nPart_1:end, 1:nPart_2:end);
        vy =  vy(1:nPart_1:end, 1:nPart_2:end);
    end


    function transpose_field()
       if transpose_flag
        
           temp = x; 
           x = y; 
           y = temp; 
           
           temp = vx; 
           vx = vy;
           vy = temp; 
           
           x = permute(x, [2, 1]); 
           y = permute(y, [2, 1]);
           vx = permute(vx, [2, 1]); 
           vy = permute(vy, [2, 1]);
           
           mySize = [mySize(1, 2), mySize(1, 1)]; 
           
           temp = x_label;
           x_label = y_label;
           y_label = temp;
           
           
           
           transpose_string = 'on';
           
       end
    end



    function update_field()        
        
        reset_field;
        reduce_field;
        transpose_field; 
        
    end







    function refresh()
        
        figure(myFigure);
        
        
        
        
        if autoScaleFlag
            quiver(y, x, vy, vx, 'Linewidth', 2, 'Autoscale', 'on');
        else
            quiver(y, x, vy, vx, 'Linewidth', 2, 'Autoscale', 'off');
        end        
        
        hold off
        
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
        myTitle = [ 'Autoscale : ', num2str(autoScaleFlag), ...
                    ', normMax : ', num2str(myNorm_max),...
                    '; reverse : ', reverse_string, ...
                    '; transpose : ', transpose_string];
        
        
                
        title(myTitle);
        
        caxis([-1, 0]);
        xlabel(y_label); 
        ylabel(x_label); 
        
    end
end







