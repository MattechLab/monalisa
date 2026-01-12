function [myMriAcquisition_node, reconFoV] = correctMetadataInteractive(myMriAcquisition_node, reconFoV)
%CORRECTMETADATAINTERACTIVE
% Opens the metadata editing window for user correction.
% Standalone version — only displays the parameter table.
%
% Authors:
%   Dominik Helbing
%   adapted and simplified by Mauro Leidi, 2024
%
% -------------------------------------------------------------------------

    %% --- Input check -----------------------------------------------------
    if ~isa(myMriAcquisition_node, 'bmMriAcquisitionParam')
        error("First argument must be an object of class bmMriAcquisitionParam.");
    end

    %% --- Parameter setup -------------------------------------------------
    paramNames = {'N', 'nLine', 'nShot', 'nSeg', 'nCh', 'nEcho', ...
                  'nShotOff', 'FoV (acq)', 'FoV (recon)'};

    automatedValues = [myMriAcquisition_node.N, ...
                       myMriAcquisition_node.nLine, ...
                       myMriAcquisition_node.nShot, ...
                       myMriAcquisition_node.nSeg, ...
                       myMriAcquisition_node.nCh, ...
                       myMriAcquisition_node.nEcho, ...
                       myMriAcquisition_node.nShot_off, ...
                       mode(myMriAcquisition_node.FoV), ...
                       mode(reconFoV)];

    %% --- Create main UI figure ------------------------------------------
    fig = uifigure('Name', 'Manual Parameter Adjustment', ...
                   'Position', [100 100 650 285]);
    movegui(fig, 'center');

    g = uigridlayout(fig, ...
        'RowHeight', {'fit','fit','1x'}, ...
        'ColumnWidth', {'1x','fit'});

    g2 = uigridlayout(g, [5,1], ...
        'RowHeight', {'fit', 'fit', 'fit', 30, 30});
    g2.Layout.Row = 2;
    g2.Layout.Column = 2;

    % Title label
    t = uilabel(g, ...
        'Text', 'Adjust Acquisition Parameters', ...
        'FontSize', 14, ...
        'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center');
    t.Layout.Row = 1;
    t.Layout.Column = [1,2];

    %% --- Table -----------------------------------------------------------
    s = uistyle('BackgroundColor', [0.9290 0.6940 0.1250]);  % orange highlight
    data = [paramNames', num2cell(automatedValues)', num2cell(automatedValues)'];

    uit = uitable(g, ...
        'Data', data, ...
        'ColumnEditable', [false false true], ...
        'ColumnName', {'Acquisition Parameters', 'Extracted Value', 'User Value'}, ...
        'ColumnWidth', '1x');
    uit.Layout.Row = 2;
    uit.Layout.Column = 1;
    addStyle(uit, s, "column", 3);

    %% --- Controls (dropdowns, checkbox, buttons) -------------------------
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


    %% --- Wait for user interaction --------------------------------------
    uiwait(fig);

    %% --- Retrieve values after closing ----------------------------------
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

    %% --- Nested callback functions --------------------------------------
    function confirmCallback(fig)
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

end
