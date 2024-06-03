% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function t = bmTraj_exp1_lineAssym2(N_u, dK_u, arg_exponent)

N_u     = N_u(:)';
dK_u    = dK_u(:)';

lx = N_u(1, 1)*dK_u(1, 1); 

x = [-N_u(1, 1)/2:N_u(1, 1)/2 - 1]*dK_u(1, 1); 
x = x(:)'; 
x = (abs(x).^arg_exponent).*sign(x); 
x = N_u(1, 1)*dK_u(1, 1)*x/abs(x(1, 1))/2; 

t = x(:)'; 

end