% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function y = bmShanna_MATLAB(x, G, KFC, n_u)

% argin_initial -----------------------------------------------------------
if isempty(n_u)
   n_u = N_u;  
end

N_u         = double(int32(G.N_u(:)'));
n_u         = double(int32(n_u(:)'));
imDim       = size(N_u(:), 1);
x_size_2    = size(x, 2);

if (size(x, 2) == 1)
    nCh = size(KFC, 2);
else
    nCh = size(x, 2);
end

private_check(x, G, KFC, N_u, n_u, nCh);
% END_argin_initial -------------------------------------------------------


% eventual channel extension
if x_size_2 < nCh
    x = repmat(x, [1, nCh]);
end

%deapotization and coil decombine
x = x.*KFC;

% eventual zero_filling
if ~isequal(N_u, n_u)
   x = bmBlockReshape(x, n_u);    
   x = bmImZeroFill(x, N_u, n_u, 'complex_single'); 
   x = bmColReshape(x, N_u); 
end


% fft
x = bmBlockReshape(x, N_u);
for n = 1:3
    if imDim > (n-1)
        x = fftshift(fft(ifftshift(x, n), [], n), n);
    end
end
x = bmColReshape(x, N_u);

% gridding
y = bmSparseMat_vec(G, x, 'omp', 'complex', false);

end




function private_check(x, G, KFC, N_u, n_u, nCh)

if not(isa(x, 'single'))
    error('The data''x'' must be of class single');
    return;
end

if not(isa(KFC, 'single'))
    error('The matrix ''KFC'' must be of class single');
    return;
end

if not(size(x, 1) == prod(n_u(:)))
    error('The data matrix ''x'' is not in the correct size');
    return;
end


if not(isequal(size(KFC), [prod(n_u(:)), nCh] ))
    error('The matrix ''K'' is probably not in the correct size');
    return;
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