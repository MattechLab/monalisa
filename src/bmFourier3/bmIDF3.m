function iFx = bmIDF3(x, N_u, dK_u)
% iFx = bmDFT3(x, N_u, dK_u)
%
% This function computes the inverse discrete Fourier transform for three 
% dimensional data using a fast Fourier transform (FFT) algorithm. 
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Parameters:
%   x (3D array): Contains the data on which the iFFT should be performed. 
%    The zero-frequency component is assumed to be in the center of x.
%   N_u (list): Contains the size of the grid.
%   dK_u (list): Contains the distances between grid points in every
%    dimension.
%
% Returns:
%   iFx (array): Contains the transformed data, having the same size as x.
%    The zero-frequency component is given in the center of iFx.

% Store the original size
argSize = size(x); 

% Reshape x to be seperated into blocks of size N_u
x = bmBlockReshape(x, N_u);

% Calculate iFFT for each dimension (assumes zero-frequency component to 
% be in the center of x). Returns the zero-frequency component back to the 
% center after performing the iFFT.
n = 1; 
x = fftshift(ifft(ifftshift(x, n), [], n), n);
n = 2; 
x = fftshift(ifft(ifftshift(x, n), [], n), n);
n = 3; 
x = fftshift(ifft(ifftshift(x, n), [], n), n);

% Fourier factor -> scaling needed due to MATLAB FFT implementation
F = single(  prod(N_u(:))*prod(dK_u(:))  ); 

% Scale x by the factor F to properly normalize the iFFT result
x = x * F; 

% Reshape to original size
iFx = reshape(x, argSize);

end