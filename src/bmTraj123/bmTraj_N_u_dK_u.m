% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [N_u, dK_u] = bmTraj_N_u_dK_u(t, varargin)

t = bmPointReshape(t); 
imDim = size(t, 1); 

N_u = []; 
if length(varargin) > 0
   N_u = varargin{1};  
end
if isempty(N_u)
   N_u = bmTraj_N_u(t);  
end

dK_u = []; 
if length(varargin) > 1
   dK_u = varargin{2};  
end
if isempty(dK_u)
   dK_u = bmTraj_dK_u(t, N_u);  
end


end