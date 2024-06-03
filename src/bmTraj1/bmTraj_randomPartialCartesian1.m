% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023


function t = bmTraj_randomPartialCartesian1(N_u, dK_u, perOne)

t = [-N_u/2 : N_u/2-1]*dK_u; 
m = (rand(1, N_u) < perOne); 
t = t(m(:));
t = t(:)'; 


end