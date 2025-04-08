function m = bmCoilSense_nonCart_mask(y, Gn, varargin)
% m = bmCoilSense_nonCart_mask(y, Gn, varargin)
%
% This function creates a mask for the regridded data which is calculated
% with a matrix multiplication of Gn*y. The mask depends on the optional
% parameters (varargin) that allow to give a threshold value for RMS and
% MIP (Maximum Intensity Projection), and min and max values for x, y, z.
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
%   varargin{1}: Lower boundary of the x indices of the mask (ROI).
%   varargin{2}: Upper boundary of the x indices of the mask (ROI).
%   varargin{3}: Lower boundary of the y indices of the mask (ROI).
%   varargin{4}: Upper boundary of the y indices of the mask (ROI).
%   varargin{5}: Lower boundary of the z indices of the mask (ROI).
%   varargin{6}: Upper boundary of the z indices of the mask (ROI).
%   varargin{7}: Threshold for RMS value.
%   varargin{8}: Threshold for MIP value.
%   varargin{9}: Value (not yet commented)
%   varargin{10}: Value (not yet commented)
%   varargin{11}: Flag; Display images if true.
%
% Returns:
%   m (array): Mask for grid defined by Gn masking all pixels outside the
%   ROI and below threshold values, by setting their points in the mask to
%   0
%
% Notes:
%   The x, y, z constrictions are meant to exclude high intensity pixels
%   outside the main image. These could be due to artifacts.
%   This is rerunnable multiple times therefore you can have as inputs 
%   the outputs.

%% Initialize arguments
% magic number
colorMax = 100; 

% Extract optional arguments
[   x_min, x_max, ...
    y_min, y_max, ...
    z_min, z_max, ...
    th_RMS, th_MIP, ...
    open_size, ...
    close_size, ...
    display_flag]    = bmVarargin(varargin); 


N_u     = double(Gn.N_u(:)');
imDim   = size(N_u(:), 1);


%% Calculate RMS and MIP
% Grid y onto the uniform grid of size N_u, given in block format and image
% space
x       = bmBlockReshape(bmNasha(y, Gn, N_u), N_u); 

% Calculate RMS for each data point across all channel
myRMS = bmRMS(x, N_u); 

% Perform MIP for each data point
myMIP = bmMIP(x, N_u); 

% Normalize and scale RMS and MIP values (maybe devide by max - min)
myRMS = colorMax*(myRMS - min(myRMS(:)))/max(myRMS(:));
myMIP = colorMax*(myMIP - min(myMIP(:)))/max(myMIP(:));

% Get number of points of x
nPix = size(myRMS(:), 1); 

n_RMS = zeros(1, colorMax);
n_MIP = zeros(1, colorMax);

% Calculate the fraction of points having a value bigger than every 
% integer from 0 to colorMax-1 (create histogram for threshold decision)
for i = 0:colorMax-1
    n_RMS(1, i+1) = sum(myRMS(:) > i)/nPix;
    n_MIP(1, i+1) = sum(myMIP(:) > i)/nPix;
end

if display_flag
    % Create histogram for threshold decision
    figure
    hold on
    plot(n_RMS, '.-');
    plot(n_MIP, '.-');
    xlabel('X');
    ylabel('Fraction above X');
    legend('RMS', 'MIP');
    title('Fraction of points having a value above X');

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

elseif not(isempty(th_RMS)) && not(isempty(th_MIP))
    m = (myRMS > th_RMS) & (myMIP > th_MIP);
end


% Modify mask to crop the image in every dimension if max and min values
% are given
if imDim == 1
    % Crop the image in x direction if max and min values are given
    if not(isempty(x_min)) && not(isempty(x_max))
        m(1:x_min, 1)   = false;
        m(x_max:end, 1) = false;
    end
end
if imDim == 2
    % Crop the image in x direction if max and min values are given
    if not(isempty(x_min)) && not(isempty(x_max))
        m(1:x_min, :)   = false;
        m(x_max:end, :) = false;
    end
    % Crop the image in y direction if max and min values are given
    if not(isempty(y_min)) && not(isempty(y_max))
        m(:, 1:y_min)   = false;
        m(:, y_max:end) = false;
    end
end
if imDim == 3
    % Crop the image in x direction if max and min values are given
    if not(isempty(x_min)) && not(isempty(x_max)) 
        if x_min > 1
            m(1:x_min-1,   :, :)  = false;
        end
        if x_max < N_u(1, 1)
            m(x_max+1:end, :, :)  = false;
        end
    end
    % Crop the image in y direction if max and min values are given
    if not(isempty(y_min)) && not(isempty(y_max)) 
        if y_min > 1
            m(:, 1:y_min-1,   :)  = false;
        end
        if y_max < N_u(1, 2)
            m(:, y_max:end, :)  = false;
        end
    end
    % Crop the image in z direction if max and min values are given
    if not(isempty(z_min)) && not(isempty(z_max)) 
        if z_min > 1
            m(:, :, 1:z_min)    = false;
        end
        if z_max < N_u(1, 3)
            m(:, :, z_max:end)  = false;
        end
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
    if display_flag
        bmImage(temp_im)
    end
end

% Prepare mask for output
m = bmBlockReshape(m, N_u);

end

