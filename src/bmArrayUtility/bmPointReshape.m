function out = bmPointReshape(t, varargin)
% out = bmPointReshape(t, varargin)
%
% Reshapes the array or cell array given to express the points in
% their dimensions -> 2D array of shape [nCh, nPt]
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
%   t (array or cell array): Contains the points (ex. of a trajectory) and
%    should be reshaped
%   varargin{1}: Gives the number of dimensions the points should have
%
% Returns:
%   out (array or cell array): Contains the reshaped array
%
% Examples:
%   t = bmPointReshape(trajectory)
%   t = bmPointReshape(...
%         bmTraj_fullRadial3_phyllotaxis_lineAssym2(myMriAcquisition_node))

argSize = bmVarargin(varargin); 

% Work recursively if t is a cell array
if iscell(t)
    out  = cell(size(t));
    for i = 1:size(t(:), 1)
        out{i} = bmPointReshape(t{i}, argSize);
    end
    return;
end

% If t is a 1D array row (1,x) or column (x,1), return it as a row
if ndims(t) == 2
    if (size(t, 1) == 1) || (size(t, 2) == 1)
        out = t(:).';
        return;
    end
end

argSize = bmVarargin(varargin); 
argSize = argSize(:)'; 

% If size isn't given, read the dimensions of t (ex. coordinates or channels)
if isempty(argSize)
   nCh = size(t, 1);
else
    nCh =  argSize(1, 1); 
end

% Calculate number of points (all entries devided by nCh)
nPt = size(t(:), 1)/nCh; 
% Reshape t to be nCh x nPt -> 2D array containing points expressed in
% dimensions
out = reshape(t, [nCh, nPt]);

end