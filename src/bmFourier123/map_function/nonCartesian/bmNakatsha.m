function x = bmNakatsha(y, G, KFC_conj, C_flag, n_u, fft_lib_sFlag)
% x = bmNakatsha(y, G, KFC_conj, C_flag, n_u, fft_lib_sFlag)
%
% This function copmutes the conjugate transpose of the Fourier transform
% and the coil sensitvity of Y -> C*F*(Y) while gridding the points to the
% uniform grid. The inverse Fourier transform is calculated using the iFFT
% algorithm with different implementations.
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
%   false, the conjugate is not included in KFC_conj. Can only be false if
%   the MATLAB fft implementation is used. 
%   n_u (list): The size of the image space grid.
%   fft_lib_sFlag (char): The iFFT algorithm to be used. The options are
%   'MATLAB' using the MATLAB intern iFFT algorithm, 'FFTW' using the
%   fastest Fourier transform in the west software library or 'CUFFT'
%   using the CUDA fast Fourier transform library.
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
%   x = bmNakatsha(ve.*y, Gut, KF_conj, false, N_u, 'MATLAB'); 

% Use G.N_u if n_u is empty
if isempty(n_u)
    n_u = G.N_u;  
end

% Throw error if CUFFT or FFTW are used with C_flag false
if not(C_flag) & strcmp(fft_lib_sFlag, 'FFTW')
    error(' ''C_flag'' must be ''true'' for the FFTW version of bmNakatsha. ');
end
if not(C_flag) & strcmp(fft_lib_sFlag, 'CUFFT')
    error(' ''C_flag'' must be ''true'' for the CUFFT version of bmNakatsha. ');
end

% Throw error if CUFFT or FFTW are used with N_u ~= n_u
if ~isequal(G.N_u, n_u) & strcmp(fft_lib_sFlag, 'CUFFT')
    error('zero_filling is not implemented for Shanna_CUFFT. ');
end
if ~isequal(G.N_u, n_u) & strcmp(fft_lib_sFlag, 'FFTW')
    error('zero_filling is not implemented for Shanna_FFTW. ');
end

% Call correct function to use required iFFT implementation
if strcmp(fft_lib_sFlag, 'MATLAB')
    x = bmNakatsha_MATLAB(y, G, KFC_conj, C_flag, n_u);
elseif strcmp(fft_lib_sFlag, 'FFTW') 
    x = bmNakatsha_FFTW_omp(y, G, KFC_conj);
elseif strcmp(fft_lib_sFlag, 'CUFFT')
    x = bmNakatsha_CUFFT_omp(y, G, KFC_conj); 
end

end
