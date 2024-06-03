% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmIsColShape(x, N_u)

nCh = size(x(:), 1)/prod(N_u(:));

myColSize = [prod(N_u(:)), nCh]; 
mySize = size(x); 

if isequal(mySize, myColSize)
    out = true; 
else
    out = false; 
end

end