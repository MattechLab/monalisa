function y = bmShanna_MATLAB(x, G, KFC, n_u)
% y = bmShanna_MATLAB(x, G, KFC, n_u)
%
% This function copmutes the Fourier transform of CX -> F(CX) while
% gridding the points back to the trajectory.
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
%   x (array): The reconstructed image.
%   G (bmSparseMat): The forward gridding matrix (grid -> trajectory).
%   KFC (array): The kernel matrix used for deapodization multiplied with
%   the fourier factor and the coil sensitivity.
%   n_u (list): The size of the image space grid.
%
% Returns:
%   y (array): The computed k-space data (FXC = y).
%
% Examples:
%   y = bmShanna_MATLAB(x, Gu, KFC, n_u);

%% Initialize arguments
% Use G.N_u if n_u is empty
if isempty(n_u)
   n_u = G.N_u;  
end

% Convert variables to the correct format
N_u         = double(int32(G.N_u(:)'));
n_u         = double(int32(n_u(:)'));
imDim       = size(N_u(:), 1);
x_size_2    = size(x, 2);

% Get number of channels from input
if (x_size_2  == 1)
    nCh = size(KFC, 2);
else
    % There is data for each channel
    nCh = x_size_2;
end

% Check format and throw errors if something is found
private_check(x, G, KFC, N_u, n_u, nCh);


%% Compute F(CX)
% Repeat data for each channel if not all channels have data
if x_size_2 < nCh
    x = repmat(x, [1, nCh]);
end

% Reduce smoothing effect introduced by gridding using a window to grid the 
% data -> deapodization, multiply with coil sensitivity
x = x.*KFC;

% Eventual zero padding if N_u is bigger than n_u
if ~isequal(N_u, n_u)
   x = bmBlockReshape(x, n_u);    
   x = bmImZeroFill(x, N_u, n_u, 'complex_single'); 
   x = bmColReshape(x, N_u); 
end

% Do FFT for every dimension in block format
x = bmBlockReshape(x, N_u);
for n = 1:3
    if imDim > (n-1)
        x = fftshift(fft(ifftshift(x, n), [], n), n);
    end
end

% Return to column format
x = bmColReshape(x, N_u); 

% Do sparse matrix multiplication to map the gridded data (x) back to the
% non-uniform trajectory 
y = bmSparseMat_vec(G, x, 'omp', 'complex', false);

end




function private_check(x, G, KFC, N_u, n_u, nCh)
% This function checks that all inputs have the correct type, size and
% values needed for the computation to work. Throws errors if something
% amiss is found.

if not(isa(x, 'single'))
    error('The data''x'' must be of class single');
end

if not(isa(KFC, 'single'))
    error('The matrix ''KFC'' must be of class single');
end

if not(size(x, 1) == prod(n_u(:)))
    error('The data matrix ''x'' is not in the correct size');
end


if not(isequal(size(KFC), [prod(n_u(:)), nCh] ))
    error('The matrix ''K'' is probably not in the correct size');
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