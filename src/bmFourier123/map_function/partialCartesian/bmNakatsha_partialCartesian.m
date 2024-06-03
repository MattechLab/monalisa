% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function x = bmNakatsha_partialCartesian(y, ind_u, FC_conj, N_u, n_u, dK_u)

% argin_initial -----------------------------------------------------------
C_flag = false;
if isempty(FC_conj)
    FC_conj = single(1/prod(single(dK_u(:))));
    C_flag = false;
else
    C_flag = true;
end

if isempty(n_u)
   n_u = N_u;  
end

N_u     = double(int32(N_u(:)'));
n_u     = double(int32(n_u(:)'));
nPt     = size(y, 1); 
nCh     = size(y, 2);
imDim   = size(N_u(:), 1);

private_check(y, FC_conj, N_u, n_u, nPt, nCh, C_flag);
% END_argin_initial -------------------------------------------------------

% gridding
x = bmGut_partialCartesian(y, ind_u, N_u);

% fft
x = bmBlockReshape(x, N_u);
for n = 1:3
    if imDim > (n-1)
        x = fftshift(ifft(ifftshift(x, n), [], n), n);
    end
end
x = bmColReshape(x, N_u);

% eventual crope
if ~isequal(N_u, n_u)
    x = bmBlockReshape(x, N_u); 
    x = bmImCrope(x, N_u, n_u); 
    x = bmColReshape(x, n_u); 
end

% Fourier_factor and coil_combine
x = x.*FC_conj; 

if C_flag
    x = sum(x, 2);
end

end




function private_check(y, FC_conj, N_u, n_u, nPt, nCh, C_flag)

if not(isa(y, 'single'))
    error('The data''y'' must be of class single');
    return; 
end

if not(isa(FC_conj, 'single'))
    error('The matrix ''FC_conj'' must be of class single');
    return;
end





if not(isequal(size(y), [nPt, nCh]))
    error('The data matrix ''y'' is not in the correct size');
    return;
end

if C_flag
    if not(isequal(size(FC_conj), [prod(n_u(:)), nCh] ))
        error('The matrix ''C'' is not in the correct size');
        return;
    end
end






if sum(mod(N_u(:), 2)) > 0
    error('N_u must have all components even for the Fourier transform. ');
    return;
end

if sum(mod(n_u(:), 2)) > 0
    error('n_u must have all components even for the Fourier transform. ');
    return;
end

end