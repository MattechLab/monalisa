function varargout = bmImage(argImage, varargin)
% varargout = bmImage(argImage, varargin)
%
% This function creates an interactive figure displaying data from a 2D,
% 3D, 4D or 5D array. If the data is complex, the absolute value will be
% used.
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
%   argImage (array): Contains the data to be displayed as an image.
%   varargin{1}: Object of class bmImageViewerParam, giving the parameters
%    for the image.
%
% Returns:
%   varargout{1}: Object of class bmImageViewerParam that was used in the
%    creation of the figure and containing the coordinates of placed
%    points.

% Extract optional arguments
argParam = bmVarargin(varargin); 
uiwait_flag = false; 

% Transform cell array to array
if iscell(argImage)
   argImage = squeeze(bmCell2Array(argImage)); 
end

% Turn complex values real
if not(isreal(argImage))
   argImage = abs(argImage);  
end

% Turn logical values to double for plotting
if islogical(argImage)
    argImage = double(argImage); 
end

% Create image for 2, 3, 4 or 5 dimensions
if ndims(argImage) == 2
    outParam = bmImage2(argImage, argParam, uiwait_flag);
elseif ndims(argImage) == 3
    outParam = bmImage3(argImage, argParam, uiwait_flag);
elseif ndims(argImage) == 4
    outParam = bmImage4(argImage, argParam, uiwait_flag);
elseif ndims(argImage) == 5
    outParam = bmImage5(argImage, argParam, uiwait_flag);
end

% Return image parameters if required
if nargout > 0
    varargout{1} = outParam; 
end

end