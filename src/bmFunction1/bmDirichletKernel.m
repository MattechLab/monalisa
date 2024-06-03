% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function f = bmDirichletKernel(x, N)

myEps = 1e-4; 

f       = sin(  (N+1/2)*x  )./sin(  x/2  ); 
m       = isinf(f) | not(isnumeric(f)) | isnan(f) | (abs(sin(x/2)) < myEps); 
f(m)    = 2*N+1; 

end

