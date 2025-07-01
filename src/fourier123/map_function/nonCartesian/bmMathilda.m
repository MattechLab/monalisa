function x = bmMathilda(y, t, v, varargin)
% x = bmMathilda(y, t, v, varargin)
%
% Performs the gridded reconstruction of non-Cartesian MRI data. 
% First, the data is regridded onto a virtual Cartesian grid, then 
% an image is created via FFT. Finally, a deapodization step is performed. 
%
% If no coil sensitivity map C is provided, the function returns the 
% individual coil images. Otherwise the coil images are combined using C.
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Contributor:
%   Mauro Leidi (Documentation)
%   HES-SO
%   Lausanne - Switzerland
%   Jul 2025
%
% Parameters:
%   y (array): The complex raw data acquired along the non-Cartesian trajectory
%   t (array): The sampling trajectory coordinates
%   v (array): The volume elements associated with the sampling
%   varargin: Optional parameters, structured as:
%       C (array): Coil sensitivity maps
%       N_u (vector): Size of the Cartesian grid
%       n_u (vector): Number of Cartesian samples
%       dK_u (scalar or vector): Step size of the Cartesian grid
%       kernelType (string): Type of gridding kernel
%       nWin (int): Kernel width parameter
%       kernelParam (float): Additional kernel parameter (e.g., Kaiser-Bessel beta)
%       fft_lib_flag (bool): Flag to use external FFT library
%       leight_flag (bool): Flag to apply Leighton's correction
%
% Returns:
%   x (array): The reconstructed image. If no coil sensitivity map is provided,
%              returns individual coil images.

% initial -----------------------------------------------------------------
[C, N_u, n_u, dK_u, kernelType, nWin, kernelParam, fft_lib_flag, leight_flag] = bmVarargin(varargin);
% If the kernelType is not set correctly, the default type is gauss
% and if the kernelParam are not set some default value are chosen.
[kernelType, nWin, kernelParam] = bmVarargin_kernelType_nWin_kernelParam(kernelType, nWin, kernelParam); 
% Try to estimate the N_U and dK_U if they are not defined already, using
% the trajectory t. The points are assumed to be sampled in lines, each
% line containig N_U points, that are spaced apart of dK_U
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
    % This is a gridding function for non-iterative reconstructions
    % Returnes the data y regridded on the cartesian grid
    % Even if it's named x this is not an image is the cartesian k-space data.
    x = bmGridder_n2u_leight(y, t, v, N_u, dK_u, kernelType, nWin, kernelParam);
else
    warning('bmGridder_n2u is deprecated.')
    % Deprecated do not use if you aren't 100% sure
    x = bmGridder_n2u(y, t, v, N_u, dK_u, kernelType, nWin, kernelParam);
end


% run the fft to transform the cartesian k-space into images
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

% deapotization step: correct distortion inserted by the gridding method.
K = single(bmK(N_u_single, dK_u_single, nCh, kernelType, nWin, kernelParam));
K = bmBlockReshape(K, N_u); 
x = x.*K; 


% eventual croping
if ~isequal(N_u, n_u)
   x = bmImCrope(x, N_u, n_u);  
end

% if the Coil sensitivity is provided, it's used to combine coil images
if not(isempty(C))
    C = bmBlockReshape(C, n_u);
    x = bmCoilSense_pinv(C, x, n_u);
end

% END_NUFFT ---------------------------------------------------------------

end % END_function

