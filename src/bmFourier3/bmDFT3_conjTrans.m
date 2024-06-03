% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function x_out = bmDFT3_conjTrans(x, N_u, dK_u)

argSize = size(x); 
x = bmBlockReshape(x, N_u);

n = 1; 
x = fftshift(ifft(ifftshift(x, n), [], n), n);
n = 2; 
x = fftshift(ifft(ifftshift(x, n), [], n), n);
n = 3; 
x = fftshift(ifft(ifftshift(x, n), [], n), n);

F_conj  = single(prod(  single(dK_u(:))  )); 
x = x/F_conj; 

x_out = reshape(x, argSize);

end