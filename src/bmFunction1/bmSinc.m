% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function f = bmSinc(x)

myEps = 1e-4; 

f = sin(x)./x; 

m = isnan(f) | isinf(f) | not(isnumeric(f)) | (x == 0) | (  abs(x) < myEps  ); 
f(m) = 1; 

end