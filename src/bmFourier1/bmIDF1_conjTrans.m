% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023


function x_out = bmIDF1_conjTrans(x, N_u, dK_u)

argSize = size(x); 
x = bmBlockReshape(x, N_u);

n = 1; 
x = fftshift(fft(ifftshift(x, n), [], n), n);

F = single(  prod(dK_u(:))  ); 
x = x*F; 

x_out = reshape(x, argSize);

end