function myIm = bmImPseudoDiffusion_inMask(argIm, argMask, varargin)
% myIm = bmImPseudoDiffusion_inMask(argIm, argMask, varargin)
%
% This function performes smoothing on data by averaging the data over its
% direct neighbors (not diagonal), by diffusing the data. The edge cases 
% take as neighbors the edges on the other side as a circular shift is 
% used. This operation is constraint to only modify and consider the 
% unmasked data (where argMask is 1) and can be applied to 1D, 2D and 3D 
% data.
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
%   argIm (array): The data that should be diffused.
%   argMask (array): Of the same size as argIm and masks the regions with 0
%    that should not be modified and considered in the smoothing.
%   varargin{1}: Integer containing the number of iterations of averaging
%    applied to smooth the data. The default value is 1.
%
% Returns:
%   myIm (data): The data smoothed at the unmasked points and the original
%    data at the masked points.

%% Initialize arguments
% Extract optional argument
nIter = bmVarargin(varargin); 

% Set default value for number of iterations if empty
if isempty(nIter)
   nIter = 1;  
end

% Get dimension and size of input data (also get data as column vector if 
% argIm is 1D)
[myIm, imDim, imSize] = bmImReshape(single(squeeze(argIm))); 

% Match mask and data size and create negative mask (to mask data)
myMask = reshape(logical(argMask), imSize); 
myMask_neg = not(myMask);


% Create shift list used to access all neighbors and the original datapoint
% with a circular shift.
if imDim == 1
    
   myShiftList = [    0; 
                      1; 
                     -1; 
                                ]; 
                            
elseif imDim == 2
    
   myShiftList = [   0,  0; 
                     0,  1; 
                     0, -1; 
                     1,  0; 
                    -1,  0; 
                                ];  
elseif imDim == 3
    
    myShiftList = [   0,   0,  0; 
                      0,   0,  1; 
                      0,   0, -1;
                      0,   1,  0;
                      0,  -1,  0;
                      1,   0,  0;
                     -1,   0,  0;
                                    ]; 
end


%% Do smoothing
% Get number of shifts = number of direct neighbors (not diagonal)
nShift = size(myShiftList, 1); 
for i = 1:nIter    
    % Set masked parts (of original mask) to 0 
    myIm(myMask_neg)    = 0; 

    % Initialize temporary arrays
    temp_im             = zeros(imSize, 'single'); 
    myNumOfNeighb       = zeros(imSize, 'single');
    
    for j = 1:nShift
        % Sum data of direct neighbors (not diagonal) to data, edges wrap 
        % around (circular)
        temp_im = temp_im + circshift(myIm, myShiftList(j, :));

        % Sum mask to get the number of valid neighbors (not masked) that 
        % are summed on top of the data
        myNumOfNeighb = myNumOfNeighb + single(circshift(myMask, myShiftList(j, :))); 
    end

    % Set zeros to one to not devide by 0
    myNumOfNeighb(myNumOfNeighb == 0) = 1; 

    % Devide the sum by the number of valid data points 
    % -> averaging over direct neighbors (not diagonal)
    myIm = temp_im./myNumOfNeighb; 
end

% Return to original size for data and mask
myIm              = reshape(myIm, size(argIm)); 
myMask_neg        = reshape(myMask_neg, size(argIm)); 

% Get original data (not modified) for masked points
myIm(myMask_neg)  = argIm(myMask_neg); 

end