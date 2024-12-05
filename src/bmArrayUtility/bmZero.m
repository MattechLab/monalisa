function z = bmZero(argSize, argType, varargin)
% z = bmZero(argSize, argType, varargin)
%
% This function creates a zero array of a given size and given type. Can
% also create a cell array containing zero arrays of the given size.
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
%   argSize (list): The size of the zero array.
%   argType (char): The type of the zero array. Can be 'real_double',
%   'real_single', 'complex_double' and 'complex_single'.
%   varargin{1}: List containing the size of the cell array if the
%   result should be a cell array.

% Extract optional arguments
frame_size = bmVarargin(varargin); 

if ~isempty(frame_size)
    % Create cell array
    z = cell(frame_size);
    z = z(:);
    for i = 1:size(z(:), 1)
        % Create zero array in every cell
        z{i} = bmZero(argSize, argType);
    end
    z = reshape(z, frame_size);
    return;
end

z = []; 
% Create zero array of different types
if strcmp(argType, 'real_double')
    z = zeros(argSize, 'double'); 
elseif strcmp(argType, 'complex_double')
    z = complex(zeros(argSize, 'double'), zeros(argSize, 'double'));
elseif strcmp(argType, 'real_single')
    z = zeros(argSize, 'single'); 
elseif strcmp(argType, 'complex_single')
    z = complex(zeros(argSize, 'single'), zeros(argSize, 'single'));
end

end