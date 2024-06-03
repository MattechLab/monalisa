% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmIsBlockShape(x, N_u)

nCh = size(x(:), 1)/prod(N_u(:));

myBlockSize = [N_u, nCh]; 
mySize = size(x); 

if isequal(mySize, myBlockSize)
    out = true; 
else
    out = false; 
end

end