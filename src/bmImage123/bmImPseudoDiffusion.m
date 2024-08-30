function myIm = bmImPseudoDiffusion(argIm, varargin)
% myIm = bmImPseudoDiffusion(argIm, varargin)
%
% This function performes smoothing on data by averaging the data over its
% direct neighbors (not diagonal), by diffusing the data. The edge cases 
% take as neighbors the edges on the other side as a circular shift is 
% used. This function can be applied to 1D, 2D and 3D data.
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
%   varargin{1}: Integer containing the number of iterations of averaging
%    applied to smooth the data. The default value is 1.
%
% Returns:
%   myIm (data): The data smoothed.

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
    % Initialize temporary array
    temp_im             = zeros(imSize, 'single');

    for j = 1:nShift
        % Sum data of direct neighbors (not diagonal) to data, edges wrap 
        % around (circular)
        temp_im = temp_im + circshift(myIm, myShiftList(j, :));  
    end

    % Devide the sum by the number of neigbors (average)
    myIm = temp_im./(imDim*2+1);
end

% Return to original size for data
myIm              = reshape(myIm, size(argIm));

end