% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function x = bmGut_partialCartesian(y, ind_u, N_u)

N_u     = double(N_u(:)'); 
ind_u   = double(ind_u(:));

nCh = size(y, 2);
nPt = size(y(:), 1)/nCh; 

y       = bmColReshape(y, nPt); 

x = zeros(prod(N_u(:)), nCh, 'single'); 
if not(isreal(y))
   x = complex(x, x);  
end

for i = 1:nCh
    x(ind_u, i) = y(:, i);
end

end