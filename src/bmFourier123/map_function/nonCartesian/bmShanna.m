function y = bmShanna(x, G, KFC, n_u, fft_lib_sFlag)
% y = bmShanna(x, G, KFC, n_u, fft_lib_sFlag)
%
% This function copmutes the Fourier transform of CX -> F(CX) while
% gridding the points back to the trajectory. The Fourier transform is
% calculated using the FFT algorithm with different implementations.
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
%   fft_lib_sFlag (char): The FFT algorithm to be used. The options are
%   'MATLAB' using the MATLAB intern FFT algorithm, 'FFTW' using the
%   fastest Fourier transform in the west software library or 'CUFFT'
%   using the CUDA fast Fourier transform library.
%
% Returns:
%   y (array): The computed k-space data (FXC = y).
%
% Examples:
%   y = bmShanna(x, Gu, KF, N_u, 'MATLAB')

% Use G.N_u if n_u is empty
if isempty(n_u)
    n_u =  G.N_u; 
end

% Throw error if CUFFT or FFTW are used with N_u ~= n_u
if ~isequal(G.N_u, n_u) & strcmp(fft_lib_sFlag, 'CUFFT') 
    error('zero_filling is not implemented for Shanna_CUFFT. '); 
end
if ~isequal(G.N_u, n_u) & strcmp(fft_lib_sFlag, 'FFTW')
    error('zero_filling is not implemented for Shanna_FFTW. ');
end

% Call correct function to use required FFT implementation
if strcmp(fft_lib_sFlag, 'MATLAB')
    y = bmShanna_MATLAB(x, G, KFC, n_u); 
elseif strcmp(fft_lib_sFlag, 'FFTW')
    y = bmShanna_FFTW_omp(x, G, KFC); 
elseif strcmp(fft_lib_sFlag, 'CUFFT')
    y = bmShanna_CUFFT_omp(x, G, KFC); 
end



end
