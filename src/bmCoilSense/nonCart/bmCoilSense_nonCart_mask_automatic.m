function m = bmCoilSense_nonCart_mask_automatic(y, Gn, autoFlag, varargin)
% m = bmCoilSense_nonCart_mask(y, Gn, varargin)
%
% This function creates a mask for the regridded data which is calculated
% with a matrix multiplication of Gn*y. The mask depends on the optional
% parameters (varargin) that allow to give a threshold value for RMS and
% MIP (Maximum Intensity Projection), and min and max values for x, y, z.
% ONLY WORKS FOR 3D DATA AT THE MOMENT (X,Y,Z and channels)
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Contributors:
%   Dominik Helbing (Documentation & Comments)
%   MattechLab 2024
%
% Parameters:
%   y (array): Raw data that should be gridded onto the grid defined by the
%   bmSparseMat in Gn.
%   Gn (bmSparseMat): Sparse Matrix defining the new uniform grid.
%   autoFlag (Logical): Flag; Automatically decide on thresholds and 
%   borders for mask if true.
%   varargin{1}: Double containing the voxel intensity threshold for RMS
%   value. If this is kept empty, the value will be decided in this
%   function. 
%   varargin{2}: Double containing the voxel intensity threshold for MIP
%   value. If this is kept empty, the value will be decided in this
%   function. 
%   varargin{3}: Array containing the min and max values for the 3
%   dimensions. Has the structure [xMin, xMax; yMin, yMax; zMin, zMax]. If
%   this is kept empty, the value will be decided in this function.
%   varargin{4}: Value (not yet commented). Default value is empty.
%   varargin{5}: Value (not yet commented). Default value is empty.
%
% Returns:
%   m (array): Mask for grid defined by Gn masking all pixels outside the
%   ROI and below threshold values, by setting their points in the mask to
%   0
%
% Examples:
%   m = bmCoilSense_nonCart_mask_automatic(y_body, Gn, autoFlag);
%   m = bmCoilSense_nonCart_mask_automatic(y_body, Gn, autoFlag, [], ...
%   [], borders);
%   m = bmCoilSense_nonCart_mask_automatic(y_body, Gn, autoFlag, thRMS, ...
%   thMIP, borders, open_size, close_size);

%% Initialize arguments
% Magic number
colorMax = 100; 

% Extract optional arguments
[   th_RMS, ...
    th_MIP, ...
    borders, ...
    open_size, ...
    close_size,]    = bmVarargin(varargin); 

N_u     = double(Gn.N_u(:)');
imDim   = size(N_u(:), 1);


%% Calculate RMS and MIP
% Grid y onto the uniform grid of size N_u, given in block format
x       = bmBlockReshape(bmNasha(y, Gn, N_u), N_u); 

% Calculate RMS for each data point across all channel
myRMS = bmRMS(x, N_u); 

% Perform MIP for each data point
myMIP = bmMIP(x, N_u); 

% Normalize and scale RMS and MIP values (maybe devide by max - min)
myRMS = colorMax*(myRMS - min(myRMS(:)))/max(myRMS(:));
myMIP = colorMax*(myMIP - min(myMIP(:)))/max(myMIP(:));


%% Compute threshold values
% If neither given as argument
if isempty(th_RMS) | isempty(th_MIP)
    [th_RMS, th_MIP] = thresholdRMS_MIP(colorMax, myRMS, myMIP, N_u, autoFlag);
end


%% Compute region of interest
% If borders is not given
if isempty(borders)
    % Apply threshold to temporary data
    tempRMS = myRMS;
    tempRMS(tempRMS <= th_RMS) = 0;
    tempMIP = myMIP;
    tempMIP(tempMIP <= th_MIP) = 0;

    % Call function with temporary data
    bordersRMS = detectROI(tempRMS, N_u);
    bordersMIP = detectROI(tempMIP, N_u);

    % Borders are [xMin, xWidth; yMin, yWidth; zMin, zWidth]
    bordersMin = min(bordersRMS(:,1), bordersMIP(:,1));
    bordersMax = max(bordersRMS(:,2), bordersMIP(:,2));

    borders = cat(2, bordersMin, bordersMax);

    % Semiautomatic selection of ROI
    borders = selectROI(tempRMS, tempMIP, N_u, autoFlag, borders);
end

if ~autoFlag
    % Create interactive figures to display RMS and MIP values
    bmImage(myRMS)
    title('RMS')
    bmImage(myMIP)
    title('MIP')
end


%% Create mask
% Create mask for valid RMS and MIP values
m = true(size(myRMS));

% Use threshold to decide lowest valid value
% Use RMS threshold for both if MIP th is not given
if not(isempty(th_RMS)) & isempty(th_MIP) 
    m = (myRMS > th_RMS) & (myMIP > th_RMS);

% Use MIP threshold for both if RMS th is not given
elseif isempty(th_RMS) & not(isempty(th_MIP)) 
    m = (myRMS > th_MIP) & (myMIP > th_MIP);

elseif not(isempty(th_RMS)) & not(isempty(th_MIP))
    m = (myRMS > th_RMS) & (myMIP > th_MIP);
end


% Modify mask to crop the image in every dimension if max and min values
% are given
if imDim == 3
    % Crop the image in x direction
    if borders(1, 1) > 1
        m(1:borders(1, 1)-1,   :, :)  = false;
    end

    if borders(1, 2) < N_u(1, 1)
        m(borders(1, 2)+1:end, :, :)  = false;
    end

    % Crop the image in y direction
    if borders(2, 1) > 1
        m(:, 1:borders(2, 1)-1,   :)  = false;
    end

    if borders(2, 2) < N_u(1, 2)
        m(:, borders(2, 2):end, :)  = false;
    end
    
    % Crop the image in z direction
    if borders(3, 1) > 1
        m(:, :, 1:borders(3, 1))    = false;
    end

    if borders(3, 2) < N_u(1, 3)
        m(:, :, borders(3, 2):end)  = false;
    end
end


% TO BE COMMENTED
if not(isempty(open_size))
    if open_size > 0
        m = bmImOpen(m, bmImShiftList(['sphere', num2str(imDim)], open_size, 0));
    end
end

if not(isempty(close_size))
    if close_size > 0
        m = bmImClose(m, bmImShiftList(['sphere', num2str(imDim)], close_size, 0));
    end
end


% Show RMS with mask applied next to the mask in an interactive figure
if sum(m(:) == false) > 0
    temp_im = m.*myRMS;

    % Combine normalized applied mask RMS and mask
    temp_im = cat(2, temp_im/max(abs(temp_im(:))), m); 
    if ~autoFlag
        bmImage(temp_im)
    end
end


% Prepare mask for output
m = bmBlockReshape(m, N_u);

end

