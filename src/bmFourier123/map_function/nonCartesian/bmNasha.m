% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function x = bmNasha(y, G, n_u, varargin)

% argin_initial -----------------------------------------------------------
[C, K, fft_lib_flag] = bmVarargin(varargin); 

if isempty(n_u)
    n_u = N_u; 
end

y           = single(y); 
N_u         = double(   int32(G.N_u(:)')    );
n_u         = double(   int32(n_u(:)')      );
dK_u        = double(   single(G.d_u(:)')   );
imDim       = size(N_u(:), 1);
nPt         = double(G.r_size);  
nCh         = size(y, 2);



if isempty(K)
    K = bmK(N_u, dK_u, nCh, G.kernel_type, G.nWin, G.kernelParam);
end
K = single(bmBlockReshape(K, N_u));

if isempty(fft_lib_flag)
    fft_lib_flag = 'MATLAB'; 
end

C_flag = false;
if not(isempty(C))
    C_flag = true;
    C = single(bmColReshape(C, n_u));
end
C = single(C); 

private_check(y, G, K, C, N_u, n_u, nCh, nPt); 
% END_argin_initial -------------------------------------------------------

% gridding
x = bmSparseMat_vec(G, y, 'omp', 'complex');

% fft
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

% deapotization
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