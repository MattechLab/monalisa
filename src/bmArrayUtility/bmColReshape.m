function out = bmColReshape(argIn, argSize)
% out = bmColReshape(argIn, argSize)
%
% This function reshapes the data into column vectors, with each vector
% containing data of one channel. The data can be given in an array or cell
% array. In case of a cell array, the arrays in each cell are reshaped.
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
%   argIn (array / cell array): Data that should be reshaped.
%   argSize (list): Size of the data of one channel. Used to calculate the
%   number of channels.
%
% Results:
%   out (array / cell array): The data reshaped into column vectors. The
%   type depends on the input.


% Work recursively if argIn is a cell array
if iscell(argIn) 
    out  = cell(size(argIn));
    for i = 1:size(argIn(:), 1)
        out{i} = bmColReshape(argIn{i}, argSize);
    end
    return;
end

% Calculate number of points per channel
nPt = prod(argSize(:)); 

% Get number of channels
nCh = size(argIn(:), 1)/nPt; 

% Reshape data into column vectors, each vector containing data of one 
% channel
out = reshape(argIn, [nPt, nCh]); 

end