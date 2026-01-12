function [myMriAcquisition_node, reconFoV] = checkMetadataInteractive(mySI, s_mean, s_center_mass, myMriAcquisition_node, reconFoV)
% [myMriAcquisition_node, reconFoV] = ISMRMRD_info(mySI, s_mean,
%                       s_center_mass, myMriAcquisition_node, reconFoV)
%
% This function plots the magnitude spectrum which shows at which shot the
% steady state is reached. It also opens an interactive figure showing the
% extracted metadata that will be used, and allowing modifications.
% This function should only be called when the automatic flag is set to
% true and will interrupt code execution.
%
% Authors:
%   Dominik Helbing
%   MattechLab 2024
%
% Parameters:
%   mySI (array): The SI magnitude calculated for every shot.
%   s_mean (list): The mean of mySI calculated for every shot.
%   s_center_mass (list): The center of mass of mySI calculated for every
%   shot.
%   myMriAcquisition_node (bmMriAcquisitionParam): The extracted meta data.
%   reconFoV (int): The extracted reconstruction FoV.
%
% Returns:
%   myMriAcquisition_node (bmMriAcquisitionParam): The extracted meta data,
%    possibly modified by the user.
%   reconFoV (int): The extracted reconstruction FoV, possibly modified by
%    the user.
    
    %% Initialize arguments
    % Test if myMriAcquisition_node is a bmMriAcquisitionParam
    if ~isa(myMriAcquisition_node, 'bmMriAcquisitionParam')
        error("Wrong arguments. Second argument should be an object of " + ...
            "class bmMriAcquisitionParam");
    end
    
    % Define the parameters for 3D radial acquisition
    paramNames = {'N', 'nLine', 'nShot', 'nSeg', 'nCh', 'nEcho', ...
        'nShotOff', 'FoV (acq)', 'FoV (recon)'};
    
    % Define automated values for 3D radial acquisition
    automatedValues = [myMriAcquisition_node.N, ...
                       myMriAcquisition_node.nLine, ...
                       myMriAcquisition_node.nShot, ...
                       myMriAcquisition_node.nSeg, ...
                       myMriAcquisition_node.nCh, ...
                       myMriAcquisition_node.nEcho, ...
                       myMriAcquisition_node.nShot_off, ...
                       mode(myMriAcquisition_node.FoV), ...
                       mode(reconFoV)];
    
    %% Show plot (magnitude spectrum)
    % Create figure
    figSI = figure('Name', 'DataInfo Magnitude');
    imagesc(mySI, [0, 3*mean(mySI(:))]); 
    imgax = gca;
    set(gca,'YDir','normal');
    colorbar
    colormap gray
    
    % Plotting the mean and COM of each shot
    hold on
    plot(s_center_mass, 'g.-')
    plot(s_mean, 'r.-')
    
    % Plotting vertical line for shotOff
    shotOff = myMriAcquisition_node.nShot_off;
    if ~isempty(shotOff)
        % Add vertical line at steady state index
        sLine = xline(shotOff, 'c--');
        xCord = shotOff/imgax.XLim(2) + 0.02;
        txt = text(xCord, 0.85, ...
             sprintf('shot = %i', shotOff), "HorizontalAlignment", "left", ...
             'Color', 'black', 'BackgroundColor', 'white', ...
             'Units', 'normalized', 'Margin', 0.5);
    end
    
    % Adding legend, title and labels
    legend('Center of Mass', 'Mean', 'Steady State', 'Location', 'best')
    xlabel('nShot')
    ylabel('N','Rotation',0)
    title(sprintf(['Magnitude spectrum for first segment of each ' ...
        'shot\n(estimates which shots should be excluded)']))
    hold off

    % Make shotOff line dragable
    isDragging = false;
    maxShot = length(s_mean);
    set(figSI, 'WindowButtonDownFcn', @(src, event) startDragFcn(figSI));
    
    
    %% Show interactive figure
    % Create a UI figure
    fig = uifigure('Name', 'Manual Parameter Adjustement', ...
        'Position', [100 100 650 285]);
    
    % Move the figure to the center of the primary screen
    movegui(fig,'center');
    
    % Create grid
    g = uigridlayout(fig, 'RowHeight', {'fit','fit','1x'}, ...
        'ColumnWidth', {'1x','fit'});
    
    % Create nested grid for buttons
    g2 = uigridlayout(g, [5,1], 'RowHeight', {'fit', 'fit', 'fit', 30, 30});
    g2.Layout.Row = 2;
    g2.Layout.Column = 2;
    
    % Add a title label in top row
    t = uilabel(g, 'Text', 'Adjust Acquisition Parameters', ...
        'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    t.Layout.Row = 1;
    t.Layout.Column = [1,2];
    
    % Creat style for column color (orange for editable column)
    s = uistyle('BackgroundColor', [0.9290 0.6940 0.1250]);
    
    % Define the data for the table
    data = [paramNames', num2cell(automatedValues)', num2cell(automatedValues)'];
    
    % Create the table with auto-adjusting column widths
    uit = uitable(g, 'Data', data, 'ColumnEditable', [false false true], ...
        'ColumnName', {'Acquisition Parameters', 'Extracted Value', 'User Value'}, ...
        'ColumnWidth', '1x');
    uit.Layout.Row = 2;
    uit.Layout.Column = 1;
    
    % Change color of 3rd column
    addStyle(uit, s, "column", 3);
    
    % Add dropdown for different cases, maybe table changes depending on case
    dd = uidropdown(g2, 'Items', {'Non-Cartesian', 'Cartesian', 'Case 3'}, ...
        "ValueChangedFcn",@(src,event) updateTable(src, uit));
    dropDown = dd.Value;

    % Add dropdown for navigation
    dd_self = uidropdown(g2, 'Items', {'SI Navigation', ...
                                       'Pilot Tone Navigation', ...
                                       'Other'});
    
    % If self nav is not used atm
    if ~myMriAcquisition_node.selfNav_flag
        dd_self.Value = 'Other';
    end
    
    % Add a checkbox for roosk_flag
    cbx_rooks = uicheckbox(g2, 'Text', 'Remove oversampling', 'Value', ...
        myMriAcquisition_node.roosk_flag);
    
    % Add a button to confirm changes
    uibutton(g2, 'Text', 'Confirm', ...
        'ButtonPushedFcn', @(btn,event) confirmCallback(fig));
    
    % Add a button to cancel
    uibutton(g2, 'Text', 'Cancel', 'BackgroundColor', '#d0d0d0', ...
        'ButtonPushedFcn', @(btn,event) closeFigure(fig));
    
    % Handle figure close request to resume execution
    fig.CloseRequestFcn = @(src, event) closeFigure(fig);

    % Make dragable line update table
    set(figSI, 'WindowButtonUpFcn', @(src, event) stopDragFcn(figSI, ...
        uit, paramNames));
    
    % Wait for the user to close the figure or press confirm
    uiwait(fig);
    
    % Only update the values if figure was closed using "Confirm"
    if ishandle(fig)
        % Table values
        automatedValues = cell2mat(uit.Data(:,3))';
    
        % Checkbox values
        selfNav = strcmp(dd_self.Value, 'SI Navigation');
        myMriAcquisition_node.selfNav_flag = selfNav;
        myMriAcquisition_node.roosk_flag = cbx_rooks.Value;
    
        % Dropdown value
        dropDown = dd.Value;
    
        % Close the figure
        close(fig);  
    end

    % Close SI figure
    if ishandle(figSI)
        close(figSI);
    end
    

    %% Return values
    % Update values in myMriAcquisition_node
    if strcmp(dropDown, 'Non-Cartesian')
        % Table values
        myMriAcquisition_node.N = automatedValues(1);
        myMriAcquisition_node.nLine = automatedValues(2);
        myMriAcquisition_node.nShot = automatedValues(3);
        myMriAcquisition_node.nSeg = automatedValues(4);
        myMriAcquisition_node.nCh = automatedValues(5);
        myMriAcquisition_node.nEcho = automatedValues(6);
        myMriAcquisition_node.nShot_off = automatedValues(7);
        newFoV = ones(size(myMriAcquisition_node.FoV)).*automatedValues(8);
        myMriAcquisition_node.FoV = newFoV;
        reconFoV = ones(size(myMriAcquisition_node.FoV)).*automatedValues(9);
    end
    
    if strcmp(dropDown, 'Cartesian')
        error("Case not implemented yet");
    end
    
    if strcmp(dropDown, 'Case 3')
        error("Case not implemented yet");
    end
    % End of function


    %% Nested callback functions
    function confirmCallback(fig)
        % Callback function to handle the confirmation
        
        % Resume execution
        uiresume(fig);  
    end
    
    
    function updateTable(src, uit)
        % Callback function to handle a dropdown change NOT IN USE YET
        % Change the background color of the columns depending on the drop
        % down. This is only as an example on how to use it.
        cols = uistyle('BackgroundColor', [0.9290 0.6940 0.1250]);
        removeStyle(uit);
        switch src.Value
            case 'Non-Cartesian'
                col = 3;
            case 'Cartesian'
                col = 2;
            case 'Case 3'
                col = 1;
            otherwise
                col = 1;
        end
        addStyle(uit, cols, "column", col);
    end
    
    
    function closeFigure(fig)
        % Callback function to handle figure close event

        % Resume execution and close the figure
        uiresume(fig);  
        delete(fig);
    end


    function startDragFcn(fig)
        % This function checks if a line is clicked and starts the dragging
        % function if this is the case

        % Check if the click is close to either line
        cp = get(gca, 'CurrentPoint');
        x_click = cp(1,1);
        
        % Test if line was clicked
        if abs(x_click - sLine.Value) < 10  % Adjust as needed
            isDragging = true;
        end
        
        if isDragging
            % Activate dragging function if line is clicked
            set(fig, 'WindowButtonMotionFcn', @(src, event) draggingFcn());
        end
    end


    function draggingFcn()
        % This function updates the line and the images when a line is
        % dragged

        % Test if dragginFcn is correctly called
        if isDragging
            % Get current point and extract x values for redrawing the 
            % active line
            cp = get(gca, 'CurrentPoint');

            % clip data and round to integer
            nshOff = min(round(cp(1,1)), floor(imgax.XLim(2)));
            nshOff = max(nshOff, ceil(imgax.XLim(1)));
            % Redraw line and text
            set(sLine, 'Value', nshOff);
            newPos = (nshOff - imgax.XLim(1)) / ...
                     (imgax.XLim(2) - imgax.XLim(1)) + 0.02;
            txt.Position(1) = newPos;
            txt.String = sprintf('shot = %i', nshOff);
            drawnow;
        end
    end


    function stopDragFcn(fig, uit, params)
        % This function resets the motion function and updates the table 
        % when the mouse button is let go and upd
        
        % Reset dragging
        isDragging = false;
        set(fig, 'WindowButtonMotionFcn', '');

        % Update nShotOff
        rowIdx = strcmp(params, 'nShotOff');
        uit.Data{rowIdx,3} = sLine.Value;
    end

end
