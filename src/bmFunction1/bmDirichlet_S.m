% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function f = bmDirichlet_S(N_over_2, dk, x)

f = dk*bmDirichletKernel(2*pi*dk*x, N_over_2); 

end