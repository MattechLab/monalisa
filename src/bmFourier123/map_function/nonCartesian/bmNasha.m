% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function x = bmNasha(y, G, n_u, varargin) 

% argin_initial -----------------------------------------------------------
[C, K, fft_lib_flag] = bmVarargin(varargin); % Extract optional arguments

if isempty(n_u)
    n_u = N_u; % Why is this here ??? Maybe G.N_u?
end

y           = single(y); % Convert inputs to correct formats
N_u         = double(   int32(G.N_u(:)')    );
n_u         = double(   int32(n_u(:)')      );
dK_u        = double(   single(G.d_u(:)')   );
imDim       = size(N_u(:), 1);
nPt         = double(G.r_size);  
nCh         = size(y, 2);



if isempty(K)
    K = bmK(N_u, dK_u, nCh, G.kernel_type, G.nWin, G.kernelParam); % Create kernel matrix for interpolation and gridding
end
K = single(bmBlockReshape(K, N_u));

if isempty(fft_lib_flag)
    fft_lib_flag = 'MATLAB'; 
end

C_flag = false;
if not(isempty(C)) % Convert C to correct format if not empty
    C_flag = true;
    C = single(bmColReshape(C, n_u));
end
C = single(C); 

private_check(y, G, K, C, N_u, n_u, nCh, nPt); % Check format and 
% END_argin_initial -------------------------------------------------------

% gridding
x = bmSparseMat_vec(G, y, 'omp', 'complex'); % Do sparse matrix multiplication to map the data (y) onto the grid defined by G.N_u 

% Calculate the inverse fast Fourier transform
x = bmBlockReshape(x, N_u); 

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

% Deapodization
x = x.*K;

% eventual croping
if ~isequal(N_u, n_u)
   x = bmImCrope(x, N_u, n_u);  
end

% eventual coil_combine
if not(isempty(C))
    C = bmBlockReshape(C, n_u);
    x = bmCoilSense_pinv(C, x, n_u);
end


end



function private_check(y, G, K, C, N_u, n_u, nCh, nPt)
% private_check(y, G, K, C, N_u, n_u, nCh, nPt)
%
% This function checks that all inputs have the correct type, size and
% values needed for the computation to work. Throws errors if something is
% found.
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Parameters:
%   See bmNasha(...)

if not(isa(y, 'single'))
    error('The data''y'' must be of class single. ');
    return; 
end

if not(isa(K, 'single'))
    error('The matrix ''K'' must be of class single. ');
    return; 
end

if not(isempty(C))
    if not(isa(C, 'single'))
        error('The data''C'' must be of class single. ');
        return;
    end
end




if not(isequal( size(y), [nPt, nCh] ))
    error('The data matrix ''y'' is not in the correct size. ');
    return;
end

if not(  isequal( size(K), [N_u, nCh] )  || isequal( size(K), [N_u] ) )
    error('The matrix ''K'' is not in the correct size. ');
    return;
end

if not(isempty(C))
    if not(isequal( size(C), [prod(n_u(:)), nCh] ))
        error('The matrix ''C'' has not the correct size. ');
        return;
    end
end




if sum(mod(N_u(:), 2)) > 0
    error('N_u must have all components even for the Fourier transform. ');
    return;
end

if not(strcmp(G.block_type, 'one_block'))
    error('The block type of G must be ''one_block''. ');
    return;
end

if not(strcmp(G.type, 'cpp_prepared')) && not(strcmp(G.type, 'l_squeezed_cpp_prepared'))
    error('G is not cpp_prepared. ');
    return;
end

end