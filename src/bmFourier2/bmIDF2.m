% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function iFx = bmIDF2(x, N_u, dK_u)

argSize = size(x); 
x = bmBlockReshape(x, N_u);

n = 1; 
x = fftshift(ifft(ifftshift(x, n), [], n), n);
n = 2; 
x = fftshift(ifft(ifftshift(x, n), [], n), n);

F = prod(N_u(:))*prod(dK_u(:)); 
x = x * F; 
iFx = reshape(x, argSize);

end