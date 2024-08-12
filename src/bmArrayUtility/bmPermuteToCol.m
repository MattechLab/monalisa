function out = bmPermuteToCol(y, varargin)
% out = bmPermuteToCol(y, varargin)
%
% This function permutes an array or a cell array containing data such that
% the data is contained in the column. Each column represents the data of a
% channel. A cell array is returned as such with the arrays contained in
% each cell being reshaped to the column format.
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Parameters:
%   y: Array or cell array containing the data that has to be permuted into
%    column format.
%   varargin (optional): Can contain a scalar or an array giving the number
%    of rows that the permuted data should have. This is enforced and can
%    lead to errors if y can't be reshaped to follow the given size. If an
%    array is given, the entries are multiplied to transform it into a
%    scalar.
%
% Returns:
%   out: Array or cell array (depending on y) containing the data permuted
%    into column format.
%
% Examples:
%   Cell array
%       y = {
%           [1, 2, 3; 4, 5, 6], ...
%           [7, 8; 9, 10; 11, 12], ...
%           {[13, 14; 15, 16]}
%       };
%       out = bmPermuteToCol(y, 2);
%
%   Outputs out with cells permuted to
%       Cell 1:
%           1     4     2
%           5     3     6
% 
%       Cell 2:
%           7     9    11
%           8    10    12
% 
%       Cell 3:
%           {2×2 double}
%           (13    15
%            14    16)
%
%   Array
%       y = [1, 2, 3; 4, 5, 6];
%       out = bmPermuteToCol(y);
%
%   Outputs out permuted to
%       out:
%           1     4
%           2     5
%           3     6

% Read size if given as argument
argSize = bmVarargin(varargin); 

out = [];
% Work recursively if y is a cell array
if iscell(y)  
    out  = cell(size(y));
    for i = 1:size(y(:), 1)
        out{i} = bmPermuteToCol(y{i}, argSize);
    end
    return;
end

% Return empty array if y is empty
if isempty(y) 
   out = []; 
   return; 
end

% Read size from y if not given as varargin
if isempty(argSize) 
    nCh = size(y, 1); 
    nPt = size(y(:), 1)/nCh; 
else
    % Multiply values in argSize to transform it if it is a list
    nPt     = prod(argSize(:)); 
    nCh     = size(y(:), 1)/nPt; 
end

% Reshape y to have each row containing data of a channel
y       = reshape(y, [nCh, nPt]); 

% Transpose y to have each column containing data of a channel
out     = y.'; 

end