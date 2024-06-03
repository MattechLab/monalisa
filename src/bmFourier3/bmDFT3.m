% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function Fx = bmDFT3(x, N_u, dK_u)

argSize = size(x); 
x = bmBlockReshape(x, N_u);

n = 1; 
x = fftshift(fft(ifftshift(x, n), [], n), n);
n = 2; 
x = fftshift(fft(ifftshift(x, n), [], n), n);
n = 3; 
x = fftshift(fft(ifftshift(x, n), [], n), n);

F = prod(N_u(:))*prod(dK_u(:)); 
x = x/F; 

Fx = reshape(x, argSize);

end