% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function myTraj = bmTraj_cartesian1_lineAssym2(varargin)

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

x = (-N_u(1, 1)/2:N_u(1, 1)/2 - 1)*dK_u(1, 1); 
myTraj = x(:)'; 

end