function [out, varargout] = bmTraj_lineReshape(t, varargin)
% [out, varargout] = bmTraj_lineReshape(t, varargin)
%
% This function transforms a trajectory to be defined in lines (if
% possible)
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Parameters:
%   t (array): The trajectory to be changed
%   varargin{1}: Trajectory to be reshaped in the same way as t (except for
%   the dimension, which is taken from varargin{1})
%
% Returns:
%   out (array): The changed trajectory
%   varargout{1}: The second trajectory to be changed (if varargin is
%   given)

imDim = size(t, 1); 
[nLine, N, isN_integer] = bmTraj_nLine(t);

% check -------------------------------------------------------------------
if not(isN_integer)
    error('The size of traj is not convertible to [imDim, N, nLine]'); 
    return; 
else
% END_check ---------------------------------------------------------------

% Reshape trajectory to be defined in lines
out = reshape(t, [imDim, N, nLine]); 

if length(varargin) > 0
   temp = varargin{1}; 
   nCh = size(temp, 1); 
   varargout{1} = reshape(temp, [nCh, N, nLine]);
end


end