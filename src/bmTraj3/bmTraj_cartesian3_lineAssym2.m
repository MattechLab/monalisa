% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% This trajectory is 3Dim cartesian. 

function myTraj = bmTraj_cartesian3_lineAssym2(varargin)

if isa(varargin{1}, 'bmTrajInfo')
    t_info  = varargin{1}; 
    N_u     = t_info.N_u; 
    dK_u    = t_info.dK_u;
else
   N_u      = varargin{1}; 
   dK_u     = varargin{2}; 
end

N_u     = N_u(:)'; 
dK_u    = dK_u(:)'; 

x = [-N_u(1, 1)/2:N_u(1, 1)/2 - 1]*dK_u(1, 1); 
y = [-N_u(1, 2)/2:N_u(1, 2)/2 - 1]*dK_u(1, 2); 
z = [-N_u(1, 3)/2:N_u(1, 3)/2 - 1]*dK_u(1, 3); 

[x, y, z] = ndgrid(x, y, z); 
myTraj    = cat(1, x(:)', y(:)', z(:)'); 

end