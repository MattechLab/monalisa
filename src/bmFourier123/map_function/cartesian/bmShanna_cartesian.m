% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function y = bmShanna_cartesian(x, N_u, dK_u, varargin)

% argin_initial -----------------------------------------------------------
x       = bmColReshape(x, N_u); 
N_u     = double(N_u(:)'); 
imDim   = size(N_u(:), 1);
nCh     = size(x, 2);
 
F       = single(1/prod(  single(N_u(:))  )/prod(  single(dK_u(:))  )); 

C = bmVarargin(varargin);
C_flag = false;
if not(isempty(C))
    C_flag = true;
    nCh = size(C, 2); 
    C = single(C); 
end

private_check(x, N_u); 
% END_argin_initial -------------------------------------------------------

% coil decombine
if C_flag
   x = C.*repmat(x, [1, nCh]);  
end


% fft
y = reshape(x, [N_u, nCh]);
for n = 1:3
    if imDim > (n-1)
        y = fftshift(fft(ifftshift(y, n), [], n), n);
    end
end
y = reshape(y, [prod(N_u(:)), nCh]);

y = y*F; 

end




function private_check(x, N_u)

if not(strcmp(class(x), 'single'))
    error('The data''x'' must be of class single');
    return; 
end

if size(x, 2) > size(x, 1)
    error('The data matrix ''x'' is probably not in the correct size');
    return;
end

if sum(mod(N_u(:), 2)) > 0
    error('N_u must have all components even for the Fourier transform. ');
    return;
end


end