% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function x = bmNakatsha_MATLAB(y, G, KFC_conj, C_flag, n_u)

% argin_initial -----------------------------------------------------------

if isempty(C_flag)
   C_flag = false;  
end

if isempty(n_u)
   n_u = N_u;  
end

N_u     = double(int32(G.N_u(:)'));
n_u     = double(int32(n_u(:)'));
nPt     = double(G.r_size); 
imDim   = size(N_u(:), 1);
nCh     = size(y, 2);





private_check(y, G, KFC_conj, N_u, n_u, nCh, nPt, C_flag);
% END_argin_initial -------------------------------------------------------

% gridding
x = bmSparseMat_vec(G, y, 'omp', 'complex', false);

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

% deapotization and coil_combine
x = x.*KFC_conj; 

% eventual channel reduction
if C_flag
    x = sum(x, 2);
end

end




function private_check(y, G, KFC_conj, N_u, n_u, nCh, nPt, C_flag)

if not(isa(y, 'single'))
    error('The data''y'' must be of class single');
    return; 
end

if not(isa(KFC_conj, 'single'))
    error('The matrix ''KFC_conj'' must be of class single');
    return;
end




if not(isequal(size(y), [nPt, nCh]))
    error('The data matrix ''y'' is not in the correct size');
    return;
end

if C_flag
    if not(isequal(size(KFC_conj), [prod(n_u(:)), nCh] ))
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

if not(strcmp(G.block_type, 'one_block'))
    error('The block type of G must be ''one_block''. ');
    return;
end

if strcmp(class(G), 'bmSparseMat')
    if not(strcmp(G.type, 'cpp_prepared')) && not(strcmp(G.type, 'l_squeezed_cpp_prepared'))
        error('G is bmSparseMat but is not cpp_prepared. ');
        return;
    end
end

end