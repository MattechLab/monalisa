% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function y = bmGu_partialCartesian(x, ind_u, N_u)

N_u     = double(N_u(:)'); 
ind_u   = double(ind_u(:));

x = bmColReshape(x, N_u); 
y = x(ind_u, :); 

end