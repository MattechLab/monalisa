function x = bmNasha(y, G, n_u, varargin) 
% x = bmNasha(y, G, n_u, varargin) 
%
% This function grids data from a non-uniform trajectory onto a uniform 
% grid given by the sparse matrix in G. The data is transformed from the 
% k-space to the image space, after which this function accounts for the 
% blurring introduced in the gridding (Deapodization).
% If the optional coil sensitivity is given, the images of all coils are
% combined into one reconstructed image.
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
%   y (array): The data that should be gridded from a non-uniform
%    trajectory onto a uniform grid.
%   G (bmSparseMat): Object containing the sparse matrix that grids the
%    non-uniform trajectory onto a uniform grid.
%   n_u (list): The size of the grid that the returned data should have.
%    This can be smaller, but not bigger, than the grid given by G.
%   varargin{1}: Array containing the coil sensitivity of each coil for
%    which the data is given in y. Has the same amount of points as y.
%   varargin{2}: Array containing the kernel matrix used for deapodization
%    after gridding the data onto the new grid.
%   varargin{3}: Char containing which fast Fourier transform algorithm
%    should be used. Options are 'MATLAB' using the MATLAB intern FFT
%    algorithm, 'FFTW' using the fastest Fourier transform in the west
%    software library or 'CUFFT' using the CUDA fast Fourier transform
%    library.
%
% Results:
%   x (array): The data regridded onto the uniform grid of size n_u, given 
%    in the image space and in the block format.

%% Initialize arguments
% Extract optional arguments
[C, K, fft_lib_flag] = bmVarargin(varargin); 

% Use G.N_u if n_u is empty
if isempty(n_u)
    n_u = G.N_u;
end

% Convert variables to the correct format
y           = single(y); 
N_u         = double(   int32(G.N_u(:)')    );
n_u         = double(   int32(n_u(:)')      );
dK_u        = double(   single(G.d_u(:)')   );
imDim       = size(N_u(:), 1);
nPt         = double(G.r_size);  
nCh         = size(y, 2);


% Create kernel matrix for interpolation and gridding if not given
if isempty(K)
    K = bmK(N_u, dK_u, nCh, G.kernel_type, G.nWin, G.kernelParam); 
end

% Transfrom K into the right format (important if given as argument)
K = single(bmBlockReshape(K, N_u));

% Set flag if empty
if isempty(fft_lib_flag)
    fft_lib_flag = 'MATLAB'; 
end

% Convert C to correct format if not empty
C_flag = false;
if not(isempty(C)) 
    C_flag = true;
    C = single(bmColReshape(C, n_u));
end
C = single(C); 

% Check format and throw errors if something is found
private_check(y, G, K, C, N_u, n_u, nCh, nPt); 


%% Data calculation
% Do sparse matrix multiplication to map the data (y) onto the grid defined 
% by G.N_u (gridding)
x = bmSparseMat_vec(G, y, 'omp', 'complex'); 

% Make sure the size is correct
x = bmBlockReshape(x, N_u); 

% Calculate the inverse fast Fourier transform, depends on flag (only
% MATLAB is used as of 08/2024)
if imDim == 1
    if strcmp(fft_lib_flag, 'MATLAB')
        x = bmIDF1(x, int32(N_u), single(dK_u) );
    elseif strcmp(fft_lib_flag, 'FFTW')
        [x_real, x_imag] = bmIDF1_FFTW_mex(real(x), imag(x), int32(N_u), single(dK_u) ); x = x_real + 1i*x_imag; 
    elseif strcmp(fft_lib_flag, 'CUFFT')
        [x_real, x_imag] = bmIDF1_CUFFT_mex(real(x), imag(x), int32(N_u), single(dK_u) ); x = x_real + 1i*x_imag; 
    end
elseif imDim == 2
    if strcmp(fft_lib_flag, 'MATLAB')
        x = bmIDF2(x, int32(N_u), single(dK_u) );
    elseif strcmp(fft_lib_flag, 'FFTW')
        [x_real, x_imag] = bmIDF2_FFTW_mex(real(x), imag(x), int32(N_u), single(dK_u) ); x = x_real + 1i*x_imag; 
    elseif strcmp(fft_lib_flag, 'CUFFT')
        [x_real, x_imag] = bmIDF2_CUFFT_mex(real(x), imag(x), int32(N_u), single(dK_u) ); x = x_real + 1i*x_imag; 
    end
elseif imDim == 3
    if strcmp(fft_lib_flag, 'MATLAB')
        x = bmIDF3(x, int32(N_u), single(dK_u) );
    elseif strcmp(fft_lib_flag, 'FFTW')
        [x_real, x_imag] = bmIDF3_FFTW_mex(real(x), imag(x), int32(N_u), single(dK_u) ); x = x_real + 1i*x_imag; 
    elseif strcmp(fft_lib_flag, 'CUFFT')
        [x_real, x_imag] = bmIDF3_CUFFT_mex(real(x), imag(x), int32(N_u), single(dK_u) ); x = x_real + 1i*x_imag; 
    end
end


%% Modify data
% Reduce smoothing effect introduced by gridding using a window to grid the 
% data -> deapodization
x = x.*K;

% Crop data if needed (N_u > n_u)
if ~isequal(N_u, n_u)
   x = bmImCrope(x, N_u, n_u);  
end

% Reconstruct image from the data of all coils if the coil sensitivity is
% given 
if not(isempty(C))
    % Reconstruct the image from different coils using a pseudoinverse
    % multiplication
    x = bmCoilSense_pinv(C, x, n_u);
end


end



function private_check(y, G, K, C, N_u, n_u, nCh, nPt)
% This function checks that all inputs have the correct type, size and
% values needed for the computation to work. Throws errors if something
% amiss is found.


if not(isa(y, 'single'))
    error('The data''y'' must be of class single. ');
end

if not(isa(K, 'single'))
    error('The matrix ''K'' must be of class single. ');
end

if not(isempty(C))
    if not(isa(C, 'single'))
        error('The data''C'' must be of class single. ');
    end
end




if not(isequal( size(y), [nPt, nCh] ))
    error('The data matrix ''y'' is not in the correct size. ');
end

if not(  isequal( size(K), [N_u, nCh] )  || isequal( size(K), N_u ) )
    error('The matrix ''K'' is not in the correct size. ');
end

if not(isempty(C))
    if not(isequal( size(C), [prod(n_u(:)), nCh] ))
        error('The matrix ''C'' has not the correct size. ');
    end
end




if sum(mod(N_u(:), 2)) > 0
    error('N_u must have all components even for the Fourier transform. ');
end

if not(strcmp(G.block_type, 'one_block'))
    error('The block type of G must be ''one_block''. ');
end

if not(strcmp(G.type, 'cpp_prepared')) && not(strcmp(G.type, 'l_squeezed_cpp_prepared'))
    error('G is not cpp_prepared. ');
end

end