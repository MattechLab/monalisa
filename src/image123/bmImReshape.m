function [outIm, imDim, imSize, varargout] = bmImReshape(argIm)
% [outIm, imDim, imSize, varargout] = bmImReshape(argIm)
%
% This function returns the number of dimensions and size of the input 
% array. Can optionally return the x, y and z size, which are the size of 
% the first three dimensions of the input array. If the input array is a
% vector (1D), the returned array is a column vector.
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
%   argIm (array): The array of which the dimension and size should be
%    returned. Cannot be empty.
%
% Returns:
%   outIm (array): Same as argIm except if argIm is 1D, then the outIm is
%   reshaped to a column vector.
%   imDim (int): The number of dimensions.
%   imSize (list): The size of each dimension as a list.
%   varargout{1}: Integer containing the size of the first dimension.
%   varargout{1}: Integer containing the size of the second dimension. 
%   Empty if imDim < 2
%   varargout{1}: Integer containing the size of the third dimension. 
%   Empty if imDim < 3

% Get number of dimensions of the input
outIm = argIm; 
imDim = bmImDim(argIm); 

% Throw an error if argIm is empty
if imDim == 0 
   error('The image dimension is 0. '); 
   return; 
end

% Turn input into column vector if input is a vector
if imDim == 1 
   outIm = outIm(:); 
end

% Get sizes of the first three dimensions
[imDim, imSize, s1, s2, s3] = bmImDim(outIm); 

% Return if required
if nargout > 3
    varargout{1} = s1; 
end
if nargout > 4
    varargout{2} = s2; 
end
if nargout > 5
    varargout{3} = s3; 
end

end