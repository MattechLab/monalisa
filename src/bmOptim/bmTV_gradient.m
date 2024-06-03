% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function g = bmTV_gradient(x, N_u, dX_u)

imDim   = size(N_u(:), 1);
N_u     = N_u(:)'; 
dX_u    = dX_u(:)'; 
D_u     = prod(dX_u(:)); 


if imDim == 1
    
    g = zeros([N_u, 1], 'single');
    g = complex(g, g);
    
    x_real = reshape(real(x), [N_u, 1]);
    x_imag = reshape(imag(x), [N_u, 1]);
    


    myShift_1 = [1, 0]; 
    
    g_real = circshift(x_real, myShift_1);
    g_imag = circshift(x_imag, myShift_1);
    g_real = sign(x_real - g_real)/dX_u(1, 1);
    g_imag = sign(x_imag - g_imag)/dX_u(1, 1);
    g_real(1, 1) = 0; 
    g_imag(1, 1) = 0; 
    g_real = g_real - circshift(g_real, - myShift_1);
    g_imag = g_imag - circshift(g_imag, - myShift_1);
    g = g + complex(g_real, g_imag); 
    
    
elseif imDim == 2
    
    g = zeros(N_u, 'single');
    g = complex(g, g);
    
    x_real = reshape(real(x), N_u);
    x_imag = reshape(imag(x), N_u);
    

    
    myShift_1 = [1, 0];
    myShift_2 = [0, 1]; 
    
    g_real = circshift(x_real, myShift_1);
    g_imag = circshift(x_imag, myShift_1);
    g_real = sign(x_real - g_real)/dX_u(1, 1);
    g_imag = sign(x_imag - g_imag)/dX_u(1, 1);
    g_real(1, :) = 0; 
    g_imag(1, :) = 0; 
    g_real = g_real - circshift(g_real, - myShift_1);
    g_imag = g_imag - circshift(g_imag, - myShift_1);
    g = g + complex(g_real, g_imag); 
    
    
    g_real = circshift(x_real, myShift_2);
    g_imag = circshift(x_imag, myShift_2);
    g_real = sign(x_real - g_real)/dX_u(1, 2);
    g_imag = sign(x_imag - g_imag)/dX_u(1, 2);
    g_real(:, 1) = 0; 
    g_imag(:, 1) = 0;
    g_real = g_real - circshift(g_real, - myShift_2);
    g_imag = g_imag - circshift(g_imag, - myShift_2);
    g = g + complex(g_real, g_imag); 
    
    
elseif imDim == 3
    
    g = zeros(N_u, 'single');
    g = complex(g, g);
    
    x_real = reshape(real(x), N_u);
    x_imag = reshape(imag(x), N_u);
    

    
    
    myShift_1 = [1, 0, 0];
    myShift_2 = [0, 1, 0]; 
    myShift_3 = [0, 0, 1]; 
    
    g_real = circshift(x_real, myShift_1);
    g_imag = circshift(x_imag, myShift_1);
    g_real = sign(x_real - g_real)/dX_u(1, 1);
    g_imag = sign(x_imag - g_imag)/dX_u(1, 1);
    g_real(1, :, :) = 0; 
    g_imag(1, :, :) = 0;
    g_real = g_real - circshift(g_real, - myShift_1);
    g_imag = g_imag - circshift(g_imag, - myShift_1);
    g = g + complex(g_real, g_imag); 
    
    
    g_real = circshift(x_real, myShift_2);
    g_imag = circshift(x_imag, myShift_2);
    g_real = sign(x_real - g_real)/dX_u(1, 2);
    g_imag = sign(x_imag - g_imag)/dX_u(1, 2);
    g_real(:, 1, :) = 0; 
    g_imag(:, 1, :) = 0;
    g_real = g_real - circshift(g_real, - myShift_2);
    g_imag = g_imag - circshift(g_imag, - myShift_2);
    g = g + complex(g_real, g_imag); 
    
    g_real = circshift(x_real, myShift_3);
    g_imag = circshift(x_imag, myShift_3);
    g_real = sign(x_real - g_real)/dX_u(1, 3);
    g_imag = sign(x_imag - g_imag)/dX_u(1, 3);
    g_real(:, :, 1) = 0; 
    g_imag(:, :, 1) = 0;
    g_real = g_real - circshift(g_real, - myShift_3);
    g_imag = g_imag - circshift(g_imag, - myShift_3);
    g = g + complex(g_real, g_imag); 
    
end

g = g*D_u; 
g = reshape(g, [prod(N_u(:)), 1]); 

end