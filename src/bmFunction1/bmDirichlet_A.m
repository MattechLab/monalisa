% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% Note: 'dk' can be replaced by 'dx' 
% and   'x'  can be replaced by 'k'. 

function f = bmDirichlet_A(N_over_2, dk, x)

k_max   = 2*N_over_2*dk; 
f       = dk*bmDirichletKernel(2*pi*dk*x, N_over_2) - dk*exp(1i*2*pi*k_max*x); 

end