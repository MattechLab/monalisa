function [N_u, dK_u] = bmTraj_N_u_dK_u(t, varargin)
% [N_u, dK_u] = bmTraj_N_u_dK_u(t, varargin)
%
% Determines the Cartesian grid size N_u and the step size dK_u 
% for gridding reconstruction based on the sampling trajectory t.
% 
% This is only used if N_u, dK_u are not explicitly provided in the input, 
% they are used. Otherwise, these parameters are automatically estimated 
% from the trajectory t.
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Contributor:
%   Mauro Leidi (Documentation)
%   HES-SO
%   Lausanne - Switzerland
%   May 2025
%
% Parameters:
%   t (array): The sampling trajectory coordinates
%   varargin: Optional parameters, structured as:
%       N_u (vector): User-defined Cartesian grid size
%       dK_u (scalar or vector): User-defined Cartesian grid step size
%
% Returns:
%   N_u (vector): Size of the Cartesian grid
%   dK_u (scalar or vector): Step size of the Cartesian grid

t = bmPointReshape(t); 
imDim = size(t, 1); 

N_u = []; 
if ~isempty(varargin)
   N_u = varargin{1};  
end
if isempty(N_u)
   warning(['N_u is automatically determined. ' ...
       'You probably want to explicitly pass it as argument instead'])
   N_u = bmTraj_N_u(t);  
end

dK_u = []; 
if length(varargin) > 1
   dK_u = varargin{2};  
end
if isempty(dK_u)
   warning(['dK_u is automatically determined. ' ...
       'You probably want to explicitly pass it as argument instead'])
   dK_u = bmTraj_dK_u(t, N_u);  
end


end