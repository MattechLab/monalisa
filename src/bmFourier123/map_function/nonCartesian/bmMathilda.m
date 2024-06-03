% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% y is the complex data.
%
% t is the trajectory;
%
% v is the volumeElement;
%
% varargin : [C, N_u, n_u, dK_u, kernelType, nWin, kernelParam, fft_lib_flag, leight_flag]

function x = bmMathilda(y, t, v, varargin)

% initial -----------------------------------------------------------------
[C, N_u, n_u, dK_u, kernelType, nWin, kernelParam, fft_lib_flag, leight_flag] = bmVarargin(varargin);
[kernelType, nWin, kernelParam] = bmVarargin_kernelType_nWin_kernelParam(kernelType, nWin, kernelParam); 
[N_u, dK_u]                     = bmVarargin_N_u_dK_u(t, N_u, dK_u); 
if isempty(n_u)
   n_u = N_u;  
end
if isempty(fft_lib_flag)
    fft_lib_flag = 'MATLAB'; 
end
if isempty(leight_flag)
   leight_flag = true;  
end

if sum(mod(N_u(:), 2)) > 0
   error('N_u must have all components even for the Fourier transform. ');
   return; 
end

if size(y, 1) >= size(y, 2)
   y = y.';  
end

t = double(bmPointReshape(t)); 
y = single(bmPointReshape(y)); 
v = double(bmPointReshape(v));
C = single(C); 

N_u         = double(int32(N_u(:)' ));
n_u         = double(int32(n_u(:)' ));
dK_u        = double(single(dK_u(:)'));
N_u_single  = single(N_u); 
dK_u_single = single(dK_u); 
nWin        = double(nWin(:)');
kernelParam = double(kernelParam(:)');


imDim   = double(size(t, 1));
nCh     = double(size(y, 1));

disp(' '); 
disp('This is Mathilda...  '); 
disp(['Matrix size  ', num2str(N_u_single), ' . ']);
disp(['FoV          ', num2str(1./dK_u_single), ' . ']);
disp(' ');

% END argin initial -------------------------------------------------------


% NUFFT -------------------------------------------------------------------

% gridding
if leight_flag
    x = bmGridder_n2u_leight(y, t, v, N_u, dK_u, kernelType, nWin, kernelParam);
else
    x = bmGridder_n2u(y, t, v, N_u, dK_u, kernelType, nWin, kernelParam);
end


% fft
x = reshape(x, [nCh, prod(N_u(:))]);
x = x.'; 
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
K = single(bmK(N_u_single, dK_u_single, nCh, kernelType, nWin, kernelParam));
K = bmBlockReshape(K, N_u); 
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

% END_NUFFT ---------------------------------------------------------------

end % END_function

