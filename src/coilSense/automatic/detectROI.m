function bBox = detectROI(rawData, N_u)
% bBox = detectROI(rawData, N_u)
%
% This function guesses the region of interest (ROI) of the given 3D image
% by transforming the image into a binary representation using Otsu's
% method and extracting the largest connected component.
%
% Authors:
%   Dominik Helbing
%   MattechLab 2024
%
% Parameters:
%   rawData (array): Contains the data of a 3D image for which a bounding
%   box around the ROI should be guessed.
%   N_u (list): The size of each dimension.
%
% Returns:
%   bBox (array): Contains the minimum value and the width of the box for
%   every dimension. The array is structured like this: 
%   [xMin, xWidth; yMin, yWidth; zMin, zWidth]

    %% Initialize arguments
    % Increase box in all directions by this value (magic number)
    padding = 3;

    % Ensure correct size
    N_u = N_u(:)';
    rawData = bmBlockReshape(rawData, N_u);

    % Sum over every dimension and normalize
    zData = sum(rawData, 3);
    zData = (zData - min(zData, [], "all")) / (max(zData, [], "all") - min(zData, [], "all"));
    
    yData = permute(rawData, [3, 1, 2]);
    yData = sum(yData, 3);
    yData = (yData - min(yData, [], "all")) / (max(yData, [], "all") - min(yData, [], "all"));
    
    xData = permute(rawData, [2, 3, 1]);
    xData = sum(xData, 3);
    xData = (xData - min(xData, [], "all")) / (max(xData, [], "all") - min(xData, [], "all"));
    
    % Combine data in 4th dimension to use a loop
    nData = cat(4, xData, yData, zData);
    

    %% Create bounding box around biggest connected component
    % List for bounding box positions in all three dimensions
    boxes = zeros([3,4]);

    for i = 1:3
        % Get x-, y- and then zData
        data = nData(:,:,:,i);

        % Automatic threshold selection using Otsu's method
        th = graythresh(data);

        % Binarize the images using the threshold
        binary = imbinarize(data, th);

        % Find connected components
        cc = bwconncomp(binary);

        % Find the bounding box and area for all connected components
        stats = regionprops(cc, 'BoundingBox', 'Area');

        % Find biggest connected component by looking at the area
        [~, idx] = max([stats.Area]);

        % Get bounding box of the biggest connected component
        boxes(i,:) = stats(idx).BoundingBox;
    end

    % Get minimum and width for each coordinate (position)
    % Pos = [hmin, vmin, width, height] (h = horizontal, v = vertical)
    % See selectROI.m to see how the axes are plotted
    % x = [zmin, ymin, zw, yw], y = [xmin, zmin, xw, zw]
    % z = [ymin, xmin, yw, xw]
    xMin = min(boxes(2,1), boxes(3,2));
    yMin = min(boxes(1,2), boxes(3,1));
    zMin = min(boxes(1,1), boxes(2,2));
    xW = max(boxes(2,3), boxes(3,4));
    yW = max(boxes(1,4), boxes(3,3));
    zW = max(boxes(1,3), boxes(2,4));

    % Add padding, drop dezimals and clip the value
    xMin = max(fix(xMin - padding), 1);
    yMin = max(fix(yMin - padding), 1);
    zMin = max(fix(zMin - padding), 1);
    xW = min(fix(xW + 2*padding), N_u(1) - xMin);
    yW = min(fix(yW + 2*padding), N_u(2) - yMin);
    zW = min(fix(zW + 2*padding), N_u(3) - zMin);
    
    % Prepare value to be returned
    bBox = [xMin, xW; yMin, yW; zMin, zW];

end

