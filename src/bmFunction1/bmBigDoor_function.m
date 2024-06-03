% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function f = bmBigDoor_function(x, L, a)

f = zeros(size(x)); 

m = (  (x-a) >=  -L/2); 
f(m) = 1;

m = (  (x-a) >= L/2  ); 
f(m) = 0; 

end