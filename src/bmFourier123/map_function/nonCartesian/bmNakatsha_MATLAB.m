function x = bmNakatsha_MATLAB(y, G, KFC_conj, C_flag, n_u)
% x = bmNakatsha_MATLAB(y, G, KFC_conj, C_flag, n_u)
%
% This function copmutes the conjugate transpose of the Fourier transform
% and the coil sensitvity of Y -> C*F*(Y) while gridding the points to the
% uniform grid.
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Contributors:
%   Dominik Helbing (Documentation & Comments)
%   MattechLab 2024
%
% Parameters:
%   y (array): The data in the k-space to be gridded and transformed into
%   the image space.
%   G (bmSparseMat): The backward gridding sparse matrix which is used for
%   transposing the conjugate. -> Gut
%   KFC_conj (array): The kernel matrix used for deapodization multiplied
%   with the conjugate Fourier factor and the conjugate transpose of the
%   coil sensitivity. Can be missing the conjugate transpose of C.
%   C_flag (logical): Indicates if KFC_conj contains the conjugate of C. If
%   false, the conjugate is not included in KFC_conj.
%   n_u (list): The size of the image space grid.
%
% Returns:
%   x (array): The computed image space data (C*F*y = x). Combined into one
%   image x if C_flag is true, otherwise x has an image for every coil.
%
% Notes:
%   This comes from F(Cx) = y -> x = F*(C*y). If the coil sensitivity is
%   not given in KFC_conj, then only y -> F*(y) = x is computed. The data
%   needs to be multiplied by the volume elements for correct results.
%
% Examples:
%   x = bmNakatsha_MATLAB(y, Gut, KFC_conj, C_flag, n_u);

%% Initialize arguments
% Set default value if empty
if isempty(C_flag) 
    C_flag = false;  
end

% Use G.N_u if n_u is empty
if isempty(n_u) 
    n_u = G.N_u;  
end

% Convert variables to the correct format
N_u     = double(int32(G.N_u(:)'));
n_u     = double(int32(n_u(:)'));
nPt     = double(G.r_size); 
imDim   = size(N_u(:), 1);
nCh     = size(y, 2);

% Check format and throw errors if something is found
private_check(y, G, KFC_conj, N_u, n_u, nCh, nPt, C_flag);


%% Compute C*F*Y
% Do sparse matrix multiplication to map the data (y) onto the grid defined 
% by G.N_u (gridding)
x = bmSparseMat_vec(G, y, 'omp', 'complex', false);

% Do inverse FFT for every dimension in block format
x = bmBlockReshape(x, N_u);
for n = 1:3
    if imDim > (n-1)
        x = fftshift(ifft(ifftshift(x, n), [], n), n);
    end
end

% Return to column format
x = bmColReshape(x, N_u); 

% Crop data if needed (N_u > n_u)
if ~isequal(N_u, n_u)
    x = bmBlockReshape(x, N_u); 
    x = bmImCrope(x, N_u, n_u); 
    x = bmColReshape(x, n_u); 
end

% Reduce smoothing effect introduced by gridding using a window to grid the 
% data -> deapodization, multiply with coil sensitivity
x = x.*KFC_conj; 

% Eventual channel reduction if KFC_conj contains C_conj
if C_flag
    x = sum(x, 2);
end

end



%% Helper function
function private_check(y, G, KFC_conj, N_u, n_u, nCh, nPt, C_flag)
% This function checks that all inputs have the correct type, size and
% values needed for the computation to work. Throws errors if something
% amiss is found.

if not(isa(y, 'single'))
    error('The data''y'' must be of class single');
end

if not(isa(KFC_conj, 'single'))
    error('The matrix ''KFC_conj'' must be of class single');
end




if not(isequal(size(y), [nPt, nCh]))
    error('The data matrix ''y'' is not in the correct size');
end

if C_flag
    if not(isequal(size(KFC_conj), [prod(n_u(:)), nCh] ))
        error('The matrix ''C'' is not in the correct size');
    end
end




if sum(mod(N_u(:), 2)) > 0
    error('N_u must have all components even for the Fourier transform. ');
end

if sum(mod(n_u(:), 2)) > 0
    error('n_u must have all components even for the Fourier transform. ');
end

if not(strcmp(G.block_type, 'one_block'))
    error('The block type of G must be ''one_block''. ');
end

if strcmp(class(G), 'bmSparseMat')
    if not(strcmp(G.type, 'cpp_prepared')) && not(strcmp(G.type, 'l_squeezed_cpp_prepared'))
        error('G is bmSparseMat but is not cpp_prepared. ');
    end
end

end