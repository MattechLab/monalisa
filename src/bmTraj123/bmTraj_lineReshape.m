% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [out, varargout] = bmTraj_lineReshape(t, varargin)

imDim = size(t, 1); 
[nLine, N, isN_integer] = bmTraj_nLine(t);

% check -------------------------------------------------------------------
if not(isN_integer)
    error('The size of traj is not convertible to [imDim, N, nLine]'); 
    return; 
else
% END_check ---------------------------------------------------------------

out = reshape(t, [imDim, N, nLine]); 

if length(varargin) > 0
   temp = varargin{1}; 
   nCh = size(temp, 1); 
   varargout{1} = reshape(temp, [nCh, N, nLine]);
end


end