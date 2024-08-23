function out = bmBlockReshape(argIn, N_u)
% out = bmBlockReshape(argIn, N_u)
%
% This function reshapes the input array argIn (or cell array) to have all
% arrays of size [N_u, nCh], which is of the same dimension as N_u if argIn
% has the same amount of elements as an array defined by the size N_u 
% (nCh = 1) or + 1 if not.
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
%   argIn (array): The data that should be reshaped into block from.
%   N_u (list): Contains the size for the blocks (same for all).
%
% Returns:
%   out (array): Contains the reshaped array, where the data is seperated
%    into nCh blocks of size N_u. The size is [N_u, nCh], which is [N_u] if
%    prod(N_u) equals the elements in argIn. nCh is the number of blocks 
%    and of dim 1. Empty if argIn is empty.
%
% Examples:
%   out = bmBlockReshape((1:884736), [96, 96, 96]);
%    size(out): [96, 96, 96]
%   out = bmBlockReshape((1:884736), [48, 48, 48]);
%    size(out): [48, 48, 48, 8]

% Work recursively if argIn is a cell array
if iscell(argIn)
    out  = cell(size(argIn));
    for i = 1:size(argIn(:), 1)
        out{i} = bmBlockReshape(argIn{i}, N_u);
    end
    return;
end

% Return empty array if argIn is empty
if isempty(argIn)
   out = []; 
   return; 
end

% Have N_u as row vector
N_u = N_u(:)'; 

% Get channels nElements / nGridPoints
nCh = size(argIn(:), 1)/prod(N_u(:)); 

% Reshape to [N_u, nCh], 3D if nCh = 1 4D otherwise
out = reshape(argIn, [N_u, nCh]); 

end