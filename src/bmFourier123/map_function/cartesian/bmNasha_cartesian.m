% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function x = bmNasha_cartesian(y, N_u, dK_u, varargin)

% argin_initial -----------------------------------------------------------
C = bmVarargin(varargin);

N_u     = double(N_u(:)');
imDim   = size(N_u(:), 1);

F_inv       = single(  prod(  single(N_u(:))  )*prod(  single(dK_u(:))  )); 

y       = bmColReshape(y, N_u); 
nCh     = size(y, 2);

C_flag = false;
if not(isempty(C))
    C_flag = true;
    C = single(C); 
end

private_check(y, N_u);
% END_argin_initial -------------------------------------------------------

% fft
x = reshape(y, [N_u, nCh]);
for n = 1:3
    if imDim > (n-1)
        x = fftshift(ifft(ifftshift(x, n), [], n), n);
    end
end
x = reshape(x, [prod(N_u(:)), nCh]);

x = x*F_inv; 

% eventual coil_combine
if C_flag
   x = bmCoilSense_pinv(C, x, N_u);   
end

x = bmBlockReshape(x, N_u); 

end


function private_check(y, N_u)

if not(strcmp(class(y), 'single'))
    error('The data''y'' must be of class single');
    return; 
end
if size(y, 2) > size(y, 1)
    error('The data matrix ''y'' is probably not in the correct size');
    return;
end
if sum(mod(N_u(:), 2)) > 0
    error('N_u must have all components even for the Fourier transform. ');
    return;
end

end